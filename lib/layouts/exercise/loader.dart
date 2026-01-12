import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';
import 'dart:async';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoaderScreen(),
    );
  }
}

class LoaderScreen extends StatefulWidget {
  const LoaderScreen({super.key});

  @override
  State<LoaderScreen> createState() => _LoaderScreenState();
}

class _LoaderScreenState extends State<LoaderScreen>
    with TickerProviderStateMixin {
  late AnimationController _ringController;
  late AnimationController _runnerController;
  late AnimationController _progressController;
  late AnimationController _messageController;
  late AnimationController _trackController;
  Timer? _messageTimer;

  final List<String> messages = [
    "Finding your stride",
    "Mapping warm-ups and cool-downs",
    "Setting pace and intervals",
    "Optimizing rest between sets",
    "Fueling tips incoming",
    "Dialing in progression blocks",
  ];
  int _messageIndex = 0;

  @override
  void initState() {
    super.initState();

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _runnerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _trackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _messageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _startMessageRotation();
  }

  void _startMessageRotation() {
    _messageTimer = Timer.periodic(const Duration(milliseconds: 1600), (_) {
      _messageController.forward(from: 0).then((_) {
        setState(() {
          _messageIndex = (_messageIndex + 1) % messages.length;
        });
        _messageController.reverse();
      });
    });
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _ringController.dispose();
    _runnerController.dispose();
    _progressController.dispose();
    _trackController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0f1431);
    const bg2 = Color(0xFF181c3a);
    const edge = Color(0xFF2b2f58);
    const muted = Color(0xFFb8c0e3);
    const accent = Color(0xFFb787ff);
    const accent2 = Color(0xFF2fe0c7);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.5,
            colors: [bg2, bg],
            stops: [0, 0.6],
          ),
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 560),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF191c40).withOpacity(0.75),
                  const Color(0xFF101330).withOpacity(0.85),
                ],
              ),
              border: Border.all(color: edge),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.45),
                  blurRadius: 60,
                  offset: const Offset(0, 20),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.04),
                  blurRadius: 0,
                  spreadRadius: 1,
                  offset: Offset.zero,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _ringController,
                        builder: (_, __) {
                          return CustomPaint(
                            size: const Size(140, 140),
                            painter: RingPainter(
                              _ringController.value,
                              accent,
                              accent2,
                            ),
                          );
                        },
                      ),
                      AnimatedBuilder(
                        animation: Listenable.merge([
                          _runnerController,
                          _trackController,
                        ]),
                        builder: (_, __) {
                          return CustomPaint(
                            size: const Size(140, 140),
                            painter: RunnerWithTrackPainter(
                              runnerProgress: _runnerController.value,
                              trackProgress: _trackController.value,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  "Lacing up your personalized plan",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFeef1ff),
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 24,
                  child: AnimatedBuilder(
                    animation: _messageController,
                    builder: (_, __) {
                      final opacity = _messageController.value;
                      final offset = (1 - _messageController.value) * 6;
                      return Transform.translate(
                        offset: Offset(0, offset),
                        child: Opacity(
                          opacity: opacity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  messages[_messageIndex],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: muted,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const AnimatedDots(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                AnimatedBuilder(
                  animation: _progressController,
                  builder: (_, __) {
                    final t = _progressController.value;
                    final progress = t < 0.5
                        ? lerpDouble(0.18, 0.82, t * 2)!
                        : lerpDouble(0.82, 0.18, (t - 0.5) * 2)!;
                    return Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22264e),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFF2f3562)),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: const LinearGradient(
                              colors: [accent, Color(0xFF8f6bff), accent2],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Animated dots
class AnimatedDots extends StatefulWidget {
  const AnimatedDots({super.key});
  @override
  State<AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<AnimatedDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<String> _dots = ['', '.', '..', '...'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final index = (_controller.value * 4).floor() % 4;
        return SizedBox(
          width: 24,
          child: Text(
            _dots[index],
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFb8c0e3),
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }
}

// Smooth gradient ring
class RingPainter extends CustomPainter {
  final double progress;
  final Color startColor;
  final Color endColor;
  RingPainter(this.progress, this.startColor, this.endColor);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    final backgroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..color = const Color(0xFF353b72);
    canvas.drawCircle(center, radius, backgroundPaint);

    final sweepProgress = lerpDouble(
      0.35,
      1.0,
      (sin(progress * pi * 2) + 1) / 2,
    )!;
    final opacity = lerpDouble(0.7, 1.0, (sin(progress * pi * 2) + 1) / 2)!;

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [
          startColor.withOpacity(opacity),
          endColor.withOpacity(opacity),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * sweepProgress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Runner with track
class RunnerWithTrackPainter extends CustomPainter {
  final double runnerProgress;
  final double trackProgress;

  RunnerWithTrackPainter({
    required this.runnerProgress,
    required this.trackProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    _drawTrack(canvas, center);
    _drawRunner(canvas, center);
  }

  void _drawTrack(Canvas canvas, Offset center) {
    final paint = Paint()
      ..color = const Color(0xFF6671c9)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final y = center.dy + 30;
    final offset = (trackProgress * 40) % 40;

    for (int i = 0; i < 4; i++) {
      final x = center.dx - 35 + (i * 22) - offset;
      canvas.drawLine(Offset(x, y), Offset(x + 14, y), paint);
    }
  }

  void _drawRunner(Canvas canvas, Offset center) {
    final bob = sin(runnerProgress * 2 * pi) * 2;
    canvas.save();
    canvas.translate(center.dx, center.dy + bob);

    const torsoColor = Color(0xFFcde1ff);
    const legColor = Color(0xFF8fd8cc);
    const skinColor = Color(0xFFffd585);
    const headColor = Color(0xFFb787ff);

    final torsoPaint = Paint()
      ..color = torsoColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final legPaint = Paint()
      ..color = legColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final skinPaint = Paint()
      ..color = skinColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Head
    canvas.drawCircle(const Offset(-6, -10), 5, Paint()..color = headColor);
    // Torso
    canvas.drawLine(const Offset(-2, -4), const Offset(8, 6), torsoPaint);
    // Legs
    final stride = sin(runnerProgress * 2 * pi);
    _drawLimb(
      canvas,
      const Offset(6, 6),
      lerpDouble(35, -45, (stride + 1) / 2)! * pi / 180,
      legPaint,
      12,
      10,
    );
    _drawLimb(
      canvas,
      const Offset(6, 6),
      lerpDouble(-45, 35, (stride + 1) / 2)! * pi / 180,
      legPaint,
      -10,
      12,
    );
    // Arms
    _drawLimb(
      canvas,
      const Offset(0, -2),
      lerpDouble(-45, 35, (stride + 1) / 2)! * pi / 180,
      skinPaint,
      10,
      4,
    );
    _drawLimb(
      canvas,
      const Offset(0, -2),
      lerpDouble(35, -45, (stride + 1) / 2)! * pi / 180,
      skinPaint,
      -14,
      6,
    );

    canvas.restore();
  }

  void _drawLimb(
    Canvas canvas,
    Offset start,
    double angle,
    Paint paint,
    double dx,
    double dy,
  ) {
    canvas.save();
    canvas.translate(start.dx, start.dy);
    canvas.rotate(angle);
    canvas.drawLine(Offset.zero, Offset(dx, dy), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
