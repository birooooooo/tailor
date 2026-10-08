import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../models/shop_profile.dart';
import '../../../providers/shop_provider.dart';

/// Services the shop offers, with prices.
class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  Future<void> _add(BuildContext context, ShopProvider shop) async {
    final name = TextEditingController();
    final price = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('خزمەتگوزاری نوێ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'ناو'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: price,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'نرخ',
                suffixText: Fmt.currencySuffix,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('پاشگەزبوونەوە'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('زیادکردن'),
          ),
        ],
      ),
    );
    if (result == true && name.text.trim().isNotEmpty) {
      shop.update(
        shop.profile.copyWith(
          services: [
            ...shop.profile.services,
            ServiceItem(
              name: name.text.trim(),
              price: int.tryParse(price.text) ?? 0,
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final services = shop.profile.services;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('خزمەتگوزاری و نرخ')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context, context.read<ShopProvider>()),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('زیادکردن'),
      ),
      body: services.isEmpty
          ? const EmptyState(
              text: 'هێشتا خزمەتگوزاری زیاد نەکراوە',
              icon: Icons.design_services_outlined,
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
              itemCount: services.length,
              itemBuilder: (_, i) {
                final s = services[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SoftCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            s.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          Fmt.currency(s.price),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: AppColors.error,
                          ),
                          onPressed: () => shop.update(
                            shop.profile.copyWith(
                              services: [...services]..removeAt(i),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
