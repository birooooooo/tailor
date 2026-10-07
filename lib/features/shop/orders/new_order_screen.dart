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

Future<void> showNewOrderSheet(BuildContext context) {
  return Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const NewOrderScreen()));
}

/// Create an order by hand — used for walk-in customers at the shop.
class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _style = TextEditingController();
  final _notes = TextEditingController();
  final _price = TextEditingController();
  final _discount = TextEditingController();
  final _advance = TextEditingController();

  GarmentType _garment = GarmentType.all.first;
  DateTime _due = DateTime.now().add(const Duration(days: 7));

  final Map<String, TextEditingController> _upper = {
    for (final l in const ['سینگ', 'ئێخە', 'مل', 'شان', 'باڵ', 'قۆڵ'])
      l: TextEditingController(),
  };
  final Map<String, TextEditingController> _lower = {
    for (final l in const ['درێژی شەروال', 'کەمەر', 'ملەنگ'])
      l: TextEditingController(),
  };

  @override
  void dispose() {
    for (final c in [
      _name,
      _phone,
      _style,
      _notes,
      _price,
      _discount,
      _advance,
      ..._upper.values,
      ..._lower.values,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(t.newOrder)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          SectionHeader(title: t.garmentLabel),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: GarmentType.all
                .map(
                  (g) => AppChip(
                    label: g.ku,
                    selected: _garment.id == g.id,
                    onTap: () => setState(() => _garment = g),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          SectionHeader(title: t.styleLabel),
          const SizedBox(height: 10),
          TextField(
            controller: _style,
            decoration: const InputDecoration(
              hintText: 'ستایلی سلێمانی کلاسیک',
            ),
          ),
          const SizedBox(height: 20),
          SectionHeader(title: t.measurementsUpper),
          const SizedBox(height: 10),
          _measureGrid(_upper),
          const SizedBox(height: 16),
          SectionHeader(title: t.measurementsLower),
          const SizedBox(height: 10),
          _measureGrid(_lower),
          const SizedBox(height: 20),
          SectionHeader(title: t.dueDateLabel),
          const SizedBox(height: 10),
          _dateField(t),
          const SizedBox(height: 20),
          SectionHeader(title: t.costSummary),
          const SizedBox(height: 10),
          _moneyField(_price, t.priceLabel),
          const SizedBox(height: 12),
          _moneyField(_discount, t.discountLabel),
          const SizedBox(height: 12),
          _moneyField(_advance, t.advanceLabel),
          const SizedBox(height: 20),
          SectionHeader(title: t.notesLabel),
          const SizedBox(height: 10),
          TextField(
            controller: _notes,
            maxLines: 3,
            decoration: InputDecoration(hintText: t.notesLabel),
          ),
          const SizedBox(height: 20),
          _label(t.customerNameLabel),
          TextField(
            controller: _name,
            decoration: InputDecoration(hintText: t.customerNameLabel),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(hintText: t.phoneLabel),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check_circle_outline),
            label: Text(t.saveLabel),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    ),
  );

  Widget _measureGrid(Map<String, TextEditingController> fields) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: fields.entries
          .map(
            (e) => SizedBox(
              width: 100,
              child: TextField(
                controller: e.value,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: InputDecoration(
                  labelText: e.key,
                  labelStyle: const TextStyle(fontSize: 12),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _moneyField(TextEditingController c, String label) {
    return TextField(
      controller: c,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        suffixText: Fmt.currencySuffix,
        prefixIcon: const Icon(Icons.payments_outlined, size: 20),
      ),
    );
  }

  Widget _dateField(AppLocalizations t) {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.event_outlined, size: 20),
        ),
        child: Text(
          Fmt.date(_due),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _due,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _due = picked);
  }

  void _save() {
    final t = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final name = _name.text.trim();
    final price = int.tryParse(_price.text) ?? 0;

    if (name.isEmpty || price <= 0) {
      messenger.showSnackBar(
        SnackBar(content: Text('${t.customerNameLabel} / ${t.priceLabel}')),
      );
      return;
    }

    List<MeasurementField> fields(Map<String, TextEditingController> m) => m
        .entries
        .where((e) => e.value.text.trim().isNotEmpty)
        .map(
          (e) => MeasurementField(
            label: e.key,
            value: double.tryParse(e.value.text) ?? 0,
          ),
        )
        .toList();

    final discount = int.tryParse(_discount.text) ?? 0;
    final advance = int.tryParse(_advance.text) ?? 0;

    final order = Order(
      id: context.read<OrdersProvider>().nextOrderId(),
      customer: Customer(
        id: 'c${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        phone: _phone.text.trim(),
      ),
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
      dueDate: _due,
      discount: discount,
      items: [
        OrderItem(
          garment: _garment.ku,
          style: _style.text.trim().isEmpty ? null : _style.text.trim(),
          unitPrice: price,
          measurements: [
            MeasurementSet(
              title: 'پێوانەکانی بەشی سەرەوە',
              fields: fields(_upper),
            ),
            MeasurementSet(
              title: 'پێوانەکانی بەشی خوارەوە',
              fields: fields(_lower),
            ),
          ],
        ),
      ],
      payments: advance > 0
          ? [Payment(amount: advance, date: DateTime.now())]
          : const [],
      notes: _notes.text.trim().isEmpty
          ? const []
          : [OrderNote(text: _notes.text.trim(), date: DateTime.now())],
    );

    context.read<OrdersProvider>().addOrder(order);
    Navigator.of(context).pop();
    messenger.showSnackBar(SnackBar(content: Text(t.orderSaved)));
  }
}
