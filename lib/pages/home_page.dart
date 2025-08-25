import 'package:flutter/material.dart';
import 'loading_page.dart';
import '../widgets/custom_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _urlController = TextEditingController();
  final _textController = TextEditingController();
  String? _selectedTone;

  final tones = [
    "Neutral summary",
    "Fact-only",
    "Explain to a 10-year-old",
  ];

  bool isLinkMode = true;

  @override
  void dispose() {
    _urlController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _analyze() {
    final inputText = isLinkMode
        ? _urlController.text.trim()
        : _textController.text.trim();

    if (inputText.isEmpty) {
      _showSnackBar(
        isLinkMode ? "Please enter a valid URL" : "Please paste article text",
      );
      return;
    }
    if (_selectedTone == null) {
      _showSnackBar("Please select a tone");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            LoadingPage(articleText: inputText, tone: _selectedTone!),
      ),
    );
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              const Text(
                "📰 News Summarizer",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Paste a news link or article text",
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),

              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _buildModeSwitch(),
                        const SizedBox(height: 20),
                        _buildInputField(),
                        const SizedBox(height: 20),
                        _buildToneChips(),
                        const SizedBox(height: 30),
                        CustomButton(
                          label: "Analyze",
                          icon: Icons.arrow_forward,
                          onPressed: _analyze,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeSwitch() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildSwitchButton("Paste Link", true),
          _buildSwitchButton("Paste Text", false),
        ],
      ),
    );
  }

  Widget _buildSwitchButton(String label, bool mode) {
    final isSelected = isLinkMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isLinkMode = mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black87 : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return TextField(
      controller: isLinkMode ? _urlController : _textController,
      maxLines: isLinkMode ? 2 : 6,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        hintText: isLinkMode
            ? "Enter article URL..."
            : "Paste full article text...",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Widget _buildToneChips() {
    return Wrap(
      spacing: 10,
      children: tones.map((tone) {
        final isSelected = _selectedTone == tone;
        return ChoiceChip(
          label: Text(tone),
          selected: isSelected,
          selectedColor: Colors.white,
          backgroundColor: Colors.white30,
          onSelected: (_) => setState(() => _selectedTone = tone),
        );
      }).toList(),
    );
  }
}
