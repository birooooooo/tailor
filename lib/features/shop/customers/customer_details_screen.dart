import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/contact.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/orders_provider.dart';
import '../orders/order_details_screen.dart';
import '../orders/order_tile.dart';

/// One customer: their contact, totals and every order they made.
class CustomerDetailsScreen extends StatelessWidget {
  const CustomerDetailsScreen({super.key, required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<OrdersProvider>();
    final orders = provider.ordersOfCustomer(customerId);

    if (orders.isEmpty) {
      return Scaffold(appBar: AppBar(), body: EmptyState(text: t.noOrders));
    }

    final customer = orders.first.customer;
    final loan = provider.loanForCustomer(customerId);
    final paid = orders.fold<int>(0, (s, o) => s + o.paid);
    final total = orders.fold<int>(0, (s, o) => s + o.payable);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(customer.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          SoftCard(
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.accent.withValues(alpha: 0.18),
                      child: Text(
                        customer.name.characters.first,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.name,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            [
                              if (customer.phone.isNotEmpty) customer.phone,
                              if (customer.area != null &&
                                  customer.area!.isNotEmpty)
                                customer.area!,
                            ].join(' • '),
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (customer.phone.isNotEmpty)
                      Bouncy(
                        onTap: () =>
                            showContactOptions(context, customer.phone),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.call_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _stat('داواکاری', Fmt.number(orders.length)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _stat('کۆی گشتی', Fmt.currency(total)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _stat('دراوە', Fmt.currency(paid)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _stat(
                        'قەرز',
                        Fmt.currency(loan),
                        danger: loan > 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SectionHeader(title: t.ordersTitle),
          const SizedBox(height: 10),
          for (final order in orders)
            OrderTile(
              order: order,
              showCall: true,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => OrderDetailsScreen(orderId: order.id),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, {bool danger = false}) {
    final color = danger ? AppColors.error : AppColors.textPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
