import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/brand_loader.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/orders_provider.dart';
import '../../providers/shop_provider.dart';
import '../../services/auth_service.dart';
import '../../models/shop_profile.dart';
import '../shop/shop_shell.dart';

/// Login / register for a tailor shop. Works with Firebase Auth when
/// configured, otherwise with local accounts (offline).
class ShopLoginScreen extends StatefulWidget {
  const ShopLoginScreen({super.key});

  @override
  State<ShopLoginScreen> createState() => _ShopLoginScreenState();
}

class _ShopLoginScreenState extends State<ShopLoginScreen> {
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _shopName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();

  bool _isRegister = false;
  String? _error;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    _name.dispose();
    _shopName.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    super.dispose();
  }

  String _friendly(Object e) {
    final code = e is AuthException ? e.code : e.toString();
    switch (code) {
      case 'user-not-found':
        return 'هیچ هەژمارێک بەم زانیارییە نەدۆزرایەوە';
      case 'wrong-password':
        return 'وشەی نهێنی هەڵەیە';
      case 'email-already-in-use':
        return 'ئەم ئیمەیڵ یان ژمارە بەکارهاتووە';
      case 'invalid-email':
        return 'ئیمەیڵەکە دروست نییە';
      case 'weak-password':
        return 'وشەی نهێنی زۆر لاوازە (٦ پیت بە کەمترین)';
      case 'network-request-failed':
      case 'network':
        return 'پەیوەندی بە ئینتەرنێت نییە';
      default:
        return 'هەڵەیەک ڕوویدا، دووبارە هەوڵ بدەوە';
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthService>();
    final orders = context.read<OrdersProvider>();
    final shop = context.read<ShopProvider>();
    setState(() => _error = null);

    if (_isRegister) {
      if (_name.text.trim().isEmpty ||
          _shopName.text.trim().isEmpty ||
          _phone.text.trim().isEmpty ||
          !_email.text.contains('@') ||
          _password.text.length < 6) {
        setState(
          () => _error =
              'ناو، ناوی دوکان، مۆبایل، ئیمەیڵ و وشەی نهێنی (٦ پیت) پڕ بکەوە',
        );
        return;
      }
    } else {
      if (_identifier.text.trim().isEmpty || _password.text.isEmpty) {
        setState(() => _error = 'ئیمەیڵ/مۆبایل/ناو و وشەی نهێنی پێویستە');
        return;
      }
    }

    try {
      await runWithBrandLoader(context, () async {
        if (_isRegister) {
          await auth.register(
            name: _name.text,
            phone: _phone.text,
            email: _email.text,
            password: _password.text,
          );

          // A brand-new shop starts empty: fresh profile, no orders.
          await shop.clear();
          shop.update(
            ShopProfile(
              ownerName: _name.text.trim(),
              shopName: _shopName.text.trim(),
              phone: _phone.text.trim(),
              address: _address.text.trim(),
            ),
          );
          orders.clearAll();
        } else {
          await auth.signInByIdentifier(_identifier.text, _password.text);
        }
      });
    } catch (e) {
      if (!mounted) return;
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
    await runWithBrandLoader(context, () => auth.continueAsGuest());
    if (!mounted) return;
    orders.useShop(auth.user?.id ?? 'shop1');
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => const ShopShell()));
  }

  Future<void> _forgot() async {
    final controller = TextEditingController(text: _identifier.text);
    final auth = context.read<AuthService>();
    final messenger = ScaffoldMessenger.of(context);

    final id = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('وشەی نهێنی لەبیرچووە'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'ئیمەیڵ یان ژمارەی مۆبایل',
            labelText: 'هەژمارەکەت',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('پاشگەزبوونەوە'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('ناردن'),
          ),
        ],
      ),
    );

    if (id == null || id.isEmpty) return;
    try {
      await auth.resetPassword(id);
      messenger.showSnackBar(
        const SnackBar(content: Text('بەستەری گۆڕینی وشەی نهێنی نێردرا')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(_friendly(e))));
    }
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
                if (_isRegister) ...[
                  _label('ناوی خاوەن'),
                  TextField(
                    controller: _name,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(hintText: 'ناوی خاوەن'),
                  ),
                  const SizedBox(height: 14),
                  _label('ناوی دوکان'),
                  TextField(
                    controller: _shopName,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(hintText: 'ناوی دوکان'),
                  ),
                  const SizedBox(height: 14),
                  _label('ژمارەی مۆبایل'),
                  TextField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: '0770 000 0000',
                    ),
                  ),
                  const SizedBox(height: 14),
                  _label('ئیمەیڵ'),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'shop@email.com',
                    ),
                  ),
                  const SizedBox(height: 14),
                  _label('ناونیشانی دوکان'),
                  TextField(
                    controller: _address,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'شار / گەرەک / شەقام',
                    ),
                  ),
                ] else ...[
                  _label('ئیمەیڵ، مۆبایل، یان ناو'),
                  TextField(
                    controller: _identifier,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'shop@email.com / 0770… / ناوت',
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                _label('وشەی نهێنی'),
                TextField(
                  controller: _password,
                  obscureText: true,
                  onSubmitted: (_) => _submit(),
                  decoration: const InputDecoration(hintText: '••••••'),
                ),
                if (!_isRegister) ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: _forgot,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 36),
                      ),
                      child: Text(
                        'وشەی نهێنیت لەبیرچووە؟',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 10),
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
                const SizedBox(height: 20),
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
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => setState(() {
                    _isRegister = !_isRegister;
                    _error = null;
                  }),
                  child: Text(
                    _isRegister
                        ? 'هەژمارت هەیە؟ بچۆ ژوورەوە'
                        : 'هەژمارت نییە؟ دروستی بکە',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
                if (auth.supportsGuest) ...[
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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Only show a back button when there is something to go back to.
              if (Navigator.of(context).canPop()) ...[
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ] else
                const SizedBox(height: 4),
              const Appear(
                child: Icon(
                  Icons.storefront_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _isRegister ? 'دروستکردنی هەژمار' : t.shopOwner,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isRegister
                    ? 'بەخێربێی! زانیارییەکان پڕ بکەوە'
                    : 'چوونەژوورەوە بۆ بەڕێوەبردنی دوکان',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
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
