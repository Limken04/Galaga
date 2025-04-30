import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

/// Root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Galaga Game', theme: ThemeData.dark(), home: const HomeScreen(), debugShowCheckedModeBanner: false);
  }
}

/// Home screen with game start menu
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Basic app bar with title
      appBar: AppBar(title: const Text('Galaga'), backgroundColor: Colors.black, centerTitle: true),
      // Main body with dark theme
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
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GalagaGame())),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
                child: const Text('START GAME', style: TextStyle(fontSize: 24, letterSpacing: 2)),
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

/// Main Galaga game screen with stateful behavior
class GalagaGame extends StatefulWidget {
  const GalagaGame({super.key});
  @override
  State<GalagaGame> createState() => _GalagaGameState();
}

class _GalagaGameState extends State<GalagaGame> with SingleTickerProviderStateMixin {
  // Game state variables
  double playerX = 0.0;
  final double playerWidth = 50.0;
  final double playerHeight = 50.0;
  late double gameWidth;
  late double gameHeight;

  int score = 0;
  int level = 1;
  List<Offset> bullets = [];
  List<Offset> enemies = [];
  List<Offset> stars = []; // For starfield effect
  Timer? gameTimer;
  bool isGameOver = false;
  bool isPaused = false;

  // Difficulty settings
  double baseEnemySpeed = 0.001;
  double enemySpeedMultiplier = 1.0;

  // Animation controller for Game Over fade-in
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _initStars(); // Initialize starfield
    startGame();
  }

  /// Initialize starfield
  void _initStars() {
    stars.clear();
    final random = Random();
    // Create 50 stars at random positions
    for (int i = 0; i < 50; i++) {
      stars.add(
        Offset(
          random.nextDouble() * 2 - 1, // -1 to 1
          random.nextDouble() * 2 - 1, // -1 to 1
        ),
      );
    }
  }

  /// Updates star positions for parallax effect
  void _updateStars() {
    for (var i = 0; i < stars.length; i++) {
      stars[i] += Offset(0, 0.002); // Move stars down
      if (stars[i].dy > 1) {
        // Reset star to top when it goes off screen
        stars[i] = Offset(stars[i].dx, -1);
      }
    }
  }

  /// Starts the game loop and enemy spawn
  void startGame() {
    spawnEnemies();
    _controller.reset();
    level = 1;
    enemySpeedMultiplier = 1.0;
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) => updateGame());
  }

  /// Spawns enemies at the top
  void spawnEnemies() {
    enemies.clear();
    for (var i = 0; i < 3; i++) {
      for (var j = 0; j < 6; j++) {
        enemies.add(Offset(-0.8 + (j * 0.3), -0.8 + (i * 0.2)));
      }
    }
  }

  /// Updates game state including difficulty progression
  void updateGame() {
    if (isGameOver || isPaused) return;

    setState(() {
      // Update stars
      _updateStars();

      // Move bullets upward
      for (var i = bullets.length - 1; i >= 0; i--) {
        bullets[i] += const Offset(0, -0.05);
        if (bullets[i].dy < -1) bullets.removeAt(i);
      }

      checkCollisions();
      moveEnemies();

      // Check for level progression
      if (enemies.isEmpty) {
        level++;
        enemySpeedMultiplier = 1.0 + (level - 1) * 0.2; // Increase speed by 20% per level
        spawnEnemies();
      }
    });
  }

  /// Moves enemies with increased difficulty
  void moveEnemies() {
    final speed = baseEnemySpeed * enemySpeedMultiplier;
    for (var i = 0; i < enemies.length; i++) {
      enemies[i] += Offset(0, speed);
      if (enemies[i].dy > 1) {
        gameOver();
      }
    }
  }

  /// Checks for bullet-enemy collisions
  void checkCollisions() {
    for (var i = bullets.length - 1; i >= 0; i--) {
      for (var j = enemies.length - 1; j >= 0; j--) {
        if ((bullets[i].dx - enemies[j].dx).abs() < 0.1 && (bullets[i].dy - enemies[j].dy).abs() < 0.1) {
          bullets.removeAt(i);
          enemies.removeAt(j);
          score += 10;
          break;
        }
      }
    }
  }

  /// Triggers game over
  void gameOver() {
    isGameOver = true;
    gameTimer?.cancel();
    _controller.forward(); // Animate Game Over
  }

  /// Shoots a bullet from the player's current position
  void shoot() {
    setState(() {
      bullets.add(Offset(playerX, 0.8));
    });
  }

  /// Toggles game pause state
  void togglePause() {
    setState(() {
      isPaused = !isPaused;
      if (isPaused) {
        gameTimer?.cancel();
      } else {
        gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) => updateGame());
      }
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Level $level'),
        backgroundColor: Colors.black,
        actions: [
          Padding(padding: const EdgeInsets.all(16.0), child: Text('Score: $score', style: const TextStyle(fontSize: 18, color: Colors.white))),
        ],
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Game Status Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Replace Lives with Pause/Exit buttons
                Row(
                  children: [
                    IconButton(
                      icon: Icon(isPaused ? Icons.play_arrow : Icons.pause, color: Colors.white),
                      onPressed: togglePause,
                      tooltip: isPaused ? 'Resume Game' : 'Pause Game',
                    ),
                    IconButton(
                      icon: const Icon(Icons.exit_to_app, color: Colors.white),
                      onPressed: () {
                        gameTimer?.cancel();
                        Navigator.of(context).pop();
                      },
                      tooltip: 'Exit to Menu',
                    ),
                  ],
                ),
                Text('High Score: ${score > 0 ? score : 0}', style: const TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
          ),

          // Game Area
          Expanded(
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (!isPaused) {
                  setState(() {
                    playerX += details.delta.dx / gameWidth * 2;
                    playerX = playerX.clamp(-0.8, 0.8);
                  });
                }
              },
              onTapDown: (_) => !isPaused ? shoot() : null,
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(border: Border.all(color: Colors.blue.withOpacity(0.5), width: 2), color: Colors.black),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        gameWidth = constraints.maxWidth;
                        gameHeight = constraints.maxHeight;
                        return Stack(
                          children: [
                            // Starfield
                            ...stars.map(
                              (star) => Positioned(
                                top: (gameHeight / 2) + (star.dy * gameHeight / 2),
                                left: (gameWidth / 2) + (star.dx * gameWidth / 2),
                                child: Container(
                                  width: 2,
                                  height: 2,
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), shape: BoxShape.circle),
                                ),
                              ),
                            ),

                            // Player Ship
                            Positioned(
                              bottom: 20,
                              left: (gameWidth / 2) + (playerX * gameWidth / 2) - playerWidth / 2,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: playerWidth,
                                height: playerHeight,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.5), spreadRadius: 2, blurRadius: 5)],
                                ),
                              ),
                            ),

                            // Bullets and Enemies
                            ...bullets.map(
                              (b) => Positioned(
                                top: b.dy * gameHeight,
                                left: (gameWidth / 2) + (b.dx * gameWidth / 2) - 2,
                                child: Container(
                                  width: 4,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.yellow,
                                    boxShadow: [BoxShadow(color: Colors.yellow.withOpacity(0.5), spreadRadius: 1, blurRadius: 3)],
                                  ),
                                ),
                              ),
                            ),

                            ...enemies.map(
                              (e) => Positioned(
                                top: (gameHeight / 2) + (e.dy * gameHeight / 2) - 15,
                                left: (gameWidth / 2) + (e.dx * gameWidth / 2) - 15,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.5), spreadRadius: 2, blurRadius: 5)],
                                  ),
                                ),
                              ),
                            ),

                            // Pause Overlay
                            if (isPaused)
                              Container(
                                color: Colors.black.withOpacity(0.7),
                                child: const Center(
                                  child: Text('PAUSED', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                                ),
                              ),

                            // Game Over Overlay with Level Display
                            if (isGameOver)
                              FadeTransition(
                                opacity: _fadeIn,
                                child: Container(
                                  color: Colors.black.withOpacity(0.8),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text('GAME OVER', style: TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 20),
                                        Text('Final Level: $level', style: const TextStyle(fontSize: 24, color: Colors.white)),
                                        const SizedBox(height: 10),
                                        Text('Final Score: $score', style: const TextStyle(fontSize: 24, color: Colors.white)),
                                        const SizedBox(height: 30),
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              isGameOver = false;
                                              score = 0;
                                              enemies.clear();
                                              bullets.clear();
                                              playerX = 0;
                                              startGame();
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                          ),
                                          child: const Text('Play Again', style: TextStyle(fontSize: 20)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Control Instructions
          Container(
            padding: const EdgeInsets.all(16.0),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.swipe, color: Colors.white70),
                SizedBox(width: 8),
                Text('Swipe to move • Tap to shoot', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
