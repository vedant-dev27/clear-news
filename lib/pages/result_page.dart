import 'package:flutter/material.dart';
import '../models/analysis_result.dart';

class ResultPage extends StatelessWidget {
  final AnalysisResult result;
  const ResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // Title bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Analysis Result",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Content scroll view
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _ResultCard(child: _ArticleDetails(result: result)),
                          _ResultCard(child: _Summary(result: result)),
                          _ResultCard(child: _Reliability(result: result)),
                          _ResultCard(child: _BiasIndicators(result: result)),
                          if (result.emotions.isNotEmpty)
                            _ResultCard(child: _Emotions(result: result)),
                          if (result.keywords.isNotEmpty)
                            _ResultCard(child: _Keywords(result: result)),
                          _ResultCard(child: _FactVerdict(result: result)),
                          if (result.comparisons.isNotEmpty)
                            _ResultCard(child: _Comparisons(result: result)),
                          _ResultCard(child: _FinalVerdict(result: result)),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------- MODERN CARD -------------------
class _ResultCard extends StatelessWidget {
  final Widget child;
  const _ResultCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ------------------- ARTICLE DETAILS -------------------
class _ArticleDetails extends StatelessWidget {
  final AnalysisResult result;
  const _ArticleDetails({required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(icon: Icons.article, title: "Article Details"),
        const SizedBox(height: 6),
        Text(result.title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            _MetaChip(
              label: "Author",
              value: result.author.isEmpty ? "Unknown" : result.author,
            ),
            _MetaChip(label: "Word Count", value: result.wordCount.toString()),
            _MetaChip(label: "Style", value: result.styleUsed),
            _MetaChip(label: "Readability", value: result.readability),
          ],
        ),
      ],
    );
  }
}

// ------------------- SUMMARY -------------------
class _Summary extends StatelessWidget {
  final AnalysisResult result;
  const _Summary({required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(icon: Icons.summarize, title: "Summary"),
        const SizedBox(height: 6),
        Text(result.summary, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

// ------------------- RELIABILITY -------------------
class _Reliability extends StatelessWidget {
  final AnalysisResult result;
  const _Reliability({required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionTitle(icon: Icons.verified, title: "Reliability"),
        const SizedBox(height: 10),
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: (result.reliabilityScore / 100).clamp(0, 1),
                strokeWidth: 9,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  result.reliabilityScore >= 70
                      ? Colors.green
                      : result.reliabilityScore >= 40
                      ? Colors.orange
                      : Colors.red,
                ),
              ),
              Center(
                child: Text(
                  "${result.reliabilityScore.round()}%",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          result.reliabilityScore >= 70
              ? "High Reliability"
              : result.reliabilityScore >= 40
              ? "Moderate Reliability"
              : "Low Reliability",
        ),
      ],
    );
  }
}

// ------------------- BIAS INDICATORS -------------------
class _BiasIndicators extends StatelessWidget {
  final AnalysisResult result;
  const _BiasIndicators({required this.result});

  int pctFromSentiment(double s) =>
      (((s.clamp(-1.0, 1.0) + 1) / 2) * 100).round();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(icon: Icons.flag, title: "Bias Indicators"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _Metric(
              label: "Sentiment",
              value: pctFromSentiment(result.sentimentScore),
            ),
            _Metric(
              label: "Subjectivity",
              value: (result.subjectivity * 100).round(),
            ),
            _Chip(label: "Leaning: ${result.leaning}"),
          ],
        ),
        if (result.flags.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...result.flags
              .map(
                (f) =>
                    Text("⚠️ $f", style: const TextStyle(color: Colors.orange)),
              )
              .toList(),
        ],
      ],
    );
  }
}

// ------------------- EMOTIONS -------------------
class _Emotions extends StatelessWidget {
  final AnalysisResult result;
  const _Emotions({required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(icon: Icons.mood, title: "Emotion Signals"),
        const SizedBox(height: 8),
        ...result.emotions.entries
            .map((e) => _EmotionBar(label: e.key, value: e.value))
            .toList(),
      ],
    );
  }
}

// ------------------- KEYWORDS -------------------
class _Keywords extends StatelessWidget {
  final AnalysisResult result;
  const _Keywords({required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(icon: Icons.key, title: "Top Keywords"),
        const SizedBox(height: 6),
        Wrap(
          spacing: 10,
          children: result.keywords
              .map(
                (k) => Chip(
                  label: Text(k),
                  backgroundColor: Colors.blueGrey.withOpacity(0.1),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

// ------------------- FACT VERDICT -------------------
class _FactVerdict extends StatelessWidget {
  final AnalysisResult result;
  const _FactVerdict({required this.result});

  Color verdictColor(String v) {
    final lc = v.toLowerCase();
    if (lc.contains("verified") || lc.contains("true")) return Colors.green;
    if (lc.contains("mixed") || lc.contains("partial")) return Colors.orange;
    if (lc.contains("false") || lc.contains("unverified")) return Colors.red;
    return Colors.blueGrey;
  }

  @override
  Widget build(BuildContext context) {
    final color = verdictColor(result.factCheckVerdict);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.verified, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.factCheckVerdict,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text("See supporting evidence for factual verification."),
            ],
          ),
        ),
      ],
    );
  }
}

// ------------------- COMPARISONS -------------------
class _Comparisons extends StatelessWidget {
  final AnalysisResult result;
  const _Comparisons({required this.result});

  int toPct(double s) => (((s.clamp(-1.0, 1.0) + 1) / 2) * 100).round();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(icon: Icons.public, title: "Other Outlets"),
        const SizedBox(height: 10),
        ...result.comparisons.map(
          (c) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.source, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text("Headline tone: ${c.headlineTone}"),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(child: Text("Sentiment")),
                    _Gauge(value: toPct(c.sentiment)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: Text("Subjectivity")),
                    _Gauge(value: (c.subjectivity * 100).round()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ------------------- FINAL VERDICT -------------------
class _FinalVerdict extends StatelessWidget {
  final AnalysisResult result;
  const _FinalVerdict({required this.result});

  @override
  Widget build(BuildContext context) {
    String text = result.reliabilityScore >= 70
        ? "This article seems well-balanced and reliable, with minor signs of bias."
        : result.reliabilityScore >= 40
        ? "This article contains noticeable bias and should be cross-checked."
        : "This article shows strong bias and low reliability. Treat with caution.";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(icon: Icons.gavel, title: "AI’s Final Verdict"),
        const SizedBox(height: 6),
        Text(text),
      ],
    );
  }
}

// ------------------- REUSABLE WIDGETS -------------------
class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final String value;
  const _MetaChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text("$label: $value"),
      backgroundColor: Colors.blueGrey.withOpacity(0.1),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final int value;
  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 6),
          _Gauge(value: value),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.blueGrey.withOpacity(0.1),
    );
  }
}

class _Gauge extends StatelessWidget {
  final int value;
  const _Gauge({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (value / 100).clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class _EmotionBar extends StatelessWidget {
  final String label;
  final double value;
  const _EmotionBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final pct = (value.clamp(0, 1) * 100).round();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(label)),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: pct / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text("$pct%"),
        ],
      ),
    );
  }
}
