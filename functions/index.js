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

