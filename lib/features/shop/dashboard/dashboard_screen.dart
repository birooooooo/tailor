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
import '../../../providers/shop_provider.dart';
import '../settings/shop_settings_screen.dart';
import '../orders/order_details_screen.dart';
import '../orders/order_tile.dart';
import '../orders/requests_screen.dart';

/// Shop home: an immersive gradient header + colourful bento tiles.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.onSeeAllOrders});

  final VoidCallback? onSeeAllOrders;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _scroll = ScrollController();
  bool _hideIncome = false;
  bool _collapsible = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  /// Rebuilds only when the income header should appear/disappear, not on
  /// every scroll frame.
  void _onScroll() {
    if (!_collapsible) return;
    final hide = _scroll.hasClients && _scroll.offset > 24;
    if (hide != _hideIncome) setState(() => _hideIncome = hide);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<OrdersProvider>();
    final shop = context.watch<ShopProvider>();
    final shopName = shop.profile.shopName.isNotEmpty
        ? shop.profile.shopName
        : kDefaultShopName;
    final recent = provider.homeOrders.take(4).toList();
    final ready = provider.byStatus(OrderStatus.ready).length;
    _collapsible = provider.orders.length > 5;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Fixed header. When there are many orders, the income block
          // collapses smoothly as the list scrolls.
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: ClipRect(
              child: _Header(
                greeting: t.greeting,
                shopName: shopName,
                incomeLabel: t.statMonthlyIncome,
                income: provider.monthlyIncome,
                showIncome: !_hideIncome,
                onSettings: () => _openSettings(context),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              controller: _scroll,
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
                if (provider.pendingCount > 0) ...[
                  Appear(
                    delay: 130,
                    child: _requestsCard(context, provider.pendingCount),
                  ),
                  const SizedBox(height: 20),
                ],
                Appear(
                  delay: 200,
                  child: SectionHeader(
                    title: t.recentOrders,
                    actionText: t.viewAll,
                    onAction: widget.onSeeAllOrders,
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

  Widget _requestsCard(BuildContext context, int count) {
    return Bouncy(
      onTap: () =>
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const RequestsScreen())),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.accent,
              AppColors.accent.withValues(alpha: 0.78),
            ],
          ),
          borderRadius: BorderRadius.circular(AppColors.rMd),
          boxShadow: AppColors.shadow(color: AppColors.accent, opacity: 0.32),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.30),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.inbox_rounded, color: Color(0xFF1A1F1B)),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'داواکاری نوێ',
                    style: TextStyle(
                      color: Color(0xFF1A1F1B),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'چاوەڕوانی پەسەندکردن',
                    style: TextStyle(color: Color(0xFF3A3A2A), fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
              decoration: const BoxDecoration(
                color: Color(0xFF1A1F1B),
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_left_rounded, color: Color(0xFF1A1F1B)),
          ],
        ),
      ),
    );
  }
}

/// Immersive gradient header with the month income.
class _Header extends StatelessWidget {
  const _Header({
    required this.greeting,
    required this.shopName,
    required this.incomeLabel,
    required this.income,
    required this.showIncome,
    required this.onSettings,
  });

  final String greeting;
  final String shopName;
  final String incomeLabel;
  final int income;
  final bool showIncome;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.brand,
        borderRadius: const BorderRadius.vertical(
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
                              Text(
                                shopName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _glassIcon(Icons.settings_outlined, onSettings),
                      ],
                    ),
                  ),
                  if (showIncome) ...[
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
