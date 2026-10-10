import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/animations.dart';
import '../../../providers/shop_provider.dart';

class _Plan {
  const _Plan({
    required this.id,
    required this.name,
    required this.price,
    required this.days,
    required this.perks,
    this.best = false,
  });

  final String id;
  final String name;
  final int price;
  final int days;
  final List<String> perks;
  final bool best;
}

const List<_Plan> _plans = [
  _Plan(
    id: 'monthly',
    name: 'مانگانە',
    price: 25000,
    days: 30,
    perks: ['بەڕێوەبردنی بێسنووری داواکاری', 'ڕاپۆرت و ئامارەکان', 'پشتگیری بەردەوام'],
  ),
  _Plan(
    id: 'yearly',
    name: 'ساڵانە',
    price: 250000,
    days: 365,
    best: true,
    perks: [
      'هەموو تایبەتمەندییەکانی مانگانە',
      'دوو مانگ بەخۆڕایی',
      'پیشانگەی تایبەت',
      'پشتگیری پێشەنگ',
    ],
  ),
];

/// Subscription plans for the shop manager.
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String _selected = 'yearly';

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final profile = shop.profile;
    final active = profile.hasActiveSubscription;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('بەشداریکردن')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _statusCard(active, profile.subscribedUntil),
          const SizedBox(height: 18),
          for (final plan in _plans) ...[
            Appear(
              duration: 320,
              child: _PlanCard(
                plan: plan,
                selected: _selected == plan.id,
                onTap: () => setState(() => _selected = plan.id),
              ),
            ),
            const SizedBox(height: 14),
          ],
          const SizedBox(height: 6),
          FilledButton.icon(
            onPressed: () => _subscribe(context, shop),
            icon: const Icon(Icons.workspace_premium_rounded),
            label: Text(active ? 'نوێکردنەوەی بەشداری' : 'بەشداریکردن'),
          ),
          const SizedBox(height: 10),
          Text(
            'پارەدان ئێستا لە بەرنامەکە ئەنجام نادرێت؛ بەشداریکردنەکە بۆ نمونە لەسەر ئەم ئامێرە تۆمار دەکرێت.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _statusCard(bool active, DateTime? until) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.brand,
        borderRadius: BorderRadius.circular(AppColors.rMd),
        boxShadow: AppColors.shadow(opacity: 0.28),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              active ? Icons.verified_rounded : Icons.lock_outline_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  active ? 'بەشداری چالاک' : 'هیچ بەشدارییەکی چالاک نییە',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  active && until != null
                      ? 'بەردەوامە تا ${Fmt.shortDate(until)}'
                      : 'یەکێک لە پلانەکان هەڵبژێرە',
                  style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _subscribe(BuildContext context, ShopProvider shop) {
    final plan = _plans.firstWhere((p) => p.id == _selected);
    shop.subscribe(
      plan: plan.id,
      until: DateTime.now().add(Duration(days: plan.days)),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('بەشداریی «${plan.name}» چالاک کرا')),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final _Plan plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Bouncy(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppColors.rMd),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  plan.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (plan.best)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentSoft,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'باشترین',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  Fmt.number(plan.price),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'د.ع / ${plan.name}',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...plan.perks.map(
              (p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Icon(Icons.check_rounded, size: 16, color: AppColors.success),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        p,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
