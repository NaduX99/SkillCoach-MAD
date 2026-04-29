import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/milestone.dart';
import '../models/quiz_question.dart';
import '../models/user_criteria.dart';
import '../models/chat_message.dart';

class AIService {
  static const _apiKey = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: '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',
  );
  static const List<String> _models = [
    'llama-3.1-8b-instant',
    'mixtral-8x7b-32768',
    'llama-3.3-70b-versatile',
  ];

  // Reusable HTTP client with connection pooling for faster requests
  static final http.Client _client = http.Client();

  static Future<String> _call(String prompt) async {
    return _callWithModelFallback([
      {'role': 'user', 'content': prompt},
    ]);
  }

  static Future<String> _callWithModelFallback(
    List<Map<String, String>> messages, {
    int maxTokens = 4000,
  }) async {
    final sanitizedKey = _apiKey
        .replaceAll(RegExp(r'[^\x00-\x7F]+'), '')
        .trim();
    if (sanitizedKey.isEmpty) throw Exception('GROQ_API_KEY is not set.');

    String? lastError;

    for (var model in _models) {
      try {
       
        final res = await _client.post(
          Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $sanitizedKey',
          },
          body: jsonEncode({
            'model': model,
            'messages': messages,
            'temperature': 0.7,
            'max_tokens': maxTokens,
          }),
        ).timeout(const Duration(seconds: 12));

        if (res.statusCode == 200) {
          return (jsonDecode(res.body)['choices'][0]['message']['content'])
              as String;
        } else if (res.statusCode == 429) {
          lastError = 'Model $model reached rate limit: ${res.body}';
          continue; // Try next model
        } else {
          lastError = 'Groq API error ${res.statusCode}: ${res.body}';
          debugPrint('AIService: Model $model failed with ${res.statusCode}');
          continue; // Try next model instead of throwing immediately
        }
      } catch (e) {
        if (e.toString().contains('TimeoutException')) {
          lastError = 'Model $model timed out after 30s';
          continue;
        }
        if (e is Exception && e.toString().contains('429')) {
          lastError = e.toString();
          continue;
        }
        lastError = e.toString();
        continue; // Try next model on any error
      }
    }

    throw Exception('All models failed. Last error: $lastError');
  }

  static Future<List<Milestone>> generateRoadmap(
    String goal,
    String skill, {
    UserCriteria? criteria,
  }) async {
    String backgroundContext = "";
    if (criteria != null) {
      backgroundContext =
          """
Learner Profile:
- Education: ${criteria.education ?? 'N/A'}
- Experience Level: ${criteria.experienceLevel ?? 'Beginner'}
- Time Commitment: ${criteria.weeklyHours?.round() ?? 10} hours per week
""";
    }

    final prompt =
        '''
### SYSTEM RULES ###
1. FOCUS EXCLUSIVELY on technical milestones for the skill: "$skill".
2. ABSOLUTELY NO generic career coaching advice (e.g., networking, portfolio, resumes, job search).
3. ALL milestones must be technical sub-skills or practical implementation challenges related to $skill.

Learner Goal: "$goal"
$backgroundContext
Create exactly 5 TECHNICAL milestones.

Respond ONLY with valid JSON:
{
  "milestones": [
    {
      "title": "Milestone title",
      "description": "What the learner achieves",
      "topics": ["topic1", "topic2", "topic3"],
      "materials": [
        {"title": "Video Name", "type": "Video", "is_free": true, "url": "https://www.youtube.com/watch?v=ID"},
        {"title": "Official Docs", "type": "Documentation", "is_free": true, "url": "https://DOCS_URL"},
        {"title": "Course Name", "type": "Web Course", "is_free": false, "url": "https://example.com"}
      ]
    }
  ]
}
Rules: 5 milestones, each 3+ materials, include official docs, real YouTube URLs.
''';
    try {
      final text = await _call(prompt);
      final data = jsonDecode(_extractJson(text));
      final list = data['milestones'] as List;
      return list
          .asMap()
          .entries
          .map(
            (e) => Milestone.fromJson(
              (e.value as Map).cast<String, dynamic>(),
              e.key,
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('AIService: generateRoadmap failed: $e');
      rethrow;
    }
  }

  static Future<List<QuizQuestion>> generateQuiz(
    String skill,
    Milestone milestone, {
    UserCriteria? criteria,
  }) async {
    final prompt =
        '''
Generate a skill assessment quiz for "$skill", milestone: "${milestone.title}".
Topics: ${milestone.topics.join(', ')}.
Experience Level: ${criteria?.experienceLevel ?? 'Beginner'}.
Create exactly 10 multiple choice questions.

Respond ONLY with valid JSON:
{"questions": [{"question": "Q?", "options": ["A","B","C","D"], "correct_index": 0, "explanation": "Why"}]}
''';
    final text = await _call(prompt);
    final data = jsonDecode(_extractJson(text));
    return (data['questions'] as List)
        .map((q) => QuizQuestion.fromJson((q as Map).cast<String, dynamic>()))
        .toList();
  }

  static Future<String> getChatResponse(List<ChatMessage> history) async {
    final messages = [
      {
        'role': 'system',
        'content':
            '''You are the SkillCoachR AI Assistant, a high-performance career coach and skill command center. 
        Your personality is professional, encouraging, and cyber-professional.
        Help the user with roadmap questions, tech deep-dives, or career breakthroughs.
        Keep responses concise and highly actionable. Use tactical phrasing like "Analysis complete" or "Optimization identified" sparingly for flavor.''',
      },
      ...history.map(
        (m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text},
      ),
    ];

    return _callWithModelFallback(messages, maxTokens: 2000);
  }

  static Future<Map<String, dynamic>> generateRecommendations(
    UserCriteria criteria,
  ) async {
    final prompt =
        '''
You are an expert career coach AI. Generate personalized weekly learning picks based on the user's profile and goal.

User Goal: ${criteria.careerGoal ?? "Professional Growth"}
Experience Level: ${criteria.experienceLevel ?? "Beginner"}
Weekly Time: ${criteria.weeklyHours?.round() ?? 10} hours
Education: ${criteria.education ?? "N/A"}

Respond ONLY with valid JSON:
{
  "weeklyFocus": "A brief summary of what the user should focus on this week",
  "picks": [
    {
      "skill": "Specific skill name",
      "resource": "Specific resource title (e.g. 'Flutter documentation')",
      "type": "Video / Documentation / Web Course / Article",
      "duration": "e.g. 20 min or 1 hour",
      "priority": "High / Medium / Low",
      "url": "A real, high-quality URL (MUST start with http:// or https://)"
    }
  ],
  "totalHours": 5
}
Rules:
1. Exactly 3-5 picks.
2. Must use official documentation or high-quality YouTube links.
3. Priority MUST be High, Medium, or Low.
''';

    final text = await _call(prompt);
    return jsonDecode(_extractJson(text)) as Map<String, dynamic>;
  }

  static String _extractJson(String text) {
    try {
      final s = text.indexOf('{');
      final e = text.lastIndexOf('}');
      if (s == -1 || e == -1) throw Exception('No JSON found in AI response');
      return text.substring(s, e + 1);
    } catch (e) {
      debugPrint('AIService: JSON extraction failed. Raw text: $text');
      rethrow;
    }
  }
}
