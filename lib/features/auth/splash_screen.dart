import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../providers/orders_provider.dart';
import '../../services/auth_service.dart';
import '../shop/shop_shell.dart';
import 'shop_login_screen.dart';

/// Animated splash: shows the brand, then goes to the shop (if logged in)
/// or to the login screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..forward();

  late final Animation<double> _logoScale = Tween<double>(
    begin: 0.6,
    end: 1,
  ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutBack));

  late final Animation<double> _fade = CurvedAnimation(
    parent: _c,
    curve: const Interval(0, 0.6, curve: Curves.easeOut),
  );

  late final Animation<double> _rise = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.2, 1, curve: Curves.easeOutCubic),
  );

  @override
  void initState() {
    super.initState();
    _next();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    await Future<void>.delayed(const Duration(milliseconds: 1900));
    if (!mounted) return;

    final auth = context.read<AuthService>();
    final orders = context.read<OrdersProvider>();

    if (auth.isLoggedIn) {
      orders.useShop(auth.user?.id ?? 'shop1');
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const ShopShell()));
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ShopLoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E7A5F), Color(0xFF0F5B4C), Color(0xFF1E4738)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              // Glowing logo
              ScaleTransition(
                scale: _logoScale,
                child: FadeTransition(
                  opacity: _fade,
                  child: Container(
                    width: 132,
                    height: 132,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.content_cut_rounded,
                      color: Colors.white,
                      size: 58,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // Name + tagline
              AnimatedBuilder(
                animation: _rise,
                builder: (context, child) => Opacity(
                  opacity: _rise.value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - _rise.value) * 18),
                    child: child,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      t.appName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.tagline,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Loading dots
              AnimatedBuilder(
                animation: _c,
                builder: (context, _) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    final phase = (_c.value * 3 - i).clamp(0.0, 1.0);
                    final glow = (phase > 0.5
                        ? 1 - (phase - 0.5) * 2
                        : phase * 2);
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.35 + glow * 0.65,
                        ),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
