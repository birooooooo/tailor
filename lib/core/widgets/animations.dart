import 'package:flutter/material.dart';

/// Animates its child in **once** when first shown.
///
/// Unlike `flutter_animate`'s `.animate()` inside `build`, this does **not**
/// restart when the parent rebuilds (which was causing lag and flicker on the
/// dashboard every time the order list changed).
class Appear extends StatefulWidget {
  const Appear({
    super.key,
    required this.child,
    this.delay = 0,
    this.duration = 520,
    this.slideFrom = 0.10,
    this.scaleFrom = 1.0,
    this.curve = Curves.easeOutCubic,
  });

  final Widget child;
  final int delay;
  final int duration;

  /// How far below (as a fraction of the child height) it starts.
  final double slideFrom;

  /// Start scale, e.g. 0.94 for a pop-in.
  final double scaleFrom;
  final Curve curve;

  @override
  State<Appear> createState() => _AppearState();
}

class _AppearState extends State<Appear>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: widget.duration),
  );

  late final Animation<double> _curved =
      CurvedAnimation(parent: _c, curve: widget.curve);

  @override
  void initState() {
    super.initState();
    if (widget.delay == 0) {
      _c.forward();
    } else {
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curved,
      child: widget.child,
      builder: (context, child) {
        return Opacity(
          opacity: _curved.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - _curved.value) * widget.slideFrom * 120),
            child: Transform.scale(
              scale: widget.scaleFrom +
                  (1 - widget.scaleFrom) * _curved.value,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Adds a quick spring "press" scale to anything tappable.
class Bouncy extends StatefulWidget {
  const Bouncy({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.95,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  @override
  State<Bouncy> createState() => _BouncyState();
}

class _BouncyState extends State<Bouncy>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 110),
    reverseDuration: const Duration(milliseconds: 180),
  );

  late final Animation<double> _scale = Tween<double>(
    begin: 1,
    end: widget.scale,
  ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _down(_) => _c.forward();
  void _up([_]) => _c.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _down,
      onTapUp: _up,
      onTapCancel: _up,
      onTap: widget.onTap,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

/// A number that counts up from 0 the first time it appears.
class AnimatedCount extends StatelessWidget {
  const AnimatedCount({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 900),
    this.format,
  });

  final num value;
  final TextStyle? style;
  final Duration duration;
  final String Function(num value)? format;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) {
        final n = v.round();
        return Text(
          format?.call(n) ?? n.toString(),
          style: style,
        );
      },
    );
  }
}

/// A very light shimmer used for loading placeholders.
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    this.height = 16,
    this.width = double.infinity,
    this.radius = 12,
  });

  final double height;
  final double width;
  final double radius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1 + _c.value * 2, 0),
              end: Alignment(1 + _c.value * 2, 0),
              colors: const [
                Color(0xFFECEAF7),
                Color(0xFFF7F5FF),
                Color(0xFFECEAF7),
              ],
            ),
          ),
        );
      },
    );
  }
}
