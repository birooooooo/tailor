import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/brand_loader.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/locale_provider.dart';
import '../../../providers/shop_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../services/auth_service.dart';
import '../../auth/shop_login_screen.dart';
import '../profile/about_screen.dart';
import '../profile/measurements_screen.dart';
import '../profile/services_screen.dart';
import '../profile/shop_info_screen.dart';
import '../profile/staff_screen.dart';
import '../profile/styles_screen.dart';
import '../profile/subscription_screen.dart';

class ShopSettingsScreen extends StatelessWidget {
  const ShopSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = context.watch<ThemeProvider>();
    final auth = context.watch<AuthService>();
    final shop = context.watch<ShopProvider>();
    final locale = context.watch<LocaleProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(t.navSettings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _accountTile(context, auth, shop),
          const SizedBox(height: 10),
          _tile(
            context,
            Icons.workspace_premium_outlined,
            'بەشداریکردن',
            () => _push(context, const SubscriptionScreen()),
            trailing: shop.profile.hasActiveSubscription
                ? 'چالاک'
                : 'چالاک نییە',
          ),
          const SizedBox(height: 10),
          _themeTile(context, theme),
          const SizedBox(height: 10),
          _tile(
            context,
            Icons.storefront_outlined,
            'زانیاری دوکان',
            () => _push(context, const ShopInfoScreen()),
          ),
          _tile(
            context,
            Icons.design_services_outlined,
            'خزمەتگوزاری و نرخ',
            () => _push(context, const ServicesScreen()),
          ),
          _tile(
            context,
            Icons.style_outlined,
            'شێوازەکان',
            () => _push(context, const StylesScreen()),
            trailing: '${shop.styles.length}',
          ),
          _tile(
            context,
            Icons.straighten_outlined,
            'پێوانەکان',
            () => _push(context, const MeasurementsScreen()),
          ),
          _tile(
            context,
            Icons.people_outline,
            'کارمەندان',
            () => _push(context, const StaffScreen()),
          ),
          _tile(
            context,
            Icons.language_outlined,
            t.language,
            () => _pickLanguage(context, locale),
            trailing: _languageName(locale.locale.languageCode),
          ),
          _tile(
            context,
            Icons.payments_outlined,
            'دراو',
            () => _currencyInfo(context),
            trailing: 'IQD',
          ),
          _tile(
            context,
            Icons.info_outline,
            'دەربارە',
            () => _push(context, const AboutScreen()),
            trailing: 'v1.0.0',
          ),
          const SizedBox(height: 10),
          _logoutTile(context, auth),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  String _languageName(String code) {
    switch (code) {
      case 'ar':
        return 'عەرەبی';
      case 'en':
        return 'ئینگلیزی';
      default:
        return 'کوردی';
    }
  }

  Future<void> _pickLanguage(
    BuildContext context,
    LocaleProvider locale,
  ) async {
    final code = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('زمان هەڵبژێرە'),
        children: [
          for (final e in const [
            ('ku', 'کوردی'),
            ('ar', 'عەرەبی'),
            ('en', 'ئینگلیزی'),
          ])
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, e.$1),
              child: Row(
                children: [
                  Icon(
                    locale.locale.languageCode == e.$1
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(e.$2),
                ],
              ),
            ),
        ],
      ),
    );
    if (code != null) await locale.setLocale(code);
  }

  Future<void> _currencyInfo(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('دراو'),
        content: const Text(
          'بەرنامەکە بە دیناری عێراقی (IQD) کار دەکات.\nنرخەکان بە د.ع پیشان دەدرێن.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('باشە'),
          ),
        ],
      ),
    );
  }

  Widget _accountTile(
    BuildContext context,
    AuthService auth,
    ShopProvider shop,
  ) {
    final u = auth.user;
    final name = shop.profile.shopName.isNotEmpty
        ? shop.profile.shopName
        : (u?.displayName ?? 'میوان');
    final sub = (u?.email.isNotEmpty ?? false)
        ? u!.email
        : (u?.phone.isNotEmpty ?? false)
        ? u!.phone
        : 'حەسابی ناوخۆیی';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.brand,
        borderRadius: BorderRadius.circular(AppColors.rMd),
        boxShadow: AppColors.shadow(opacity: 0.28),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.storefront_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _logoutTile(BuildContext context, AuthService auth) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppColors.rSm),
        boxShadow: AppColors.softShadow,
      ),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.rSm),
        child: ListTile(
          leading: Icon(Icons.logout_rounded, color: AppColors.error),
          title: Text(
            'چوونەدەرەوە',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.error,
            ),
          ),
          onTap: () async {
            await runWithBrandLoader(context, () => auth.signOut());
            if (!context.mounted) return;
            // Clear the whole stack and go back to the login page.
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const ShopLoginScreen()),
              (route) => false,
            );
          },
        ),
      ),
    );
  }

  Widget _themeTile(BuildContext context, ThemeProvider theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppColors.rSm),
        boxShadow: AppColors.softShadow,
      ),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.rSm),
        child: SwitchListTile(
          value: theme.isDark,
          onChanged: (v) => theme.setDark(v),
          secondary: Icon(
            theme.isDark ? Icons.dark_mode : Icons.light_mode,
            color: AppColors.primary,
          ),
          title: Text(
            'دۆخی تاریک',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: const Text('ڕووکاری تاریک بۆ شەوان'),
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    String? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppColors.rSm),
        boxShadow: AppColors.softShadow,
      ),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.rSm),
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon, color: AppColors.primary),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailing != null)
                Text(trailing, style: TextStyle(color: AppColors.textMuted)),
              const SizedBox(width: 4),
              Icon(Icons.chevron_left, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
