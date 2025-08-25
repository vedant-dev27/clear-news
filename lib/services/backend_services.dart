import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/analysis_result.dart';

class NewsAnalyzerService {
  final String apiKey;
  NewsAnalyzerService(this.apiKey);

  Future<AnalysisResult?> analyze(String text, String tone) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey',
    );

    // Map UI tone -> instruction
    final normalizedTone = tone.toLowerCase().replaceAll('-', '').trim();
    String toneInstruction;
    switch (normalizedTone) {
      case 'neutral summary':
        toneInstruction =
            'Write in professional, balanced language. No bias, no emotion.';
        break;
      case 'factonly':
        toneInstruction =
            'List ONLY raw facts from the article. Do not use adjectives or explanations.';
        break;
      case 'explaintoa10yearold':
        toneInstruction =
            'Use very simple words and short sentences, like explaining to a 10-year-old child.';
        break;
      default:
        toneInstruction = 'Summarize neutrally.';
    }

    // Single, strict JSON-only prompt (aligned with the model)
    final prompt =
        '''
You are an AI news analyzer and bias detector.
Adapt style to: $toneInstruction.
Return ONLY a valid JSON object (no markdown, no commentary).

Schema:
{
  "title": "string",
  "author": "string",
  "publishedDate": "ISO date or empty",
  "wordCount": int,

  "styleUsed": "$tone",
  "summary": "string (~200 words, paragraph style, adapted to style)",

  "sentimentScore": float,   // -1..1
  "subjectivity": float,     // 0..1
  "leaning": "string",     // Left/Right/Center/Unknown
  "reliabilityScore": float, // 0..100

  "readability": "string",  // Easy/Medium/Hard etc
  "emotions": { "anger": float, "joy": float, "fear": float, "sadness": float, "trust": float },
  "keywords": ["string"],
  "factCheckVerdict": "string", // e.g., Verified/Mostly True/Mixed/Needs Verification/Unverified
  "writingStyle": "string",
  "analyzedAt": "ISO timestamp",

  "flags": ["string"],
  "comparisons": [
    { "source": "string", "sentiment": float, "subjectivity": float, "headlineTone": "string" }
  ]
}

Article: $text
''';

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
      }),
    );

    if (response.statusCode != 200) {
      // Log and bail gracefully
      // ignore: avoid_print
      print('Error: ${response.statusCode} ${response.body}');
      return null;
    }

    try {
      final data = jsonDecode(response.body);
      final raw =
          data['candidates'][0]['content']['parts'][0]['text'] as String;
      final cleaned = _cleanJson(raw);
      final parsed = jsonDecode(cleaned) as Map<String, dynamic>;

      // Safe extract helpers
      double _numToDouble(dynamic v, [double def = 0]) =>
          (v is num) ? v.toDouble() : def;

      DateTime? _tryParseDate(String? s) {
        if (s == null || s.trim().isEmpty) return null;
        try {
          return DateTime.parse(s).toLocal();
        } catch (_) {
          return null;
        }
      }

      int _toInt(dynamic v) {
        if (v is int) return v;
        if (v is double) return v.round();
        if (v is String) {
          final n = int.tryParse(v);
          if (n != null) return n;
        }
        return 0;
      }

      final comparisonsRaw = (parsed['comparisons'] as List?) ?? const [];
      final comparisons = comparisonsRaw.map((c) {
        final m = (c as Map?) ?? const {};
        return SourceComparison(
          source: (m['source'] ?? 'Unknown').toString(),
          sentiment: _numToDouble(m['sentiment'], 0.0),
          subjectivity: _numToDouble(m['subjectivity'], 0.0),
          headlineTone: (m['headlineTone'] ?? 'Neutral').toString(),
        );
      }).toList();

      final emotionsRaw = (parsed['emotions'] as Map?) ?? const {};
      final emotions = <String, double>{
        'anger': _numToDouble(emotionsRaw['anger'], 0.0),
        'joy': _numToDouble(emotionsRaw['joy'], 0.0),
        'fear': _numToDouble(emotionsRaw['fear'], 0.0),
        'sadness': _numToDouble(emotionsRaw['sadness'], 0.0),
        'trust': _numToDouble(emotionsRaw['trust'], 0.0),
      };

      return AnalysisResult(
        // metadata
        title: (parsed['title'] ?? 'Untitled').toString(),
        author: (parsed['author'] ?? 'Unknown').toString(),
        publishedDate: _tryParseDate(parsed['publishedDate']?.toString()),
        wordCount: _toInt(parsed['wordCount']),

        // core
        summary: (parsed['summary'] ?? 'No summary generated.').toString(),
        styleUsed: (parsed['styleUsed'] ?? tone).toString(),

        // bias
        sentimentScore: _numToDouble(parsed['sentimentScore'], 0.0),
        subjectivity: _numToDouble(parsed['subjectivity'], 0.0),
        leaning: (parsed['leaning'] ?? 'Unknown').toString(),
        reliabilityScore: _numToDouble(parsed['reliabilityScore'], 50.0),

        // extra
        readability: (parsed['readability'] ?? 'Unknown').toString(),
        emotions: emotions,
        keywords: List<String>.from(
          (parsed['keywords'] as List?)?.map((e) => e.toString()) ?? const [],
        ),
        factCheckVerdict: (parsed['factCheckVerdict'] ?? 'Not available')
            .toString(),
        writingStyle: (parsed['writingStyle'] ?? 'Not specified').toString(),
        analyzedAt:
            _tryParseDate(parsed['analyzedAt']?.toString()) ?? DateTime.now(),

        // comparisons/flags
        comparisons: comparisons,
        flags: List<String>.from(
          (parsed['flags'] as List?)?.map((e) => e.toString()) ?? const [],
        ),
      );
    } catch (e) {
      // ignore: avoid_print
      print('❌ JSON parse failed: $e');
      return null;
    }
  }

  String _cleanJson(String raw) {
    var cleaned = raw.trim();
    if (cleaned.startsWith('```')) {
      cleaned = cleaned.replaceAll(RegExp(r'```(json)?'), '').trim();
    }
    final lastBrace = cleaned.lastIndexOf('}');
    if (lastBrace != -1) {
      cleaned = cleaned.substring(0, lastBrace + 1);
    }
    return cleaned;
  }
}
