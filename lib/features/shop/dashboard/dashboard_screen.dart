import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/sample_data.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/order.dart';
import '../../../providers/orders_provider.dart';
import '../settings/shop_settings_screen.dart';
import '../orders/order_details_screen.dart';
import '../orders/order_tile.dart';

/// Shop home: an immersive gradient header + colourful bento tiles.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, this.onSeeAllOrders});

  final VoidCallback? onSeeAllOrders;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<OrdersProvider>();
    final recent = provider.orders.take(4).toList();
    final ready = provider.byStatus(OrderStatus.ready).length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _Header(
            greeting: t.greeting,
            incomeLabel: t.statMonthlyIncome,
            income: provider.monthlyIncome,
            onSettings: () => _openSettings(context),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
              children: [
                Appear(
                  delay: 60,
                  child: Row(
                    children: [
                      Expanded(
                        child: BentoTile(
                          icon: Icons.pending_actions_rounded,
                          label: t.statActiveOrders,
                          value: Fmt.number(provider.activeCount),
                          color: AppColors.info,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: BentoTile(
                          icon: Icons.verified_rounded,
                          label: 'ئامادەیە',
                          value: Fmt.number(ready),
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Appear(
                  delay: 200,
                  child: SectionHeader(
                    title: t.recentOrders,
                    actionText: t.viewAll,
                    onAction: onSeeAllOrders,
                  ),
                ),
                const SizedBox(height: 10),
                if (recent.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: EmptyState(text: t.noOrders),
                  )
                else
                  for (int i = 0; i < recent.length; i++)
                    Appear(
                      delay: 240 + i * 60,
                      child: OrderTile(
                        order: recent[i],
                        onTap: () => _openOrder(context, recent[i]),
                      ),
                    ),
                const SizedBox(height: 16),
                Appear(delay: 480, child: _announcement(t)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openOrder(BuildContext context, Order order) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => OrderDetailsScreen(orderId: order.id)),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const ShopSettingsScreen()));
  }

  Widget _announcement(AppLocalizations t) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF17142B), Color(0xFF4F46E5)],
        ),
        borderRadius: BorderRadius.circular(AppColors.rMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.announcements,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  t.announcementBody,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.lime,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      t.viewUpdates,
                      style: const TextStyle(
                        color: Color(0xFF17142B),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.campaign_rounded, color: Colors.white24, size: 68),
        ],
      ),
    );
  }
}

/// Immersive gradient header with the month income.
class _Header extends StatelessWidget {
  const _Header({
    required this.greeting,
    required this.incomeLabel,
    required this.income,
    required this.onSettings,
  });

  final String greeting;
  final String incomeLabel;
  final int income;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6D5BFF), Color(0xFF8B5CF6), Color(0xFFA855F7)],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppColors.rLg),
        ),
      ),
      child: Stack(
        children: [
          // Real garment photo blended under the gradient.
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(AppColors.rLg),
              ),
              child: Opacity(
                opacity: 0.30,
                child: Image.network(
                  SampleData.headerImage,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) =>
                      progress == null ? child : const SizedBox.shrink(),
                  errorBuilder: (context, error, stack) =>
                      const SizedBox.shrink(),
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
              child: Column(
                children: [
                  Appear(
                    duration: 420,
                    slideFrom: -0.06,
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'ش',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 19,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                greeting,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                SampleData.shopName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _glassIcon(Icons.notifications_none_rounded, () {}),
                        const SizedBox(width: 8),
                        _glassIcon(Icons.settings_outlined, onSettings),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Appear(
                    delay: 90,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                incomeLabel,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              AnimatedCount(
                                value: income,
                                format: Fmt.currency,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.8,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.trending_up_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'بەردەوام زیاد دەکات',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        const _MiniBars(
                          values: [0.4, 0.65, 0.5, 0.8, 0.6, 0.95, 0.75],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassIcon(IconData icon, VoidCallback onTap) {
    return Bouncy(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

/// Tiny bar chart used in the income header.
class _MiniBars extends StatelessWidget {
  const _MiniBars({required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 74,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (int i = 0; i < values.length; i++)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 12 + values[i] * 62),
              duration: Duration(milliseconds: 500 + i * 70),
              curve: Curves.easeOutCubic,
              builder: (context, h, _) => Container(
                width: 8,
                height: h,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: i == values.length - 2 ? 1 : 0.45,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
