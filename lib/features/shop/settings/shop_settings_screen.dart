import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';

class ShopSettingsScreen extends StatelessWidget {
  const ShopSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Text(
              t.navSettings,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _tile(Icons.storefront_outlined, 'زانیاری دوکان'),
            _tile(Icons.design_services_outlined, 'خزمەتگوزاری و نرخ'),
            _tile(Icons.straighten_outlined, 'پێوانەکان'),
            _tile(Icons.people_outline, 'کارمەندان'),
            _tile(Icons.language_outlined, t.language, trailing: t.kurdish),
            _tile(Icons.payments_outlined, 'دراو', trailing: 'IQD'),
            _tile(Icons.info_outline, 'دەربارە', trailing: 'v1.0.0'),
          ],
        ),
      ),
    );
  }

  Widget _tile(IconData icon, String title, {String? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailing != null)
              Text(
                trailing,
                style: const TextStyle(color: AppColors.textMuted),
              ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_left, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
