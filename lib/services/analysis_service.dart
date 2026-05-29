import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config_provider.dart';

final analysisServiceProvider = Provider<AnalysisService>((ref) {
  final apiKey = ref.watch(configProvider).geminiApiKey;
  return AnalysisService(apiKey ?? '');
});

class RateLimitException implements Exception {
  final String message;
  RateLimitException(this.message);
  @override
  String toString() => message;
}

class AnalysisResult {
  final String title;
  final String summary;
  final String moodKeyword;
  final double moodScore;
  final List<String> emojis;

  AnalysisResult({
    required this.title,
    required this.summary,
    required this.moodKeyword,
    required this.moodScore,
    required this.emojis,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      title: json['title'] ?? 'Untitled Journey',
      summary: json['summary'] ?? 'No summary available.',
      moodKeyword: json['moodKeyword'] ?? 'Neutral',
      moodScore: (json['moodScore'] as num?)?.toDouble() ?? 0.0,
      emojis: List<String>.from(json['emojis'] ?? []),
    );
  }
}

class AnalysisService {
  final String apiKey;
  static const String _model = 'gemini-1.5-flash';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';

  // In-memory rate limiting tracking
  static final List<DateTime> _requestTimestamps = [];
  static const int _maxRequestsPerMinute = 5;

  AnalysisService(this.apiKey);

  Future<AnalysisResult?> analyzeTranscript(String transcript) async {
    final now = DateTime.now();
    // Clear timestamps older than 60 seconds
    _requestTimestamps.removeWhere((t) => now.difference(t).inSeconds > 60);

    if (_requestTimestamps.length >= _maxRequestsPerMinute) {
      throw RateLimitException("You are reflecting too quickly. Take a deep breath.");
    }

    _requestTimestamps.add(now);

    if (apiKey.isEmpty) throw Exception("API Key is missing");

    final url = Uri.parse('$_baseUrl/$_model:generateContent?key=$apiKey');
    
    final prompt = """
You are the "Narrative Engine" of StoryArc, a cinematic journaling app.
Analyze the following transcript and return a JSON object with the following fields:
- "title": A short, punchy, cinematic title for this session.
- "summary": A 1-2 sentence descriptive summary in a cinematic tone.
- "moodKeyword": A single word describing the primary mood (e.g., Anxious, Elated, Melancholic).
- "moodScore": A double between -1.0 (very negative) and 1.0 (very positive).
- "emojis": An array of exactly 3 emojis representing the session's theme.

Transcript:
\"\"\"
$transcript
\"\"\"

Return ONLY the JSON object. No markdown, no preamble.
""";

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [{"text": prompt}]
            }
          ],
          "generationConfig": {
            "response_mime_type": "application/json",
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        
        // Use compute to parse JSON in a background isolate to prevent UI jank
        return await compute(_parseAnalysisResult, text as String);
      } else {
        print("Analysis Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Analysis Exception: $e");
      return null;
    }
  }

  static AnalysisResult _parseAnalysisResult(String jsonString) {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);
      return AnalysisResult.fromJson(data);
    } catch (e) {
      print("JSON Parsing Error: $e");
      return AnalysisResult(
        title: "Analysis Failed",
        summary: "Could not parse AI response.",
        moodKeyword: "Error",
        moodScore: 0.0,
        emojis: ["⚠️"],
      );
    }
  }
}
