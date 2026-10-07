import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'animations.dart';

/// A network photo with a shimmer while loading and a gradient fallback if it
/// cannot be loaded (offline, bad URL...). Never crashes on a broken image.
class RemotePhoto extends StatelessWidget {
  const RemotePhoto({
    super.key,
    required this.url,
    this.height = 160,
    this.width = double.infinity,
    this.radius = AppColors.rMd,
    this.icon = Icons.checkroom_rounded,
    this.iconSize = 40,
  });

  final String url;
  final double height;
  final double width;
  final double radius;
  final IconData icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        url,
        height: height,
        width: width,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return ShimmerBox(height: height, width: width, radius: 0);
        },
        errorBuilder: (context, error, stack) => _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(gradient: AppColors.brand),
      child: Center(
        child: Icon(icon, color: Colors.white38, size: iconSize),
      ),
    );
  }
}

/// Fires a short confetti burst over the whole screen.
void showConfetti(BuildContext context) {
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return;
  late OverlayEntry entry;
  entry = OverlayEntry(builder: (_) => _Confetti(onDone: () => entry.remove()));
  overlay.insert(entry);
}

class _Confetti extends StatefulWidget {
  const _Confetti({required this.onDone});

  final VoidCallback onDone;

  @override
  State<_Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<_Confetti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  );

  late final List<_Piece> _pieces = _build();

  @override
  void initState() {
    super.initState();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onDone();
    });
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  List<_Piece> _build() {
    final rnd = math.Random(7);
    const colors = [
      Color(0xFF6D5BFF),
      Color(0xFFA855F7),
      Color(0xFFCBDD3C),
      Color(0xFF34D399),
      Color(0xFFFBBF24),
      Color(0xFFFB7185),
    ];
    return List.generate(70, (_) {
      return _Piece(
        x: rnd.nextDouble(),
        speed: 0.7 + rnd.nextDouble() * 0.8,
        size: 6 + rnd.nextDouble() * 8,
        color: colors[rnd.nextInt(colors.length)],
        angle: rnd.nextDouble() * math.pi,
        spin: (rnd.nextDouble() - 0.5) * 8,
        drift: (rnd.nextDouble() - 0.5) * 0.3,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(_pieces, Curves.easeIn.transform(_c.value)),
        ),
      ),
    );
  }
}

class _Piece {
  const _Piece({
    required this.x,
    required this.speed,
    required this.size,
    required this.color,
    required this.angle,
    required this.spin,
    required this.drift,
  });

  final double x;
  final double speed;
  final double size;
  final Color color;
  final double angle;
  final double spin;
  final double drift;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.t);

  final List<_Piece> pieces;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in pieces) {
      final progress = (t * p.speed).clamp(0.0, 1.0);
      final y = -0.15 + progress * 1.25;
      final dx =
          (p.x + math.sin(progress * 6 + p.angle) * p.drift) * size.width;
      final dy = y * size.height;
      final opacity = (1 - progress).clamp(0.0, 1.0);
      paint.color = p.color.withValues(alpha: opacity);

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(p.angle + p.spin * t);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.6,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
