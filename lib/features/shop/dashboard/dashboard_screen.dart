import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/sample_data.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/order.dart';
import '../../../providers/orders_provider.dart';
import '../settings/shop_settings_screen.dart';
import '../orders/order_details_screen.dart';
import '../orders/order_tile.dart';

/// Shop home: a bento grid of stats, recent orders and an announcement.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, this.onSeeAllOrders});

  final VoidCallback? onSeeAllOrders;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<OrdersProvider>();
    final recent = provider.orders.take(4).toList();
    final ready = provider.byStatus(OrderStatus.ready).length;

    final tiles = <Widget>[
      _header(context, t),
      const SizedBox(height: 20),
      _heroIncome(t, provider.monthlyIncome),
      const SizedBox(height: 12),
      Row(
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
              icon: Icons.event_available_rounded,
              label: 'دەگات ئەمڕۆ',
              value: Fmt.number(provider.dueToday),
              color: AppColors.accent,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: BentoTile(
              icon: Icons.verified_rounded,
              label: 'ئامادەیە',
              value: Fmt.number(ready),
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: BentoTile(
              icon: Icons.assignment_return_rounded,
              label: t.statReturns,
              value: Fmt.number(provider.returnsCount),
              color: AppColors.error,
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
      SectionHeader(
        title: t.recentOrders,
        actionText: t.viewAll,
        onAction: onSeeAllOrders,
      ),
      const SizedBox(height: 10),
      if (recent.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: EmptyState(text: t.noOrders),
        )
      else
        ...recent.map(
          (o) => OrderTile(order: o, onTap: () => _openOrder(context, o)),
        ),
      const SizedBox(height: 16),
      _announcement(t),
    ];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
          children: [
            for (int i = 0; i < tiles.length; i++)
              (tiles[i] is SizedBox)
                  ? tiles[i]
                  : tiles[i]
                      .animate(delay: (i * 45).ms)
                      .fadeIn(duration: 380.ms, curve: Curves.easeOut)
                      .slideY(
                        begin: 0.12,
                        end: 0,
                        duration: 380.ms,
                        curve: Curves.easeOutCubic,
                      ),
          ],
        ),
      ),
    );
  }

  void _openOrder(BuildContext context, Order order) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrderDetailsScreen(orderId: order.id),
      ),
    );
  }

  Widget _header(BuildContext context, AppLocalizations t) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppColors.brand,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.shadow(),
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
                t.greeting,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
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
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
        _iconButton(Icons.notifications_none_rounded, () {}),
        const SizedBox(width: 8),
        _iconButton(Icons.settings_outlined, () => _openSettings(context)),
      ],
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ShopSettingsScreen()),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppColors.softShadow,
        ),
        child: Icon(icon, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _heroIncome(AppLocalizations t, int income) {
    return SoftCard(
      gradient: AppColors.brandGradient,
      shadowColor: AppColors.primary,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.statMonthlyIncome,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  Fmt.currency(income),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.trending_up_rounded,
                          size: 14, color: Colors.white),
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
    );
  }

  Widget _announcement(AppLocalizations t) {
    return SoftCard(
      gradient: const [Color(0xFF17142B), Color(0xFF4F46E5)],
      shadowColor: AppColors.primaryDark,
      padding: const EdgeInsets.all(18),
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
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.lime,
                    foregroundColor: const Color(0xFF17142B),
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(t.viewUpdates),
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

/// Tiny bar chart used in the income tile.
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
            AnimatedContainer(
              duration: Duration(milliseconds: 300 + i * 60),
              curve: Curves.easeOutCubic,
              width: 8,
              height: 12 + values[i] * 62,
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: i == values.length - 2 ? 1 : 0.45,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
        ],
      ),
    );
  }
}
