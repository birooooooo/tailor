import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import 'customers/customers_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'orders/new_order_screen.dart';
import 'orders/orders_screen.dart';
import 'reports/reports_screen.dart';

/// The tailor shop side of the app: floating bento-style bottom navigation
/// with a centre "+" button to create a new order.
class ShopShell extends StatefulWidget {
  const ShopShell({super.key});

  @override
  State<ShopShell> createState() => _ShopShellState();
}

class _ShopShellState extends State<ShopShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    final pages = [
      DashboardScreen(onSeeAllOrders: () => setState(() => _index = 1)),
      const OrdersScreen(),
      const CustomersScreen(),
      const ReportsScreen(),
    ];

    final items = [
      (Icons.grid_view_rounded, t.navDashboard),
      (Icons.receipt_long_rounded, t.navOrders),
      (Icons.people_alt_rounded, t.navCustomers),
      (Icons.insights_rounded, t.navReports),
    ];

    return Scaffold(
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
                  boxShadow: AppColors.shadow(opacity: 0.16),
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
            Positioned(
              bottom: 40,
              child: _fab(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem((IconData, String) item, int index) {
    final selected = _index == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _index = index),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.$1,
              size: 23,
              color: selected ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(height: 3),
            Text(
              item.$2,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fab(BuildContext context) {
    return GestureDetector(
      onTap: () => showNewOrderSheet(context),
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          gradient: AppColors.brand,
          shape: BoxShape.circle,
          boxShadow: AppColors.shadow(opacity: 0.35),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
    );
  }
}
