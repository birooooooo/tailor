import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/order.dart';
import '../../../providers/orders_provider.dart';

/// Bottom sheet to edit the basic info of an order: customer name/phone and
/// the pickup date.
Future<void> showEditOrderSheet(BuildContext context, Order order) async {
  final provider = context.read<OrdersProvider>();
  final name = TextEditingController(text: order.customer.name);
  final phone = TextEditingController(text: order.customer.phone);
  var due = order.dueDate;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setLocal) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 4,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'دەستکاری داواکاری #${order.id}',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: name,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'ناوی کڕیار'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'ژمارەی مۆبایل'),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: ctx,
                  initialDate: due,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setLocal(() => due = picked);
              },
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'بەرواری وەرگرتن',
                  prefixIcon: Icon(Icons.event_outlined, size: 20),
                ),
                child: Text(
                  Fmt.date(due),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                provider.editOrder(
                  order.id,
                  customerName: name.text.trim(),
                  customerPhone: phone.text.trim(),
                  dueDate: due,
                );
                Navigator.pop(ctx);
              },
              icon: const Icon(Icons.check_rounded),
              label: const Text('پاشەکەوتکردن'),
            ),
          ],
        ),
      ),
    ),
  );
}
