import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A custom on-screen number pad.
///
/// Used instead of the system keyboard so every phone shows the same fast,
/// predictable numeric input for sizes and money.
class NumberPad extends StatelessWidget {
  const NumberPad({
    super.key,
    required this.title,
    required this.value,
    required this.onKey,
    required this.onDone,
    this.allowDecimal = true,
  });

  final String title;
  final String value;

  /// Called with a digit, `'.'`, or `'back'`.
  final ValueChanged<String> onKey;
  final VoidCallback onDone;
  final bool allowDecimal;

  @override
  Widget build(BuildContext context) {
    final keys = <String>[
      '1', '2', '3',
      '4', '5', '6',
      '7', '8', '9',
      if (allowDecimal) '.' else '', '0', 'back',
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: AppColors.shadow(opacity: 0.18),
      ),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
              child: Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    value.isEmpty ? '0' : value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: onDone,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    child: const Text('تەواو'),
                  ),
                ],
              ),
            ),
            for (int r = 0; r < 4; r++)
              Row(
                children: [
                  for (int c = 0; c < 3; c++) _key(context, keys[r * 3 + c]),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _key(BuildContext context, String k) {
    if (k.isEmpty) return const Expanded(child: SizedBox(height: 52));
    final isBack = k == 'back';
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: isBack
              ? AppColors.error.withValues(alpha: 0.10)
              : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => onKey(k),
            child: SizedBox(
              height: 52,
              child: Center(
                child: isBack
                    ? Icon(Icons.backspace_outlined, color: AppColors.error)
                    : Text(
                        k,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}