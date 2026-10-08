import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../models/shop_profile.dart';
import '../../../providers/shop_provider.dart';

/// The people working in the shop.
class StaffScreen extends StatelessWidget {
  const StaffScreen({super.key});

  Future<void> _add(BuildContext context, ShopProvider shop) async {
    final name = TextEditingController();
    final role = TextEditingController();
    final phone = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('کارمەندی نوێ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'ناو'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: role,
              decoration: const InputDecoration(
                labelText: 'ئەرک (بڕین / دوورین…)',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'ژمارەی مۆبایل'),
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
    if (ok == true && name.text.trim().isNotEmpty) {
      shop.update(
        shop.profile.copyWith(
          staff: [
            ...shop.profile.staff,
            StaffMember(
              name: name.text.trim(),
              role: role.text.trim(),
              phone: phone.text.trim(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final staff = shop.profile.staff;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('کارمەندەکان')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context, context.read<ShopProvider>()),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('زیادکردن'),
      ),
      body: staff.isEmpty
          ? const EmptyState(
              text: 'هێشتا کارمەند زیاد نەکراوە',
              icon: Icons.people_outline,
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
              itemCount: staff.length,
              itemBuilder: (_, i) {
                final m = staff[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SoftCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.accentSoft,
                          child: Text(
                            m.name.isEmpty ? '؟' : m.name.characters.first,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (m.role.isNotEmpty || m.phone.isNotEmpty)
                                Text(
                                  [
                                    m.role,
                                    m.phone,
                                  ].where((s) => s.isNotEmpty).join(' • '),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: AppColors.error,
                          ),
                          onPressed: () => shop.update(
                            shop.profile.copyWith(
                              staff: [...staff]..removeAt(i),
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
