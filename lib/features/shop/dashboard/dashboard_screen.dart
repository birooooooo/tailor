import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/sample_data.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/order.dart';
import '../../../providers/orders_provider.dart';
import '../orders/new_order_screen.dart';
import '../orders/order_details_screen.dart';
import '../orders/order_tile.dart';

/// Shop home: stats, recent orders and a shortcut to create a new order.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, this.onSeeAllOrders});

  final VoidCallback? onSeeAllOrders;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<OrdersProvider>();
    final recent = provider.orders.take(4).toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            _header(context, t),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => showNewOrderSheet(context),
              icon: const Icon(Icons.add_circle_outline),
              label: Text(t.newOrder),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.pending_actions,
                    label: t.statActiveOrders,
                    value: Fmt.number(provider.activeCount),
                    color: const Color(0xFF2A6FDB),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    icon: Icons.payments_outlined,
                    label: t.statMonthlyIncome,
                    value: Fmt.number(provider.monthlyIncome),
                    color: const Color(0xFF2E7D4F),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    icon: Icons.assignment_return_outlined,
                    label: t.statReturns,
                    value: Fmt.number(provider.returnsCount),
                    color: const Color(0xFFC0392B),
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
            const SizedBox(height: 8),
            if (recent.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: EmptyState(text: t.noOrders),
              )
            else
              ...recent.map(
                (o) => OrderTile(
                  order: o,
                  onTap: () => _openOrder(context, o),
                ),
              ),
            const SizedBox(height: 20),
            _announcement(t),
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
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFF14213D),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: const Text(
            'ش',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
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
                  color: Color(0xFF5A5A66),
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                SampleData.shopName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none),
        ),
      ],
    );
  }

  Widget _announcement(AppLocalizations t) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF14213D), Color(0xFF2A3A5E)],
        ),
        borderRadius: BorderRadius.circular(20),
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
                    fontWeight: FontWeight.w700,
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
                    backgroundColor: const Color(0xFFC8A24A),
                    foregroundColor: const Color(0xFF0B132B),
                    minimumSize: const Size(0, 42),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                  child: Text(t.viewUpdates),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.campaign_outlined, color: Colors.white24, size: 64),
        ],
      ),
    );
  }
}
