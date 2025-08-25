import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const NewsSummarizerApp());
}

class NewsSummarizerApp extends StatelessWidget {
  const NewsSummarizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFC20CF9),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC20CF9),
          primary: const Color.fromARGB(255, 198, 10, 255),
          secondary: const Color(0xFFE907FF),
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
