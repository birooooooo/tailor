import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/contact.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/effects.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/order.dart';
import '../../../providers/orders_provider.dart';

/// Card used in the orders list and on the dashboard.
class OrderTile extends StatelessWidget {
  const OrderTile({
    super.key,
    required this.order,
    this.onTap,
    this.showCall = false,
  });

  final Order order;
  final VoidCallback? onTap;

  /// Shows a call button that offers phone / WhatsApp.
  final bool showCall;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final muted = order.status.isCompleted;
    final primary = muted ? AppColors.textMuted : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Bouncy(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: muted ? AppColors.surfaceMuted : AppColors.surface,
            borderRadius: BorderRadius.circular(AppColors.rMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              // Status accent bar.
              Container(
                width: 5,
                height: 54,
                decoration: BoxDecoration(
                  color: muted
                      ? AppColors.textMuted.withValues(alpha: 0.5)
                      : order.status.color,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 10),
              _thumb(order, muted),
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
                        letterSpacing: -0.2,
                        color: primary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${t.orderLabel} #${order.id}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        StatusChip(order.status, compact: true),
                        if (order.loan > 0) _loanBadge(context, order.loan),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Fmt.currency(order.payable),
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (showCall)
                    _callButton(context)
                  else
                    Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.textMuted,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loanBadge(BuildContext context, int amount) {
    return Bouncy(
      onTap: () => _settleLoan(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 12,
              color: AppColors.error,
            ),
            const SizedBox(width: 4),
            Text(
              'قەرز ${Fmt.number(amount)}',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _settleLoan(BuildContext context) async {
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

  Widget _callButton(BuildContext context) {
    return Bouncy(
      onTap: () => showContactOptions(context, order.customer.phone),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.call_rounded, size: 18, color: AppColors.primary),
      ),
    );
  }

  Widget _thumb(Order order, bool muted) {
    final url = order.items.isNotEmpty ? order.items.first.imageUrl : null;
    if (url != null) {
      final photo = RemotePhoto(
        url: url,
        height: 46,
        width: 46,
        radius: 14,
        iconSize: 22,
      );
      return muted ? Opacity(opacity: 0.6, child: photo) : photo;
    }
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        gradient: muted ? null : AppColors.brand,
        color: muted ? AppColors.border : null,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        Icons.checkroom_rounded,
        color: muted ? AppColors.textMuted : Colors.white70,
        size: 23,
      ),
    );
  }
}
