import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/orders_provider.dart';
import 'order_details_screen.dart';
import 'deliver_dialog.dart';
import 'invoice_screen.dart';
import 'order_tile.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  OrderStatus? _filter;
  bool _loanOnly = false;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<OrdersProvider>();

    var list = _loanOnly
        ? provider.loanOrders
        : (_filter == null
              ? provider.sortedOrders
              : (provider.byStatus(_filter)
                    ..sort((a, b) => b.createdAt.compareTo(a.createdAt))));
    if (_query.isNotEmpty) {
      final q = _query.trim();
      list = list
          .where(
            (o) =>
                o.customer.name.contains(q) ||
                o.customer.phone.contains(q) ||
                o.id.contains(q),
          )
          .toList();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Text(
                    t.ordersTitle,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${provider.orders.length}',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: t.searchHint,
                  prefixIcon: const Icon(Icons.search, size: 20),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  AppChip(
                    label: t.filterAll,
                    selected: _filter == null && !_loanOnly,
                    onTap: () => setState(() {
                      _filter = null;
                      _loanOnly = false;
                    }),
                  ),
                  ...orderFlow.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: AppChip(
                        label: s.ku,
                        selected: _filter == s && !_loanOnly,
                        onTap: () => setState(() {
                          _filter = s;
                          _loanOnly = false;
                        }),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AppChip(
                      label: 'قەرز',
                      selected: _loanOnly,
                      onTap: () => setState(() {
                        _loanOnly = true;
                        _filter = null;
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: list.isEmpty
                  ? EmptyState(text: t.noOrders)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final order = list[i];
                        return Dismissible(
                          key: ValueKey(order.id),
                          background: _swipe(
                            AppColors.success,
                            Icons.arrow_back_rounded,
                            'قۆناغی داهاتوو',
                            Alignment.centerRight,
                          ),
                          secondaryBackground: _swipe(
                            AppColors.error,
                            Icons.close_rounded,
                            'هەڵوەشاندنەوە',
                            Alignment.centerLeft,
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              if (order.status == OrderStatus.ready) {
                                final done = await deliverOrderWithPayment(
                                  context,
                                  provider,
                                  order,
                                );
                                if (done && context.mounted) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          InvoiceScreen(orderId: order.id),
                                    ),
                                  );
                                }
                              } else {
                                provider.advanceStatus(order.id);
                              }
                            } else {
                              provider.updateStatus(
                                order.id,
                                OrderStatus.cancelled,
                              );
                            }
                            return false;
                          },
                          child: OrderTile(
                            order: order,
                            showCall: true,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    OrderDetailsScreen(orderId: order.id),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _swipe(Color color, IconData icon, String label, Alignment alignment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppColors.rMd),
      ),
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
