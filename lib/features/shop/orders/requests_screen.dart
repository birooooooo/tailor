import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/effects.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/order.dart';
import '../../../providers/orders_provider.dart';

/// Orders waiting for the shop to accept or reject them.
class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();
    final requests = provider.pendingOrders;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text('داواکاری نوێ')),
      body: requests.isEmpty
          ? EmptyState(
              text: 'هیچ داواکارییەکی نوێ نییە',
              icon: Icons.inbox_rounded,
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              itemCount: requests.length,
              itemBuilder: (_, i) => Appear(
                delay: i * 60,
                child: _RequestCard(order: requests[i]),
              ),
            ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final item = order.items.isNotEmpty ? order.items.first : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SoftCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (item?.imageUrl != null)
                  RemotePhoto(
                    url: item!.imageUrl!,
                    height: 56,
                    width: 56,
                    radius: 16,
                    iconSize: 26,
                  )
                else
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppColors.brand,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.checkroom_rounded,
                      color: Colors.white70,
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.customer.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${t.orderLabel} #${order.id} • ${Fmt.shortDate(order.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      if (item != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          item.garment,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  Fmt.currency(order.payable),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      context.read<OrdersProvider>().updateStatus(
                        order.id,
                        OrderStatus.accepted,
                      );
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(t.orderSaved)));
                    },
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('پەسەندکردن'),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () => context.read<OrdersProvider>().updateStatus(
                    order.id,
                    OrderStatus.cancelled,
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 54),
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error),
                  ),
                  child: const Text('ڕەتکردنەوە'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
