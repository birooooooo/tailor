import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../providers/shop_provider.dart';

/// The measurement fields this shop uses (ئێخە، مل، شان …).
class MeasurementsScreen extends StatelessWidget {
  const MeasurementsScreen({super.key});

  Future<void> _add(BuildContext context, ShopProvider shop) async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('پێوانەی نوێ'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'ناوی پێوانە'),
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
    if (ok == true && controller.text.trim().isNotEmpty) {
      shop.update(
        shop.profile.copyWith(
          measurementFields: [
            ...shop.profile.measurementFields,
            controller.text.trim(),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final fields = shop.profile.measurementFields;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('پێوانەکان')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context, context.read<ShopProvider>()),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('زیادکردن'),
      ),
      body: fields.isEmpty
          ? const EmptyState(
              text: 'هێشتا پێوانە زیاد نەکراوە',
              icon: Icons.straighten_outlined,
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
              itemCount: fields.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SoftCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.straighten_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          fields[i],
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                        ),
                        onPressed: () => shop.update(
                          shop.profile.copyWith(
                            measurementFields: [...fields]..removeAt(i),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
