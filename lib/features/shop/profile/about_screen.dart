import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../providers/shop_provider.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>().profile;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('دەربارە')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          Center(
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                gradient: AppColors.brand,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.content_cut_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'تەرز',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Center(
            child: Text(
              'دروین، بە سادەیی',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 24),
          SoftCard(
            child: Column(
              children: [
                _row('وەشان', '1.0.0'),
                const Divider(height: 20),
                _row('دوکان', shop.shopName.isEmpty ? '—' : shop.shopName),
                const Divider(height: 20),
                _row('خاوەن', shop.ownerName.isEmpty ? '—' : shop.ownerName),
                const Divider(height: 20),
                _row('مۆبایل', shop.phone.isEmpty ? '—' : shop.phone),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'ئەم بەرنامەیە بۆ دوکانی دروین دروستکراوە: داواکاری، پێوانە، پارەدان و کڕیار بە شێوەیەکی سادە بەڕێوە دەبات.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, height: 1.8),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Row(
    children: [
      Expanded(
        child: Text(label, style: TextStyle(color: AppColors.textMuted)),
      ),
      Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    ],
  );
}
