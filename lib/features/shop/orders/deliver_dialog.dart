import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/order.dart';
import '../../../providers/orders_provider.dart';

/// Called when an order is about to be handed over (ئامادەیە → گەیەنرا).
///
/// It asks whether the customer paid everything:
///  * yes → the remaining balance is recorded as paid (no loan),
///  * no  → the amount given now is recorded and the rest becomes a قەرز loan.
///
/// Returns `true` when the order was delivered (so the caller can show the
/// invoice), or `false` when the shop cancelled the dialog.
Future<bool> deliverOrderWithPayment(
  BuildContext context,
  OrdersProvider provider,
  Order order,
) async {
  // Nothing owed: just deliver.
  if (order.remaining <= 0) {
    provider.updateStatus(order.id, OrderStatus.delivered);
    return true;
  }

  final controller = TextEditingController();
  bool? paidAll;

  final paidNow = await showDialog<int>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setLocal) => AlertDialog(
        title: const Text('گەیاندن و پارەدان'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _row('کۆی گشتی', Fmt.currency(order.payable)),
              _row('پێشتر دراوە', Fmt.currency(order.paid)),
              _row('ماوە', Fmt.currency(order.remaining), strong: true),
              const SizedBox(height: 14),
              const Text(
                'ئایا کڕیار هەموو پارەکەی دا؟',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('بەڵێ، هەمووی دا'),
                      selected: paidAll == true,
                      onSelected: (_) => setLocal(() => paidAll = true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('نەخێر'),
                      selected: paidAll == false,
                      onSelected: (_) => setLocal(() => paidAll = false),
                    ),
                  ),
                ],
              ),
              if (paidAll == false) ...[
                const SizedBox(height: 14),
                TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'ئەو پارەیەی ئێستا دا',
                    suffixText: Fmt.currencySuffix,
                    hintText: Fmt.number(order.remaining),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'ماوەکە دەبێت بە قەرز و لە لیستی قەرز دەردەکەوێت.',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('پاشگەزبوونەوە'),
          ),
          FilledButton(
            onPressed: () {
              if (paidAll == null) return;
              if (paidAll == true) {
                Navigator.pop(ctx, order.remaining);
                return;
              }
              final v = int.tryParse(controller.text) ?? 0;
              Navigator.pop(ctx, v.clamp(0, order.remaining));
            },
            child: const Text('گەیاندن'),
          ),
        ],
      ),
    ),
  );

  if (paidNow == null) return false;
  provider.deliver(order.id, paidNow: paidNow);
  return true;
}

Widget _row(String label, String value, {bool strong = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    ),
  );
}
