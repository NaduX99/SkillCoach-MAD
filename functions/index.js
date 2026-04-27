const functions = require("firebase-functions");
const admin = require("firebase-admin");
const {OpenAI} = require("openai");

admin.initializeApp();

// Initialize OpenAI client for Groq API
// The .env file automatically populates process.env locally and on deployment
const getGroqClient = () => {
  return new OpenAI({
    apiKey: process.env.GROQ_API_KEY,
    baseURL: "https://api.groq.com/openai/v1", // Groq structured OpenAI endpoint
  });
};

// Helper to clean JSON responses if wrapped in markdown
function cleanJsonResponse(text) {
  let cleaned = text.trim();
  if (cleaned.startsWith("```json")) {
    cleaned = cleaned.substring(7);
  } else if (cleaned.startsWith("```")) {
    cleaned = cleaned.substring(3);
  }
  if (cleaned.endsWith("```")) {
    cleaned = cleaned.substring(0, cleaned.length - 3);
  }
  return cleaned.trim();
}

//  ROADMAP GENERATION 
exports.generateRoadmap = functions.https.onCall(async (data, context) => {
  // Auth check
  if (!context.auth) {
    throw new functions.https.HttpsError(
        "unauthenticated",
        "Login required!",
    );
  }

  const uid = context.auth.uid;
  const {gaps, careerGoal, availableTime} = data;

  const groq = getGroqClient();

  // Prompt build
  const prompt = `
    You are an expert career advisor AI. Your responses must be entirely valid JSON without any markdown blocks.
    
    User's Career Goal: ${careerGoal}
    Available Learning Time: ${availableTime} hours per week
    
    Skill Gaps (priority order):
    ${gaps.map((g) =>
    `- ${g.skill}: ${g.priority} priority, current level ${g.userLevel}/5, needs level ${g.requiredLevel}/5`,
  ).join("\n")}
    
    Generate a structured week-by-week learning roadmap.
    Consider skill dependencies (learn basics before advanced).
    
    Return ONLY valid JSON in this exact format, with no markdown \`\`\` wrappers:
    {
      "totalWeeks": number,
      "steps": [
        {
          "order": 1,
          "skill": "skill name",
          "priority": "Critical/High/Medium/Low",
          "estimatedWeeks": number,
          "status": "not_started",
          "resources": ["resource 1", "resource 2"],
          "weeklyHours": number
        }
      ]
    }
  `;

  try {
    const response = await groq.chat.completions.create({
      model: "llama3-8b-8192", // Fast and robust model
      messages: [
        {role: "system", content: "You strictly output JSON. No conversational text."},
        {role: "user", content: prompt},
      ],
      response_format: {type: "json_object"}, // Groq supports strict JSON mode
    });

    let responseText = response.choices[0].message.content.trim();
    responseText = cleanJsonResponse(responseText);

    const roadmapData = JSON.parse(responseText);

    const roadmapRef = await admin.firestore()
        .collection("users")
        .doc(uid)
        .collection("roadmaps")
        .add({
          ...roadmapData,
          careerGoal,
          completedSkills: 0,
          progress: 0,
          generatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

    return {
      success: true,
      roadmapId: roadmapRef.id,
      roadmap: roadmapData,
    };
  } catch (error) {
    throw new functions.https.HttpsError(
        "internal",
        "Roadmap generate failed: " + error.message,
    );
  }
});

// ── WEEKLY RECOMMENDATIONS ────────────────────
exports.generateWeeklyRecommendations = functions.pubsub
    .schedule("every monday 08:00")
    .timeZone("Asia/Colombo")
    .onRun(async (context) => {
      const db = admin.firestore();
      const groq = getGroqClient();

      const usersSnap = await db
          .collection("users")
          .where("profileCompleted", "==", true)
          .get();

      const promises = usersSnap.docs.map(async (userDoc) => {
        const uid = userDoc.id;
        const userData = userDoc.data();

        const roadmapSnap = await db
            .collection("users").doc(uid)
            .collection("roadmaps")
            .orderBy("generatedAt", "desc")
            .limit(1)
            .get();

        if (roadmapSnap.empty) return;

        const roadmap = roadmapSnap.docs[0].data();
        const remainingSteps = roadmap.steps.filter(
            (s) => s.status !== "completed",
        );

        const prompt = `
        You are an expert career advisor AI.
        User Goal: ${userData.careerGoal}
        Available time this week: ${userData.availableLearningTime} hours
        
        Remaining skills to learn:
        ${remainingSteps.slice(0, 5).map((s) =>
    `- ${s.skill} (${s.priority}): ${s.resources.join(", ")}`,
  ).join("\n")}
        
        Generate this week's focused learning picks (max 3 items).
        Return ONLY valid JSON, with absolutely no markdown blocks or surrounding text.
        
        Format:
        {
          "weeklyFocus": "brief focus description",
          "picks": [
            {
              "skill": "skill name",
              "resource": "specific resource name",
              "estimatedHours": number,
              "priority": "High/Medium/Low",
              "reason": "why this week"
            }
          ],
          "totalHours": number
        }
      `;

        try {
          const response = await groq.chat.completions.create({
            model: "llama3-8b-8192",
            messages: [
              {role: "system", content: "You strictly output JSON. No conversational text."},
              {role: "user", content: prompt},
            ],
            response_format: {type: "json_object"},
          });

          let responseText = response.choices[0].message.content.trim();
          responseText = cleanJsonResponse(responseText);

          const recommendations = JSON.parse(responseText);

          const now = new Date();
          const weekId = `week_${now.getFullYear()}_${Math.ceil(now.getDate() / 7)}`;

          await db
              .collection("users").doc(uid)
              .collection("weeklyRecommendations")
              .doc(weekId)
              .set({
                ...recommendations,
                weekId,
                generatedAt: admin.firestore.FieldValue.serverTimestamp(),
              });

          await admin.messaging().sendToTopic(
              `user_${uid}`,
              {
                notification: {
                  title: "This Week's Learning Picks Ready! 🎯",
                  body: recommendations.weeklyFocus,
                },
                data: {type: "weekly_recommendations"},
              },
          );
        } catch (e) {
          console.error("Failed to generate weekly recommendation for user: ", uid, e);
        }
      });

      await Promise.all(promises);
      console.log("Weekly recommendations generated!");
      return null;
    });
