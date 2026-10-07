import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/order.dart';
import '../../../providers/orders_provider.dart';

/// Full details of one order: status control, measurements, money and notes.
class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key, required this.orderId});

  final String orderId;

  static const List<OrderStatus> _flow = [
    OrderStatus.pending,
    OrderStatus.accepted,
    OrderStatus.measured,
    OrderStatus.cutting,
    OrderStatus.stitching,
    OrderStatus.trial,
    OrderStatus.ready,
    OrderStatus.delivered,
  ];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<OrdersProvider>();
    final order = provider.byId(orderId);

    if (order == null) {
      return Scaffold(appBar: AppBar(), body: EmptyState(text: t.noOrders));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${t.orderLabel} #${order.id}'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          _customerCard(t, order),
          const SizedBox(height: 18),
          _progress(context, t, provider, order),
          const SizedBox(height: 18),
          ...order.items.expand(_itemSection),
          const SizedBox(height: 6),
          _costCard(t, order),
          const SizedBox(height: 16),
          _payments(context, t, order),
          const SizedBox(height: 16),
          _notes(context, t, order),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- customer

  Widget _customerCard(AppLocalizations t, Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                child: Text(
                  order.customer.name.characters.first,
                  style: const TextStyle(
                    color: AppColors.primary,
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
                      order.customer.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${t.phoneLabel}: ${order.customer.phone}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              StatusChip(order.status),
            ],
          ),
          const Divider(height: 26),
          Row(
            children: [
              Expanded(
                child: _dateBox(
                  t.orderDate,
                  Fmt.shortDate(order.createdAt),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _dateBox(
                  t.pickupDate,
                  Fmt.shortDate(order.dueDate),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dateBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- progress

  Widget _progress(
    BuildContext context,
    AppLocalizations t,
    OrdersProvider provider,
    Order order,
  ) {
    final current = order.status.step;
    final isActive = order.status.isActive;
    final canAdvance = isActive && current < _flow.length - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: SectionHeader(title: t.progressTitle)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: List.generate(_flow.length, (i) {
              final done = i <= current;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: done
                          ? order.status.color
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Text(
            order.status.ku,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: order.status.color,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (canAdvance)
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => provider.updateStatus(
                        order.id, _flow[current + 1]),
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: Text(
                        '${t.nextStage}: ${_flow[current + 1].ku}'),
                  ),
                ),
              if (canAdvance && isActive) const SizedBox(width: 10),
              if (isActive)
                OutlinedButton(
                  onPressed: () => provider.updateStatus(
                      order.id, OrderStatus.cancelled),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                  child: Text(t.cancelOrder),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ items

  List<Widget> _itemSection(OrderItem item) {
    return [
      const SizedBox(height: 4),
      SectionHeader(title: item.garment),
      const SizedBox(height: 10),
      PhotoBox(
        imageUrl: item.imageUrl,
        height: 170,
        label: 'وێنەی حەقی',
        icon: Icons.image_outlined,
      ),
      const SizedBox(height: 12),
      if (item.style != null) ...[
        _kvText('شێواز', item.style!),
        const SizedBox(height: 12),
      ],
      ...item.measurements.map(_measureSet),
      const SizedBox(height: 8),
    ];
  }

  Widget _measureSet(MeasurementSet set) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            set.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: set.fields
                .map((f) => _MeasureBox(label: f.label, value: f.value))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _kvText(String k, String v) {
    return Row(
      children: [
        Text(
          '$k: ',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        Expanded(
          child: Text(
            v,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------- money

  Widget _costCard(AppLocalizations t, Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: t.costSummary),
          const SizedBox(height: 12),
          _moneyRow(t.totalLabel, Fmt.currency(order.subtotal)),
          if (order.discount > 0)
            _moneyRow(
              t.discountLabel,
              '- ${Fmt.currency(order.discount)}',
              color: AppColors.error,
            ),
          _moneyRow(t.advanceLabel, Fmt.currency(order.paid),
              color: AppColors.success),
          const Divider(height: 22),
          _moneyRow(
            t.remainingLabel,
            Fmt.currency(order.remaining),
            bold: true,
            color: order.remaining > 0 ? AppColors.accent : AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _moneyRow(
    String label,
    String value, {
    bool bold = false,
    Color? color,
  }) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
      fontSize: bold ? 16 : 14,
      color: color ?? AppColors.textPrimary,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }

  Widget _payments(BuildContext context, AppLocalizations t, Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: t.advanceLabel,
            actionText: t.recordPayment,
            onAction: () => _recordPayment(context, t, order),
          ),
          const SizedBox(height: 6),
          ...order.payments.map(
            (p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 18, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${p.method} • ${Fmt.shortDate(p.date)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    Fmt.currency(p.amount),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _notes(BuildContext context, AppLocalizations t, Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: t.tailorNotes,
            actionText: t.saveLabel,
            onAction: () => _addNote(context, t, order),
          ),
          const SizedBox(height: 6),
          if (order.notes.isEmpty)
            Text(
              t.notesLabel,
              style: const TextStyle(color: AppColors.textMuted),
            )
          else
            ...order.notes.map(
              (n) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.circle,
                        size: 8, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        n.text,
                        style: const TextStyle(fontSize: 13, height: 1.6),
                      ),
                    ),
                    Text(
                      Fmt.shortDate(n.date),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
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

  // ----------------------------------------------------------------- dialogs

  Future<void> _recordPayment(
    BuildContext context,
    AppLocalizations t,
    Order order,
  ) async {
    final controller = TextEditingController();
    final amount = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.recordPayment),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: Fmt.number(order.remaining),
            labelText: t.priceLabel,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('پاشگەزبوونەوە'),
          ),
          FilledButton(
            onPressed: () {
              final v = int.tryParse(controller.text);
              Navigator.pop(ctx, v);
            },
            child: Text(t.saveLabel),
          ),
        ],
      ),
    );
    if (amount != null && amount > 0 && context.mounted) {
      context.read<OrdersProvider>().addPayment(order.id, amount);
    }
  }

  Future<void> _addNote(
    BuildContext context,
    AppLocalizations t,
    Order order,
  ) async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.tailorNotes),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(labelText: t.notesLabel),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('پاشگەزبوونەوە'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(t.saveLabel),
          ),
        ],
      ),
    );
    if (text != null && text.isNotEmpty && context.mounted) {
      context.read<OrdersProvider>().addNote(order.id, text);
    }
  }
}

class _MeasureBox extends StatelessWidget {
  const _MeasureBox({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value == value.roundToDouble()
                    ? value.toInt().toString()
                    : value.toString(),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 3),
              const Text(
                'سم',
                style: TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
