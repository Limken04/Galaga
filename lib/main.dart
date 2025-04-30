import 'dart:collection'; // Added for SplayTreeSet

import 'package:flutter/material.dart';

import 'screens/galaga_game.dart';

// Class to store score data
class ScoreData {
  final int score;
  final String date;

  ScoreData(this.score, this.date);
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Galaga Game',
      theme: ThemeData.dark(), // Changed to dark theme
      debugShowCheckedModeBanner: false,
      // Define initial route and route mapping
      initialRoute: '/',
      routes: {'/': (context) => const MyHomePage(title: 'Galaga'), '/game': (context) => const GalagaGame()},
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  bool _visible = false;
  double _titleScale = 0.5;

  // Helper method to get dummy high scores
  List<ScoreData> _getHighScores() {
    final scores = SplayTreeSet<ScoreData>((a, b) => b.score.compareTo(a.score));
    scores.addAll([
      ScoreData(1000, '2024-04-30'),
      ScoreData(850, '2024-04-29'),
      ScoreData(720, '2024-04-28'),
      ScoreData(500, '2024-04-27'),
      ScoreData(350, '2024-04-26'),
    ]);
    return scores.take(5).toList();
  }

  @override
  void initState() {
    super.initState();
    // Trigger animations after build
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _visible = true;
        _titleScale = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final highScores = _getHighScores();

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.black, title: Text(widget.title), centerTitle: true),
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Game title
            AnimatedScale(
              duration: const Duration(milliseconds: 800),
              scale: _titleScale,
              curve: Curves.elasticOut,
              child: const Text('GALAGA', style: TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 8)),
            ),

            // Animated High Scores ListView
            AnimatedOpacity(
              duration: const Duration(milliseconds: 800),
              opacity: _visible ? 1.0 : 0.0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(vertical: 20),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue.withOpacity(_visible ? 0.5 : 0.0)),
                  borderRadius: BorderRadius.circular(10),
                ),
                height: 200,
                width: 300,
                child: Column(
                  children: [
                    const Text('High Scores', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: highScores.length,
                        itemBuilder: (context, index) {
                          final score = highScores[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(color: index.isEven ? Colors.blue.withOpacity(0.1) : Colors.transparent),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('#${index + 1}', style: const TextStyle(color: Colors.white70)),
                                Text('${score.score}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                Text(score.date, style: const TextStyle(color: Colors.white70)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Animated Start Game button
            AnimatedOpacity(
              duration: const Duration(milliseconds: 800),
              opacity: _visible ? 1.0 : 0.0,
              child: Container(
                margin: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pushNamed('/game'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
                  child: const Text('START GAME', style: TextStyle(fontSize: 24, letterSpacing: 2, color: Colors.white)),
                ),
              ),
            ),

            // Animated Game Instructions
            AnimatedSlide(
              duration: const Duration(milliseconds: 800),
              offset: _visible ? Offset.zero : const Offset(0, 0.2),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 800),
                opacity: _visible ? 1.0 : 0.0,
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(20),
                  child: const Column(
                    children: [
                      Text('How to Play:', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text(
                        '• Swipe left/right to move\n• Tap screen to shoot\n• Destroy enemies to score',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
