import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class CosmicVisualizer extends StatefulWidget {
  final double level; // 0.0 to 1.0
  final bool isActive;

  const CosmicVisualizer({
    super.key,
    required this.level,
    this.isActive = true,
  });

  @override
  State<CosmicVisualizer> createState() => _CosmicVisualizerState();
}

class _CosmicVisualizerState extends State<CosmicVisualizer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
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
      builder: (context, child) {
        return CustomPaint(
          painter: _CosmicPainter(
            animation: _controller.value,
            level: widget.level,
            color: CosmicTheme.accentSoftCyan,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _CosmicPainter extends CustomPainter {
  final double animation;
  final double level;
  final Color color;

  _CosmicPainter({
    required this.animation,
    required this.level,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 4;
    
    // Draw multiple overlapping circles/waves
    for (int i = 0; i < 3; i++) {
      final path = Path();
      final waveOffset = i * math.pi / 2;
      final currentRadius = radius + (level * 50 * (i + 1));
      
      for (double t = 0; t <= 2 * math.pi; t += 0.05) {
        final x = center.dx + currentRadius * math.cos(t) * (1 + 0.1 * math.sin(t * 8 + animation * 2 * math.pi + waveOffset));
        final y = center.dy + currentRadius * math.sin(t) * (1 + 0.1 * math.cos(t * 8 + animation * 2 * math.pi + waveOffset));
        
        if (t == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      
      canvas.drawPath(path, paint..color = color.withOpacity(0.3 / (i + 1)));
    }

    // Glow effect
    final glowPaint = Paint()
      ..color = color.withOpacity(0.1 + (level * 0.2))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(center, radius + (level * 30), glowPaint);
  }

  @override
  bool shouldRepaint(covariant _CosmicPainter oldDelegate) {
    return oldDelegate.animation != animation || oldDelegate.level != level;
  }
}
