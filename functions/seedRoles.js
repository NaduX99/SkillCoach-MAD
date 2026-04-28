const admin = require('firebase-admin');

// IMPORTANT: Before running this script, you must typically have a service account key.
// Set it via: export GOOGLE_APPLICATION_CREDENTIALS="path/to/serviceAccountKey.json"
// Or if you are fully authenticated locally via 'gcloud auth application-default login', this will just work.

admin.initializeApp({
  projectId: "skillcoachr-c39ad" // Targeting your active project
});

const db = admin.firestore();

const roles = [
  {
    id: 'fullstack_developer',
    roleName: "Full Stack Developer",
    requiredSkills: [
      { skillName: "React", requiredLevel: 4, weight: 0.9, category: "Frontend" },
      { skillName: "Node.js", requiredLevel: 4, weight: 0.85, category: "Backend" },
      { skillName: "SQL", requiredLevel: 3, weight: 0.7, category: "Database" },
      { skillName: "TypeScript", requiredLevel: 3, weight: 0.75, category: "Frontend" },
      { skillName: "Git", requiredLevel: 3, weight: 0.6, category: "Tools" },
      { skillName: "REST API", requiredLevel: 4, weight: 0.8, category: "Backend" }
    ]
  },
  {
    id: 'data_scientist',
    roleName: "Data Scientist",
    requiredSkills: [
      { skillName: "Python", requiredLevel: 5, weight: 0.95, category: "Programming" },
      { skillName: "Machine Learning", requiredLevel: 4, weight: 0.9, category: "AI" },
      { skillName: "SQL", requiredLevel: 3, weight: 0.7, category: "Database" },
      { skillName: "Statistics", requiredLevel: 4, weight: 0.85, category: "Math" }
    ]
  }
];

async function seedData() {
  console.log("Seeding Industry Roles...");
  try {
    for (const role of roles) {
      const { id, ...data } = role;
      await db.collection("industryRoles").doc(id).set(data);
      console.log(`✅ successfully seeded: ${role.roleName}`);
    }
    console.log("🎉 All roles seeded successfully!");
  } catch (error) {
    console.error("❌ Error seeding roles:", error);
  }
}

seedData();
