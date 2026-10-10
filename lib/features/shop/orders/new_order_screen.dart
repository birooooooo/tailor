import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/number_pad.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/order.dart';
import '../../../providers/orders_provider.dart';
import '../../../providers/shop_provider.dart';

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
  final _fabric = TextEditingController();
  final _color = TextEditingController();
  final _finishing = TextEditingController();
  final _notes = TextEditingController();
  final _price = TextEditingController();
  final _advance = TextEditingController();

  final _styleController = FixedExtentScrollController(initialItem: 0);
  int _styleIndex = 0;

  // Custom number pad state.
  TextEditingController? _pad;
  String _padTitle = '';
  bool _padDecimal = true;
  bool _padOpen = false;

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
  final Map<String, TextEditingController> _women = {
    for (final l in const ['بەژن', 'کەمەر', 'سینگ']) l: TextEditingController(),
  };

  @override
  void dispose() {
    for (final c in [
      _name,
      _phone,
      _fabric,
      _color,
      _finishing,
      _notes,
      _price,
      _advance,
      ..._upper.values,
      ..._lower.values,
      ..._women.values,
    ]) {
      c.dispose();
    }
    _styleController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------- number pad

  void _openPad(TextEditingController c, String title, {bool decimal = true}) {
    setState(() {
      _pad = c;
      _padTitle = title;
      _padDecimal = decimal;
      _padOpen = true;
    });
  }

  void _closePad() {
    if (!_padOpen) return;
    setState(() => _padOpen = false);
  }

  void _padKey(String k) {
    final c = _pad;
    if (c == null) return;
    final text = c.text;
    if (k == 'back') {
      if (text.isNotEmpty) c.text = text.substring(0, text.length - 1);
    } else if (k == '.') {
      if (!_padDecimal || text.contains('.')) return;
      c.text = text.isEmpty ? '0.' : '$text.';
    } else {
      c.text = '$text$k';
    }
    c.selection = TextSelection.collapsed(offset: c.text.length);
    setState(() {});
  }

  /// A numeric field that opens our own pad instead of the system keyboard.
  Widget _numericField(
    TextEditingController c,
    String label, {
    bool decimal = true,
    String? suffix,
    double? width,
  }) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: SizedBox(
        width: width,
        child: TextField(
          controller: c,
          // readOnly => the system keyboard never appears; onTap opens our pad.
          readOnly: true,
          showCursor: false,
          enableInteractiveSelection: false,
          onTap: () => _openPad(c, label, decimal: decimal),
          decoration: InputDecoration(
            labelText: label,
            suffixText: suffix,
            labelStyle: const TextStyle(fontSize: 12),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _padLayer() {
    if (_pad == null) return const SizedBox.shrink();
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedSlide(
        offset: _padOpen ? Offset.zero : const Offset(0, 1.2),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _padOpen ? 1 : 0,
          duration: const Duration(milliseconds: 140),
          child: IgnorePointer(
            ignoring: !_padOpen,
            child: NumberPad(
              title: _padTitle,
              value: _pad?.text ?? '',
              allowDecimal: _padDecimal,
              onKey: _padKey,
              onDone: _closePad,
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final styles = context.watch<ShopProvider>().styles;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(t.newOrder)),
      body: Stack(
        children: [
          // Tapping anywhere in the form closes the pad. Using a Listener
          // (not a competing GestureDetector) so a field tap always wins.
          Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => _closePad(),
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 8, 16, _padOpen ? 320 : 32),
              children: [
                SectionHeader(title: t.garmentLabel),
                const SizedBox(height: 10),
                // One scrollable row of garment types.
                SizedBox(
                  height: 46,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: GarmentType.all.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final g = GarmentType.all[i];
                      return Align(
                        alignment: Alignment.center,
                        child: AppChip(
                          label: g.ku,
                          selected: _garment.id == g.id,
                          onTap: () => setState(() => _garment = g),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Style wheel picker.
                SectionHeader(title: t.styleLabel),
                const SizedBox(height: 10),
                if (styles.isEmpty)
                  Text(
                    'هیچ شێوازێک نییە — لە ڕێکخستن زیاد بکە',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  )
                else
                  _styleWheel(styles),

                const SizedBox(height: 20),
                ..._measurementSections(t),

                const SizedBox(height: 20),
                SectionHeader(title: t.dueDateLabel),
                const SizedBox(height: 10),
                _dateField(t),

                const SizedBox(height: 20),
                SectionHeader(title: t.costSummary),
                const SizedBox(height: 10),
                _numericField(
                  _price,
                  t.priceLabel,
                  decimal: false,
                  suffix: Fmt.currencySuffix,
                ),
                _numericField(
                  _advance,
                  t.advanceLabel,
                  decimal: false,
                  suffix: Fmt.currencySuffix,
                ),

                const SizedBox(height: 16),
                SectionHeader(title: 'جۆری قوماش و ڕەنگ'),
                const SizedBox(height: 10),
                TextField(
                  controller: _fabric,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'جۆری قوماش (نموونە: شاڵ، کەتان)',
                    prefixIcon: Icon(Icons.texture_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _color,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'ڕەنگی قوماش',
                    prefixIcon: Icon(Icons.palette_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _finishing,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'تەواوکاری (نموونە: دەرزی، کەندک، ڕێکخستن)',
                    prefixIcon: Icon(Icons.handyman_outlined, size: 20),
                  ),
                ),

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
                  onPressed: () => _save(styles),
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(t.saveLabel),
                ),
              ],
            ),
          ),
          _padLayer(),
        ],
      ),
    );
  }

  Widget _styleWheel(List<String> styles) {
    final index = _styleIndex.clamp(0, styles.length - 1);
    return Container(
      height: 156,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.rMd),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: CupertinoPicker(
        itemExtent: 42,
        scrollController: _styleController,
        selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(
          background: Color(0x221E7A5F),
        ),
        onSelectedItemChanged: (i) => setState(() => _styleIndex = i),
        children: [
          for (final s in styles)
            Center(
              child: Text(
                s,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: s == styles[index]
                      ? FontWeight.w800
                      : FontWeight.w500,
                  color: s == styles[index]
                      ? AppColors.primary
                      : AppColors.textPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _measurementSections(AppLocalizations t) {
    switch (_garment.measurements) {
      case GarmentMeasurements.women:
        return [_section('پێوانەکان', _women)];
      case GarmentMeasurements.lowerOnly:
        return [_section(t.measurementsLower, _lower)];
      case GarmentMeasurements.upperLower:
        return [
          _section(t.measurementsUpper, _upper),
          const SizedBox(height: 16),
          _section(t.measurementsLower, _lower),
        ];
    }
  }

  Widget _section(String title, Map<String, TextEditingController> fields) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        const SizedBox(height: 6),
        Wrap(
          spacing: 2,
          runSpacing: 2,
          children: fields.entries
              .map(
                (e) => _numericField(e.value, e.key, width: 104),
              )
              .toList(),
        ),
      ],
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

  void _save(List<String> styles) {
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

    List<MeasurementSet> measurements() {
      switch (_garment.measurements) {
        case GarmentMeasurements.women:
          return [
            MeasurementSet(
              title: 'پێوانەکانی کراسی ئافرەتان',
              fields: fields(_women),
            ),
          ];
        case GarmentMeasurements.lowerOnly:
          return [
            MeasurementSet(title: t.measurementsLower, fields: fields(_lower)),
          ];
        case GarmentMeasurements.upperLower:
          return [
            MeasurementSet(title: t.measurementsUpper, fields: fields(_upper)),
            MeasurementSet(title: t.measurementsLower, fields: fields(_lower)),
          ];
      }
    }

    final styleName = styles.isEmpty
        ? null
        : styles[_styleIndex.clamp(0, styles.length - 1)];
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
      items: [
        OrderItem(
          garment: _garment.ku,
          style: styleName,
          unitPrice: price,
          colors: _color.text.trim().isEmpty ? const [] : [_color.text.trim()],
          fabrics: _fabric.text.trim().isEmpty
              ? const []
              : [_fabric.text.trim()],
          finishing: _finishing.text.trim().isEmpty
              ? null
              : _finishing.text.trim(),
          measurements: measurements(),
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