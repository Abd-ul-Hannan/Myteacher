import 'dart:convert';
import 'package:http/http.dart' as http;

enum AIProvider { openAI, gemini, groq, custom }

class AIService {
  static AIProvider provider = AIProvider.groq;

  // 🔴 REPLACE THIS WITH YOUR OWN API KEY
  static String apiKey = "Add here your Api key";

  // 🔴 CORRECT GROQ MODEL NAMES (choose one)
  // Available models:
  // - llama-3.3-70b-versatile (RECOMMENDED - best performance)
  // - llama-3.1-70b-versatile
  // - llama-3.1-8b-instant (fastest)
  // - mixtral-8x7b-32768
  // - gemma2-9b-it
  
  static String model = "openai/gpt-oss-120b"; // Change this

  /// Call this once at app start (recommended)
  static void configure({
    required AIProvider aiProvider,
    required String key,
    required String modelName,
  }) {
    provider = aiProvider;
    apiKey = key;
    model = modelName;
  }

  static Future<String> getReply(String prompt) async {
    try {
      switch (provider) {
        case AIProvider.openAI:
          return await _openAI(prompt);
        case AIProvider.gemini:
          return await _gemini(prompt);
        case AIProvider.groq:
          return await _groq(prompt);
        case AIProvider.custom:
          return await _custom(prompt);
      }
    } catch (e) {
      print("❌ AI Service Error: $e");
      return "AI error: $e";
    }
  }

  // ---------------- OPENAI ----------------
  static Future<String> _openAI(String prompt) async {
    final res = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": model,
        "messages": [
          {"role": "user", "content": prompt}
        ],
      }),
    );

    if (res.statusCode != 200) {
      throw Exception("OpenAI ${res.statusCode}: ${res.body}");
    }

    final data = jsonDecode(res.body);
    return data["choices"][0]["message"]["content"];
  }

  // ---------------- GEMINI ----------------
  static Future<String> _gemini(String prompt) async {
    final res = await http.post(
      Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey",
      ),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ]
      }),
    );

    if (res.statusCode != 200) {
      throw Exception("Gemini ${res.statusCode}: ${res.body}");
    }

    final data = jsonDecode(res.body);
    return data["candidates"][0]["content"]["parts"][0]["text"];
  }

  // ---------------- GROQ (UPDATED) ----------------
  static Future<String> _groq(String prompt) async {
    print("🔍 Calling Groq API...");
    print("📝 Model: $model");
    
    try {
      final res = await http.post(
        Uri.parse("https://api.groq.com/openai/v1/chat/completions"),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": model,
          "messages": [
            {"role": "user", "content": prompt}
          ],
          "temperature": 0.7,
          "max_tokens": 1024,
        }),
      ).timeout(Duration(seconds: 30));

      print("📡 Response Status: ${res.statusCode}");

      if (res.statusCode != 200) {
        print("❌ Error Response: ${res.body}");
        throw Exception("Groq ${res.statusCode}: ${res.body}");
      }

      final data = jsonDecode(res.body);
      
      if (data["choices"] == null || data["choices"].isEmpty) {
        throw Exception("No choices in response");
      }
      
      final content = data["choices"][0]["message"]["content"];
      print("✅ Got response!");
      return content;
      
    } catch (e) {
      print("❌ Groq Error: $e");
      rethrow;
    }
  }

  // ---------------- CUSTOM ----------------
  static Future<String> _custom(String prompt) async {
    final res = await http.post(
      Uri.parse("YOUR_CUSTOM_API_ENDPOINT"),
      headers: {
        "Authorization": apiKey,
        "Content-Type": "application/json",
      },
      body: jsonEncode({"prompt": prompt}),
    );

    if (res.statusCode != 200) {
      throw Exception("Custom ${res.statusCode}: ${res.body}");
    }

    final data = jsonDecode(res.body);
    return data["reply"];
  }
}