import 'package:flutter/material.dart';
import '../models/analysis_result.dart';

class ResultPage extends StatelessWidget {
  final AnalysisResult result;
  const ResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Result'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: _ResultView(result: result),
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final AnalysisResult result;
  const _ResultView({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String _formatDate(DateTime? d) {
      if (d == null) return 'Unknown';
      // Simple yyyy-mm-dd hh:mm without intl
      final y = d.year.toString().padLeft(4, '0');
      final m = d.month.toString().padLeft(2, '0');
      final da = d.day.toString().padLeft(2, '0');
      final hh = d.hour.toString().padLeft(2, '0');
      final mm = d.minute.toString().padLeft(2, '0');
      return '$y-$m-$da $hh:$mm';
    }

    int _pctFromSentiment(double s) {
      final clamped = s.clamp(-1.0, 1.0);
      return (((clamped + 1) / 2) * 100).round();
    }

    Widget _sectionTitle(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(t, style: theme.textTheme.titleLarge),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // -------- Article Details --------
        _sectionTitle('Article Details'),
        _InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(result.title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  _SmallMeta(
                    'Author',
                    result.author.isEmpty ? 'Unknown' : result.author,
                  ),
                  _SmallMeta('Published', _formatDate(result.publishedDate)),
                  _SmallMeta(
                    'Word Count',
                    result.wordCount > 0 ? '${result.wordCount}' : 'Unknown',
                  ),
                  _SmallMeta('Style Used', result.styleUsed),
                  _SmallMeta('Readability', result.readability),
                  _SmallMeta('Analyzed', _formatDate(result.analyzedAt)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // -------- Summary --------
        _sectionTitle('Summary'),
        _InfoCard(
          child: Text(result.summary, style: theme.textTheme.bodyLarge),
        ),
        const SizedBox(height: 16),

        // -------- Reliability --------
        _sectionTitle('Reliability Score'),
        _InfoCard(
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  width: 110,
                  height: 110,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: (result.reliabilityScore.clamp(0, 100)) / 100,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          result.reliabilityScore >= 70
                              ? Colors.green
                              : (result.reliabilityScore >= 40
                                    ? Colors.orange
                                    : Colors.red),
                        ),
                      ),
                      Center(
                        child: Text('${result.reliabilityScore.round()}%'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  result.reliabilityScore >= 70
                      ? 'High Reliability'
                      : result.reliabilityScore >= 40
                      ? 'Moderate Reliability'
                      : 'Low Reliability',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // -------- Bias Indicators --------
        _sectionTitle('Bias Indicators'),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _MetricChip(
              label: 'Sentiment',
              value: _pctFromSentiment(result.sentimentScore),
            ),
            _MetricChip(
              label: 'Subjectivity',
              value: (result.subjectivity * 100).clamp(0, 100).round(),
            ),
            _LabelChip(label: 'Leaning: ${result.leaning}'),
          ],
        ),
        if (result.flags.isNotEmpty) ...[
          const SizedBox(height: 12),
          _InfoCard(
            color: Colors.amber.withOpacity(0.08),
            borderColor: Colors.amber.shade200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.flag_outlined, color: Colors.amber),
                    SizedBox(width: 6),
                    Text('Potential bias cues'),
                  ],
                ),
                const SizedBox(height: 8),
                ...result.flags.map(
                  (f) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 6),
                        const SizedBox(width: 6),
                        Expanded(child: Text(f)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),

        // -------- Emotions --------
        if (result.emotions.isNotEmpty) ...[
          _sectionTitle('Emotion Signals'),
          _InfoCard(
            child: Column(
              children: [
                _EmotionBar(label: 'Joy', value: result.emotions['joy'] ?? 0),
                _EmotionBar(
                  label: 'Trust',
                  value: result.emotions['trust'] ?? 0,
                ),
                _EmotionBar(
                  label: 'Anger',
                  value: result.emotions['anger'] ?? 0,
                ),
                _EmotionBar(label: 'Fear', value: result.emotions['fear'] ?? 0),
                _EmotionBar(
                  label: 'Sadness',
                  value: result.emotions['sadness'] ?? 0,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // -------- Keywords --------
        if (result.keywords.isNotEmpty) ...[
          _sectionTitle('Top Keywords'),
          _InfoCard(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: result.keywords
                  .map(
                    (k) => Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blueGrey.shade100),
                      ),
                      child: Text(k),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // -------- Fact Check Verdict --------
        _sectionTitle('Fact-check Verdict'),
        _InfoCard(
          color: _verdictColor(result.factCheckVerdict).withOpacity(0.07),
          borderColor: _verdictColor(result.factCheckVerdict).withOpacity(0.4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.verified,
                color: _verdictColor(result.factCheckVerdict),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.factCheckVerdict,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _verdictHint(result.factCheckVerdict),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // -------- Source Comparisons --------
        if (result.comparisons.isNotEmpty) ...[
          _sectionTitle('How other outlets framed it'),
          Column(
            children: result.comparisons
                .map((c) => _ComparisonTile(c))
                .toList(),
          ),
        ],

        const SizedBox(height: 16),

        // -------- Final Verdict --------
        _InfoCard(
          color: Colors.blue.withOpacity(0.05),
          borderColor: Colors.blue.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI’s Final Verdict',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                result.reliabilityScore >= 70
                    ? 'This article seems well-balanced and reliable, with minor signs of bias.'
                    : result.reliabilityScore >= 40
                    ? 'This article contains noticeable bias and should be cross-checked.'
                    : 'This article shows strong bias and low reliability. Treat with caution.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Color _verdictColor(String verdict) {
  final v = verdict.toLowerCase();
  if (v.contains('verified') || v.contains('true')) return Colors.green;
  if (v.contains('mixed') || v.contains('partial')) return Colors.orange;
  if (v.contains('needs') || v.contains('unverified') || v.contains('false'))
    return Colors.red;
  return Colors.blueGrey;
}

String _verdictHint(String verdict) {
  final v = verdict.toLowerCase();
  if (v.contains('verified') || v.contains('true')) {
    return 'Key factual claims appear supported by available evidence.';
  } else if (v.contains('mixed') || v.contains('partial')) {
    return 'Some claims are accurate, others are disputed or missing context.';
  } else if (v.contains('needs') ||
      v.contains('unverified') ||
      v.contains('false')) {
    return 'Important claims are unverified. Cross-check with reliable sources.';
  }
  return 'No explicit verdict provided. Consider cross-checking key claims.';
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Color? borderColor;
  const _InfoCard({required this.child, this.color, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor ?? Colors.grey.shade200),
      ),
      child: child,
    );
  }
}

class _SmallMeta extends StatelessWidget {
  final String label;
  final String value;
  const _SmallMeta(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(value, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final int value; // 0..100
  const _MetricChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          const SizedBox(width: 8),
          _Gauge(value: value),
        ],
      ),
    );
  }
}

class _LabelChip extends StatelessWidget {
  final String label;
  const _LabelChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: Text(label),
    );
  }
}

class _Gauge extends StatelessWidget {
  final int value; // 0..100
  const _Gauge({required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 10,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          FractionallySizedBox(
            widthFactor: (value / 100).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text('$value%', style: const TextStyle(fontSize: 10)),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmotionBar extends StatelessWidget {
  final String label;
  final double value; // 0..1
  const _EmotionBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final pct = (value.clamp(0, 1) * 100).round();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label)),
          Expanded(
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: (pct / 100).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(width: 36, child: Text('$pct%', textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

class _ComparisonTile extends StatelessWidget {
  final SourceComparison c;
  const _ComparisonTile(this.c);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    int _toPct(double score) =>
        (((score.clamp(-1.0, 1.0) + 1) / 2) * 100).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.public, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.source, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Headline tone: ${c.headlineTone}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Text('Sentiment '),
                  _Gauge(value: _toPct(c.sentiment)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Text('Subjectivity '),
                  _Gauge(value: (c.subjectivity * 100).round()),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
