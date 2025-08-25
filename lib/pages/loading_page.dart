import 'package:flutter/material.dart';
import '../services/backend_services.dart';
import 'result_page.dart';

class LoadingPage extends StatefulWidget {
  final String articleText;
  final String tone;

  const LoadingPage({super.key, required this.articleText, required this.tone});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  final _service = NewsAnalyzerService(
    "AIzaSyC_rThFdXnDQHQtTOHkL0IdY_z0jTP9eEg", // 🔑 Replace with your Gemini API key
  );

  @override
  void initState() {
    super.initState();
    _analyze();
  }

  Future<void> _analyze() async {
    final result = await _service.analyze(widget.articleText, widget.tone);

    if (!mounted) return;

    if (result != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ResultPage(result: result)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error analyzing article")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 5,
            ),
          ),
        ],
      ),
    );
  }
}
