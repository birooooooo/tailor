import 'package:flutter/material.dart';

/// Runs [action] while showing a branded full-screen loader.
///
/// The loader is guaranteed to stay visible for at least [minimum] so quick
/// logins/sign-ups/logouts still feel deliberate instead of flashing.
Future<T> runWithBrandLoader<T>(
  BuildContext context,
  Future<T> Function() action, {
  Duration minimum = const Duration(milliseconds: 1100),
}) async {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  OverlayEntry? entry;
  if (overlay != null) {
    entry = OverlayEntry(builder: (_) => const BrandLoaderOverlay());
    overlay.insert(entry);
  }

  final stopwatch = Stopwatch()..start();
  try {
    return await action();
  } finally {
    final remaining = minimum.inMilliseconds - stopwatch.elapsedMilliseconds;
    if (remaining > 0) {
      await Future<void>.delayed(Duration(milliseconds: remaining));
    }
    entry?.remove();
  }
}

/// Full-screen branded loading view (logo + spinner) used during auth changes.
class BrandLoaderOverlay extends StatefulWidget {
  const BrandLoaderOverlay({super.key});

  @override
  State<BrandLoaderOverlay> createState() => _BrandLoaderOverlayState();
}

class _BrandLoaderOverlayState extends State<BrandLoaderOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: FadeTransition(
        opacity: _c,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF49769F), Color(0xFF0A4174), Color(0xFF001D39)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1).animate(
                    CurvedAnimation(parent: _c, curve: Curves.easeOutBack),
                  ),
                  child: Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.content_cut_rounded,
                      color: Colors.white,
                      size: 46,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'تەرز',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 26),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.6,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
