import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/animations.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/orders_provider.dart';
import '../../services/auth_service.dart';
import '../shop/shop_shell.dart';

/// Login / register for a tailor shop. Works with Firebase Auth when
/// configured, otherwise with a local (offline) account.
class ShopLoginScreen extends StatefulWidget {
  const ShopLoginScreen({super.key});

  @override
  State<ShopLoginScreen> createState() => _ShopLoginScreenState();
}

class _ShopLoginScreenState extends State<ShopLoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _shopName = TextEditingController();

  bool _isRegister = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _shopName.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthService>();
    final orders = context.read<OrdersProvider>();
    setState(() => _error = null);

    if (_email.text.trim().isEmpty || _password.text.length < 6) {
      setState(() => _error = 'ئیمەیڵ و وشەی نهێنی (٦ پیت) پێویستە');
      return;
    }

    try {
      if (_isRegister) {
        await auth.register(_email.text, _password.text, _shopName.text);
      } else {
        await auth.signIn(_email.text, _password.text);
      }
    } catch (e) {
      setState(() => _error = _friendly(e));
      return;
    }

    if (!mounted) return;
    orders.useShop(auth.user?.id ?? 'shop1');
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => const ShopShell()));
  }

  Future<void> _guest() async {
    final auth = context.read<AuthService>();
    final orders = context.read<OrdersProvider>();
    await auth.continueAsGuest();
    if (!mounted) return;
    orders.useShop(auth.user?.id ?? 'shop1');
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => const ShopShell()));
  }

  String _friendly(Object e) {
    final s = e.toString();
    if (s.contains('user-not-found')) return 'هیچ هەژمارێک بەم ئیمەیڵە نییە';
    if (s.contains('wrong-password')) return 'وشەی نهێنی هەڵەیە';
    if (s.contains('email-already-in-use')) return 'ئەم ئیمەیڵە بەکارهاتووە';
    if (s.contains('invalid-email')) return 'ئیمەیڵەکە دروست نییە';
    if (s.contains('network')) return 'پەیوەندی بە ئینتەرنێت نییە';
    return 'هەڵەیەک ڕوویدا، دووبارە هەوڵ بدەوە';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _header(t),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _label('ئیمەیڵ'),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(hintText: 'shop@email.com'),
                ),
                const SizedBox(height: 14),
                _label('وشەی نهێنی'),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: '••••••'),
                ),
                if (_isRegister) ...[
                  const SizedBox(height: 14),
                  _label('ناوی دوکان'),
                  TextField(
                    controller: _shopName,
                    decoration: const InputDecoration(hintText: 'ناوی دوکان'),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(AppColors.rSm),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 18,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                FilledButton(
                  onPressed: auth.isLoading ? null : _submit,
                  child: auth.isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isRegister ? 'دروستکردنی هەژمار' : 'چوونەژوورەوە',
                        ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => setState(() => _isRegister = !_isRegister),
                  child: Text(
                    _isRegister
                        ? 'هەژمارت هەیە؟ بچۆ ژوورەوە'
                        : 'هەژمارت نییە؟ دروستی بکە',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
                if (auth.supportsGuest) ...[
                  const SizedBox(height: 4),
                  const Divider(height: 26),
                  OutlinedButton.icon(
                    onPressed: _guest,
                    icon: const Icon(Icons.person_outline, size: 18),
                    label: const Text('بەردەوامبوون بێ هەژمار'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(AppLocalizations t) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E7A5F), Color(0xFF0F5B4C), Color(0xFF1E4738)],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppColors.rLg),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Appear(
                child: Icon(
                  Icons.storefront_rounded,
                  color: Colors.white,
                  size: 44,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                t.shopOwner,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'چوونەژوورەوە بۆ بەڕێوەبردنی دوکان',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    ),
  );
}
