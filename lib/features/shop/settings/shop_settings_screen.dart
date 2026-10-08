import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/theme_provider.dart';
import '../../../services/auth_service.dart';

class ShopSettingsScreen extends StatelessWidget {
  const ShopSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = context.watch<ThemeProvider>();
    final auth = context.watch<AuthService>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(t.navSettings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _accountTile(context, auth),
          const SizedBox(height: 10),
          _themeTile(context, theme),
          const SizedBox(height: 10),
          _tile(Icons.storefront_outlined, 'زانیاری دوکان'),
          _tile(Icons.design_services_outlined, 'خزمەتگوزاری و نرخ'),
          _tile(Icons.straighten_outlined, 'پێوانەکان'),
          _tile(Icons.people_outline, 'کارمەندان'),
          _tile(Icons.language_outlined, t.language, trailing: t.kurdish),
          _tile(Icons.payments_outlined, 'دراو', trailing: 'IQD'),
          _tile(Icons.info_outline, 'دەربارە', trailing: 'v1.0.0'),
          const SizedBox(height: 10),
          _logoutTile(context, auth),
        ],
      ),
    );
  }

  Widget _accountTile(BuildContext context, AuthService auth) {
    final u = auth.user;
    final name = u?.displayName ?? 'میوان';
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.rSm),
        boxShadow: AppColors.softShadow,
      ),
      child: ListTile(
        leading: Icon(Icons.logout_rounded, color: AppColors.error),
        title: Text(
          'چوونەدەرەوە',
          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.error),
        ),
        onTap: () async {
          await auth.signOut();
          if (context.mounted) {
            Navigator.of(context).popUntil((r) => r.isFirst);
          }
        },
      ),
    );
  }

  Widget _themeTile(BuildContext context, ThemeProvider theme) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.rSm),
        boxShadow: AppColors.softShadow,
      ),
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
    );
  }

  Widget _tile(IconData icon, String title, {String? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.rSm),
        boxShadow: AppColors.softShadow,
      ),
      child: ListTile(
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
    );
  }
}
