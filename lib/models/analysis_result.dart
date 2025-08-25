// ==============================
// lib/models/analysis_result.dart
// ==============================

class AnalysisResult {
  // ---- Metadata ----
  final String title; // e.g., extracted or "Untitled"
  final String author; // "Unknown" if missing
  final DateTime? publishedDate; // nullable in case not provided
  final int wordCount; // 0 if unknown

  // ---- Core summary + style ----
  final String summary;
  final String styleUsed; // Neutral / Fact-only / Explain to a 10-year-old

  // ---- Bias metrics ----
  final double sentimentScore; // -1..1
  final double subjectivity; // 0..1
  final String leaning; // e.g., "Left", "Right", "Center"
  final double reliabilityScore; // 0..100

  // ---- Extra analysis ----
  final String readability; // e.g., "Easy", "College Level"
  final Map<String, double> emotions; // anger/joy/fear/sadness/trust 0..1
  final List<String> keywords; // top keywords
  final String factCheckVerdict; // e.g., "Needs Verification"
  final String writingStyle; // persuasive/informative etc
  final DateTime analyzedAt;

  // ---- Cross-source comparisons ----
  final List<SourceComparison> comparisons;
  final List<String> flags; // bias cues

  const AnalysisResult({
    // metadata
    required this.title,
    required this.author,
    required this.publishedDate,
    required this.wordCount,

    // core
    required this.summary,
    required this.styleUsed,

    // bias
    required this.sentimentScore,
    required this.subjectivity,
    required this.leaning,
    required this.reliabilityScore,

    // extra
    required this.readability,
    required this.emotions,
    required this.keywords,
    required this.factCheckVerdict,
    required this.writingStyle,
    required this.analyzedAt,

    // comparisons/flags
    required this.comparisons,
    required this.flags,
  });
}

class SourceComparison {
  final String source;
  final double sentiment; // -1..1
  final double subjectivity; // 0..1
  final String headlineTone; // e.g., "Neutral/Negative/Positive"

  const SourceComparison({
    required this.source,
    required this.sentiment,
    required this.subjectivity,
    required this.headlineTone,
  });
}


// ========================================
// lib/services/news_analyzer_service.dart
// ========================================


// ==============================
// lib/ui/result_page.dart
// ==============================
