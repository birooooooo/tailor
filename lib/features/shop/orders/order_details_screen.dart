import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/contact.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/effects.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/order.dart';
import '../../../providers/orders_provider.dart';
import 'deliver_dialog.dart';
import 'edit_order_sheet.dart';
import 'invoice_screen.dart';

/// Full details of one order. The first card holds everything: customer,
/// dates, garment, style, fabric, colour, finishing, sizes and money.
class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<OrdersProvider>();
    final order = provider.byId(orderId);

    if (order == null) {
      return Scaffold(appBar: AppBar(), body: EmptyState(text: t.noOrders));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('${t.orderLabel} #${order.id}'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => InvoiceScreen(orderId: order.id),
              ),
            ),
            icon: const Icon(Icons.receipt_long_rounded),
          ),
          IconButton(
            onPressed: () => showContactOptions(context, order.customer.phone),
            icon: const Icon(Icons.call_rounded),
          ),
          IconButton(
            onPressed: () => showEditOrderSheet(context, order),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          _overviewCard(context, t, order),
          const SizedBox(height: 14),
          _progressCard(context, t, provider, order),
          const SizedBox(height: 14),
          _payments(context, t, order),
          const SizedBox(height: 14),
          _notes(context, t, order),
        ],
      ),
    );
  }

  Future<void> _advance(
    BuildContext context,
    OrdersProvider provider,
    Order order,
    OrderStatus next,
  ) async {
    if (next == OrderStatus.delivered) {
      final done = await deliverOrderWithPayment(context, provider, order);
      if (!context.mounted) return;
      if (done) {
        showConfetti(context);
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => InvoiceScreen(orderId: order.id)),
        );
      }
      return;
    }
    provider.updateStatus(order.id, next);
  }

  // --------------------------------------------------------------- overview

  Widget _overviewCard(BuildContext context, AppLocalizations t, Order order) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer + status.
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppColors.brand,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  order.customer.name.characters.first,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      [
                        if (order.customer.phone.isNotEmpty)
                          order.customer.phone,
                        if (order.customer.area?.isNotEmpty ?? false)
                          order.customer.area!,
                      ].join(' • '),
                      style: TextStyle(
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
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _dateBox(t.orderDate, Fmt.shortDate(order.createdAt)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _dateBox(t.pickupDate, Fmt.shortDate(order.dueDate)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 4),
          for (final item in order.items) _itemBlock(item),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _moneyRow(t.totalLabel, Fmt.currency(order.subtotal)),
          _moneyRow(t.advanceLabel, Fmt.currency(order.paid)),
          _moneyRow(
            t.remainingLabel,
            Fmt.currency(order.remaining),
            color: order.loan > 0 ? AppColors.error : AppColors.success,
            bold: true,
          ),
          if (order.loan > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 18,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'قەرز ${Fmt.currency(order.loan)}',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _settleLoan(context, order),
                icon: const Icon(Icons.price_check_rounded, size: 18),
                label: const Text('وەرگرتنی قەرز'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _itemBlock(OrderItem item) {
    final details = <Widget>[
      if (item.style?.isNotEmpty ?? false) _kv('شێواز', item.style!),
      if (item.fabrics.isNotEmpty)
        _kv('جۆری قوماش', item.fabrics.join('، ')),
      if (item.colors.isNotEmpty) _kv('ڕەنگی قوماش', item.colors.join('، ')),
      if (item.finishing?.isNotEmpty ?? false)
        _kv('تەواوکاری', item.finishing!),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (item.imageUrl != null)
                RemotePhoto(
                  url: item.imageUrl!,
                  height: 46,
                  width: 46,
                  radius: 14,
                  iconSize: 22,
                )
              else
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.checkroom_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.garment,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                Fmt.currency(item.lineTotal),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (details.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...details,
          ],
          for (final set in item.measurements) ...[
            const SizedBox(height: 12),
            Text(
              set.title,
              style: TextStyle(
                fontSize: 13.5,
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
        ],
      ),
    );
  }

  Widget _dateBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
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
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$k: ',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          Expanded(
            child: Text(
              v,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _moneyRow(String label, String value, {Color? color, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
              fontSize: bold ? 15.5 : 13.5,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- progress

  Widget _progressCard(
    BuildContext context,
    AppLocalizations t,
    OrdersProvider provider,
    Order order,
  ) {
    final current = order.status.step;
    final isActive = order.status.isActive;
    final canAdvance = isActive && current < orderFlow.length - 1;

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: t.progressTitle),
          const SizedBox(height: 14),
          _Timeline(current: current, color: order.status.color),
          const SizedBox(height: 18),
          Row(
            children: [
              if (canAdvance)
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _advance(
                      context,
                      provider,
                      order,
                      orderFlow[current + 1],
                    ),
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: Text('${t.nextStage}: ${orderFlow[current + 1].ku}'),
                  ),
                ),
              if (canAdvance) const SizedBox(width: 10),
              if (isActive)
                OutlinedButton(
                  onPressed: () =>
                      provider.updateStatus(order.id, OrderStatus.cancelled),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 54),
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error),
                  ),
                  child: Text(t.cancelOrder),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------- payments

  Widget _payments(BuildContext context, AppLocalizations t, Order order) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: t.advanceLabel,
            actionText: t.recordPayment,
            onAction: () => _recordPayment(context, t, order),
          ),
          const SizedBox(height: 8),
          if (order.payments.isEmpty)
            Text(t.notesLabel, style: TextStyle(color: AppColors.textMuted))
          else
            ...order.payments.map(
              (p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 17,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${p.method} • ${Fmt.shortDate(p.date)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      Fmt.currency(p.amount),
                      style: const TextStyle(fontWeight: FontWeight.w800),
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
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: t.tailorNotes,
            actionText: t.saveLabel,
            onAction: () => _addNote(context, t, order),
          ),
          const SizedBox(height: 8),
          if (order.notes.isEmpty)
            Text(t.notesLabel, style: TextStyle(color: AppColors.textMuted))
          else
            ...order.notes.map(
              (n) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 7),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        n.text,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.7,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      Fmt.shortDate(n.date),
                      style: TextStyle(
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

  Future<void> _settleLoan(BuildContext context, Order order) async {
    final provider = context.read<OrdersProvider>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('وەرگرتنی قەرز'),
        content: Text('${Fmt.currency(order.loan)} وەرگیرا و قەرزەکە تەواو بکرێت؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('نەخێر'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('بەڵێ'),
          ),
        ],
      ),
    );
    if (ok == true) provider.addPayment(order.id, order.loan);
  }

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

/// Vertical status timeline.
class _Timeline extends StatelessWidget {
  const _Timeline({required this.current, required this.color});

  final int current;
  final Color color;

  @override
  Widget build(BuildContext context) {
    const steps = orderFlow;
    return Column(
      children: [
        for (int i = 0; i < steps.length; i++)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: i <= current ? color : AppColors.surfaceMuted,
                      shape: BoxShape.circle,
                      boxShadow: i == current
                          ? AppColors.shadow(color: color, opacity: 0.4)
                          : null,
                    ),
                    child: Icon(
                      steps[i].icon,
                      size: 15,
                      color: i <= current ? Colors.white : AppColors.textMuted,
                    ),
                  ),
                  if (i != steps.length - 1)
                    Container(
                      width: 2.5,
                      height: 20,
                      color: i < current ? color : AppColors.border,
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  steps[i].ku,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: i == current
                        ? FontWeight.w800
                        : FontWeight.w500,
                    color: i <= current
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _MeasureBox extends StatelessWidget {
  const _MeasureBox({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value == value.roundToDouble()
                      ? value.toInt().toString()
                      : value.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  'سم',
                  style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
