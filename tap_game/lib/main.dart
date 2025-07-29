import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(TapGameApp());
}

class TapGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tap Game',
      home: TapGameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TapGameScreen extends StatefulWidget {
  @override
  _TapGameScreenState createState() => _TapGameScreenState();
}

class _TapGameScreenState extends State<TapGameScreen>
    with SingleTickerProviderStateMixin {
  int score = 0;
  int timeLeft = 30;
  bool gameOver = false;

  double circleX = 0.5;
  double circleY = 0.5;
  double circleRadius = 50;

  late Timer timer;
  late AnimationController animationController;
  late Animation<double> scaleAnimation;

  final random = Random();

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
    );

    scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOut),
    );

    startTimer();
  }

  Future<void> playTapSound() async {
    final player = AudioPlayer();
    await player.play(AssetSource('sounds/tap.wav'));
  }

  Future<void> playGameOverSound() async {
    final player = AudioPlayer();
    await player.play(AssetSource('sounds/game_over.wav'));
  }

  void startTimer() {
    timeLeft = 30;
    gameOver = false;
    score = 0;
    resetCirclePosition();

    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          gameOver = true;
          playGameOverSound();
          timer.cancel();
        }
      });
    });
  }

  void resetCirclePosition() {
    circleX = 0.2 + random.nextDouble() * 0.6;
    circleY = 0.2 + random.nextDouble() * 0.6;
  }

  void onTapDown(TapDownDetails details, BoxConstraints constraints) {
    if (gameOver) return;

    final tapX = details.localPosition.dx;
    final tapY = details.localPosition.dy;

    final circleCenterX = circleX * constraints.maxWidth;
    final circleCenterY = circleY * constraints.maxHeight;

    final dx = tapX - circleCenterX;
    final dy = tapY - circleCenterY;

    final distance = sqrt(dx * dx + dy * dy);

    if (distance <= circleRadius) {
      setState(() {
        score++;
        animationController.forward(from: 0);
        resetCirclePosition();
        playTapSound();
      });
    }
  }

  void restartGame() {
    setState(() {
      startTimer();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final adaptiveRadius = (circleRadius / 800) * size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) => onTapDown(details, constraints),
            child: Stack(
              children: [
                Positioned(
                  top: 40,
                  left: 20,
                  child: Text(
                    'Score: $score',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: Text(
                    'Time: $timeLeft',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Positioned(
                  left: circleX * constraints.maxWidth - adaptiveRadius,
                  top: circleY * constraints.maxHeight - adaptiveRadius,
                  child: ScaleTransition(
                    scale: scaleAnimation,
                    child: Container(
                      width: adaptiveRadius * 2,
                      height: adaptiveRadius * 2,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                if (gameOver)
                  Positioned.fill(
                    child: Container(
                      color: Colors.white.withOpacity(0.85),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'GAME OVER',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: restartGame,
                              child: Text(
                                'Restart',
                                style: TextStyle(fontSize: 24),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
