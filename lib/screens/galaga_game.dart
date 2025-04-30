import 'dart:async';

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

/// Home screen with a button to start the game
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Galaga Project')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const GalagaGame()));
          },
          child: const Text('Start Game'),
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
  List<Offset> bullets = [];
  List<Offset> enemies = [];
  Timer? gameTimer;
  bool isGameOver = false;

  // Animation controller for Game Over fade-in
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    startGame(); // Start game logic when screen is initialized
  }

  /// Starts the game loop and enemy spawn
  void startGame() {
    spawnEnemies();
    _controller.reset();
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

  /// Updates bullets, enemy positions, and checks for collisions
  void updateGame() {
    if (isGameOver) return;

    setState(() {
      // Move bullets upward
      for (var i = bullets.length - 1; i >= 0; i--) {
        bullets[i] += const Offset(0, -0.05);
        if (bullets[i].dy < -1) bullets.removeAt(i);
      }

      checkCollisions();
      moveEnemies();
    });
  }

  /// Moves enemies downward and ends game if they reach the bottom
  void moveEnemies() {
    for (var i = 0; i < enemies.length; i++) {
      enemies[i] += const Offset(0, 0.001);
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

  @override
  void dispose() {
    gameTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Galaga Game'), backgroundColor: Colors.deepPurple),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Restart the game
          setState(() {
            isGameOver = false;
            score = 0;
            bullets.clear();
            enemies.clear();
            playerX = 0;
            startGame();
          });
        },
        child: const Icon(Icons.refresh),
      ),
      backgroundColor: Colors.black,
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          // Drag to move player
          setState(() {
            playerX += details.delta.dx / gameWidth * 2;
            playerX = playerX.clamp(-0.8, 0.8);
          });
        },
        onTapDown: (_) => shoot(), // Tap to shoot
        child: LayoutBuilder(
          builder: (context, constraints) {
            gameWidth = constraints.maxWidth;
            gameHeight = constraints.maxHeight;

            return Stack(
              children: [
                // Player ship
                Positioned(
                  bottom: 20,
                  left: (gameWidth / 2) + (playerX * gameWidth / 2) - playerWidth / 2,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: playerWidth,
                    height: playerHeight,
                    decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                // Bullets
                ...bullets.map(
                  (b) => Positioned(
                    top: b.dy * gameHeight,
                    left: (gameWidth / 2) + (b.dx * gameWidth / 2) - 2,
                    child: Container(width: 4, height: 10, color: Colors.yellow),
                  ),
                ),

                // Enemies
                ...enemies.map(
                  (e) => Positioned(
                    top: (gameHeight / 2) + (e.dy * gameHeight / 2) - 15,
                    left: (gameWidth / 2) + (e.dx * gameWidth / 2) - 15,
                    child: Container(width: 30, height: 30, decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6))),
                  ),
                ),

                // Score Display
                Positioned(top: 20, right: 20, child: Text('Score: $score', style: const TextStyle(color: Colors.white, fontSize: 24))),

                // Game Over overlay
                if (isGameOver)
                  FadeTransition(
                    opacity: _fadeIn,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Game Over', style: TextStyle(fontSize: 48, color: Colors.white)),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              // Restart game from Game Over screen
                              setState(() {
                                isGameOver = false;
                                score = 0;
                                enemies.clear();
                                bullets.clear();
                                playerX = 0;
                                startGame();
                              });
                            },
                            child: const Text('Play Again'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
