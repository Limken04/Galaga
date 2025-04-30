import 'package:flutter/material.dart';

import 'screens/galaga_game.dart';

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
      home: const MyHomePage(title: 'Galaga'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.black, title: Text(title), centerTitle: true),
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Game title
            Container(
              margin: const EdgeInsets.only(bottom: 40),
              child: const Text('GALAGA', style: TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 8)),
            ),

            // Start game button
            Container(
              margin: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const GalagaGame()));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
                child: const Text('START GAME', style: TextStyle(fontSize: 24, letterSpacing: 2, color: Colors.white)),
              ),
            ),

            // Game instructions
            Container(
              margin: const EdgeInsets.only(top: 40),
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
          ],
        ),
      ),
    );
  }
}
