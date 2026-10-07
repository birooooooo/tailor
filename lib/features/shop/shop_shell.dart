import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/animations.dart';
import '../../l10n/generated/app_localizations.dart';
import 'customers/customers_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'orders/new_order_screen.dart';
import 'orders/orders_screen.dart';
import 'reports/reports_screen.dart';

/// The tailor shop side of the app: floating bottom navigation with a
/// morphing centre "+" button. Pages are created once and kept alive.
class ShopShell extends StatefulWidget {
  const ShopShell({super.key});

  @override
  State<ShopShell> createState() => _ShopShellState();
}

class _ShopShellState extends State<ShopShell> {
  int _index = 0;
  bool _fabOpen = false;

  void _goOrders() => setState(() => _index = 1);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    // Rebuild (and pick up new colours) whenever the theme changes.
    final pages = [
      DashboardScreen(onSeeAllOrders: _goOrders),
      OrdersScreen(),
      CustomersScreen(),
      ReportsScreen(),
    ];

    final items = [
      (Icons.grid_view_rounded, t.navDashboard),
      (Icons.receipt_long_rounded, t.navOrders),
      (Icons.people_alt_rounded, t.navCustomers),
      (Icons.insights_rounded, t.navReports),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBody: true,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: SizedBox(
        height: 96,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Container(
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: AppColors.shadow(opacity: 0.14),
                ),
                child: Row(
                  children: [
                    _navItem(items[0], 0),
                    _navItem(items[1], 1),
                    const SizedBox(width: 76),
                    _navItem(items[2], 2),
                    _navItem(items[3], 3),
                  ],
                ),
              ),
            ),
            if (_fabOpen)
              Positioned(
                bottom: 118,
                child: _miniAction(
                  Icons.add_circle_outline_rounded,
                  t.newOrder,
                  () {
                    setState(() => _fabOpen = false);
                    showNewOrderSheet(context);
                  },
                ),
              ),
            Positioned(
              bottom: 40,
              child: Bouncy(
                scale: 0.9,
                onTap: () => setState(() => _fabOpen = !_fabOpen),
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    gradient: AppColors.brand,
                    shape: BoxShape.circle,
                    boxShadow: AppColors.shadow(opacity: 0.35),
                  ),
                  child: AnimatedRotation(
                    turns: _fabOpen ? 0.125 : 0,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutBack,
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniAction(IconData icon, String label, VoidCallback onTap) {
    return Appear(
      duration: 280,
      slideFrom: 0.4,
      child: Bouncy(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(30),
            boxShadow: AppColors.shadow(opacity: 0.22),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem((IconData, String) item, int index) {
    final selected = _index == index;
    return Expanded(
      child: Bouncy(
        onTap: () => setState(() {
          _index = index;
          _fabOpen = false;
        }),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                color: selected ? AppColors.accentSoft : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                item.$1,
                size: 22,
                color: selected ? AppColors.primary : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.$2,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                color: selected ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
