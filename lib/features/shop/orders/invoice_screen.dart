import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/order.dart';
import '../../../models/shop_profile.dart';
import '../../../providers/orders_provider.dart';
import '../../../providers/shop_provider.dart';

/// A printable invoice/receipt shown after the clothes are handed over.
class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final _boundaryKey = GlobalKey();
  bool _printing = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<OrdersProvider>();
    final shop = context.watch<ShopProvider>();
    final order = provider.byId(widget.orderId);

    if (order == null) {
      return Scaffold(appBar: AppBar(), body: EmptyState(text: t.noOrders));
    }

    final shopName = shop.profile.shopName.isNotEmpty
        ? shop.profile.shopName
        : kDefaultShopName;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('پسووڵە')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          RepaintBoundary(
            key: _boundaryKey,
            child: _receipt(shop.profile, order, shopName),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('داخستن'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _printing ? null : _print,
                  icon: _printing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.print_rounded),
                  label: const Text('پرینت'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _print() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _printing = true);
    try {
      final boundary =
          _boundaryKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw Exception('no image');

      final png = data.buffer.asUint8List();
      final aspect = image.height / image.width;
      final pageWidth = 80 * PdfPageFormat.mm;

      final doc = pw.Document();
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(
            pageWidth,
            pageWidth * aspect,
            marginAll: 0,
          ),
          build: (_) => pw.Image(
            pw.MemoryImage(png),
            fit: pw.BoxFit.contain,
          ),
        ),
      );
      final bytes = await doc.save();

      if (!mounted) return;
      await Printing.layoutPdf(onLayout: (_) => bytes);
    } catch (e) {
      messenger.showSnackBar(
        const SnackBar(content: Text('پرینت سەرکەوتوو نەبوو')),
      );
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  Widget _receipt(ShopProfile shop, Order order, String shopName) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.rMd),
        boxShadow: AppColors.shadow(opacity: 0.12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _brandHeader(shopName),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'پسووڵەی داواکاری',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'ژمارە #${order.id}',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusChip(order.status),
                  ],
                ),
                const SizedBox(height: 14),
                const _DashedLine(),
                const SizedBox(height: 14),
                _meta('ناوی کڕیار', order.customer.name),
                if (order.customer.phone.isNotEmpty)
                  _meta('ژمارەی مۆبایل', order.customer.phone),
                if (order.customer.area != null &&
                    order.customer.area!.isNotEmpty)
                  _meta('ناوچە', order.customer.area!),
                _meta('بەرواری تۆمارکردن', Fmt.shortDate(order.createdAt)),
                _meta('بەرواری گەیاندن', Fmt.shortDate(order.dueDate)),
                const SizedBox(height: 14),
                const _DashedLine(),
                const SizedBox(height: 14),
                ...order.items.map(_itemRow),
                const SizedBox(height: 8),
                const _DashedLine(),
                const SizedBox(height: 14),
                _moneyRow('کۆی گشتی', Fmt.currency(order.subtotal)),
                if (order.discount > 0)
                  _moneyRow('داشکاندن', '- ${Fmt.currency(order.discount)}'),
                _moneyRow('پێشتر دراوە', Fmt.currency(order.paid)),
                const SizedBox(height: 8),
                _remainingRow(order),
                const SizedBox(height: 16),
                const _DashedLine(),
                const SizedBox(height: 14),
                _footer(shop),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _brandHeader(String shopName) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF49769F), Color(0xFF0A4174)],
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppColors.rMd),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.content_cut_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shopName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'خەیات و بەرگدرو',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _meta(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
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

  Widget _itemRow(OrderItem item) {
    final details = <String>[
      if (item.style != null && item.style!.isNotEmpty) item.style!,
      if (item.fabrics.isNotEmpty) 'قوماش: ${item.fabrics.join('، ')}',
      if (item.colors.isNotEmpty) 'ڕەنگ: ${item.colors.join('، ')}',
      if (item.finishing != null && item.finishing!.isNotEmpty)
        'تەواوکاری: ${item.finishing}',
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.checkroom_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.garment,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (details.isNotEmpty)
                      Text(
                        details.join(' • '),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Fmt.currency(item.lineTotal),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (item.quantity > 1)
                    Text(
                      '${item.quantity} × ${Fmt.number(item.unitPrice)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                ],
              ),
            ],
          ),
          ..._measureChips(item),
        ],
      ),
    );
  }

  List<Widget> _measureChips(OrderItem item) {
    final chips = <Widget>[];
    for (final set in item.measurements) {
      for (final f in set.fields) {
        chips.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${f.label}: ${f.value == f.value.roundToDouble() ? f.value.toInt() : f.value}',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ),
        );
      }
    }
    if (chips.isEmpty) return const [];
    return [
      const SizedBox(height: 8),
      Wrap(spacing: 6, runSpacing: 6, children: chips),
    ];
  }

  Widget _moneyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
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
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _remainingRow(Order order) {
    final isLoan = order.loan > 0;
    final color = isLoan ? AppColors.error : AppColors.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            isLoan
                ? Icons.account_balance_wallet_outlined
                : Icons.verified_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isLoan ? 'قەرز (ماوە)' : 'تەواو دراوە',
              style: TextStyle(fontWeight: FontWeight.w700, color: color),
            ),
          ),
          Text(
            isLoan ? Fmt.currency(order.remaining) : '0 ${Fmt.currencySuffix}',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer(ShopProfile shop) {
    final contact = [
      if (shop.phone.isNotEmpty) shop.phone,
      if (shop.address.isNotEmpty) shop.address,
    ].join(' • ');

    return Column(
      children: [
        Text(
          'سوپاس بۆ مامەڵەکردن لەگەڵمان',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'هیوادارین جلوبەرگەکە لەبت بەخێر بێت',
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        if (contact.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            contact,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
        const SizedBox(height: 14),
        const _Barcode(),
      ],
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1.4,
      width: double.infinity,
      child: CustomPaint(painter: _DashedPainter(AppColors.border)),
    );
  }
}

class _DashedPainter extends CustomPainter {
  _DashedPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4;
    const dash = 6.0;
    const gap = 5.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Decorative barcode strip at the bottom of the receipt.
class _Barcode extends StatelessWidget {
  const _Barcode();

  static const List<int> _bars = [
    2, 1, 3, 1, 1, 2, 1, 4, 1, 2, 1, 1, 3, 2, 1, 1, 2, 3, 1, 1, 2, 1, 3, 1,
    2, 1, 1, 2, 4, 1, 1, 2, 1,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final w in _bars)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Container(
                width: w.toDouble(),
                color: AppColors.textPrimary.withValues(alpha: 0.75),
              ),
            ),
        ],
      ),
    );
  }
}
