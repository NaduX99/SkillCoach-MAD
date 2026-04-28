require('dotenv').config();
const { OpenAI } = require('openai');

const groq = new OpenAI({
    apiKey: process.env.GROQ_API_KEY,
    baseURL: "https://api.groq.com/openai/v1",
});

async function testGroq() {
    console.log("🚀 Testing Groq API locally...");
    
    // Simulate what the Flutter app sends to the backend
    const prompt = `
        You are an expert career advisor AI. Your responses must be entirely valid JSON without any markdown blocks.
        
        User's Career Goal: Full Stack Developer
        Available Learning Time: 10 hours per week
        
        Skill Gaps (priority order):
        - React: High priority, current level 2/5, needs level 4/5
        - Node.js: Medium priority, current level 1/5, needs level 3/5
        
        Generate a structured week-by-week learning roadmap.
        
        Return ONLY valid JSON in this exact format:
        {
          "totalWeeks": 4,
          "steps": [
            {
              "order": 1,
              "skill": "React",
              "priority": "Critical/High/Medium/Low",
              "estimatedWeeks": 2,
              "status": "not_started",
              "resources": ["Official Docs"],
              "weeklyHours": 5
            }
          ]
        }
    `;

    try {
        const response = await groq.chat.completions.create({
            model: "llama3-8b-8192",
            messages: [
                { role: "system", content: "You strictly output JSON. No conversational text." },
                { role: "user", content: prompt }
            ],
            response_format: { type: "json_object" }
        });

        console.log("✅ Success! Groq responded with:\n");
        console.log(response.choices[0].message.content);
        
    } catch (e) {
        console.error("❌ Failed:", e.message);
    }
}

testGroq();
