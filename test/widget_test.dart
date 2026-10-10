import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tailor_app/core/constants/app_constants.dart';
import 'package:tailor_app/core/widgets/number_pad.dart';
import 'package:tailor_app/main.dart';
import 'package:tailor_app/providers/orders_provider.dart';

/// Starts the app and waits for the splash to finish (it shows the login
/// screen when nobody is logged in).
Future<void> _boot(WidgetTester tester) async {
  await tester.pumpWidget(const TailorApp());
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

/// On the login screen, continues without an account (offline mode).
Future<void> _enterShop(WidgetTester tester) async {
  final guest = find.text('بەردەوامبوون بێ هەژمار');
  if (guest.evaluate().isNotEmpty) {
    await tester.ensureVisible(guest);
    await tester.pumpAndSettle();
    await tester.tap(guest);
    await tester.pumpAndSettle();
  }
}

/// Whether the custom number pad is currently visible (not slid away).
bool _padVisible(WidgetTester tester) {
  final finder = find.ancestor(
    of: find.byType(NumberPad),
    matching: find.byType(IgnorePointer),
  );
  return !tester.widget<IgnorePointer>(finder.first).ignoring;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Splash shows the brand, then the login page', (tester) async {
    await tester.pumpWidget(const TailorApp());
    expect(find.text('تەرز'), findsOneWidget); // splash brand

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('چوونەژوورەوە'), findsOneWidget); // login button
    expect(find.text('وشەی نهێنیت لەبیرچووە؟'), findsOneWidget); // forgot
    expect(find.text('هەژمارت نییە؟ دروستی بکە'), findsOneWidget); // register
  });

  testWidgets('Shop dashboard shows greeting and stats', (tester) async {
    await _boot(tester);
    await _enterShop(tester);

    expect(find.text('بەخێربێیتەوە'), findsOneWidget); // greeting
    expect(find.text('داهاتی ئەم مانگە'), findsOneWidget); // hero tile
    expect(find.text('ئامادەیە'), findsOneWidget); // bento tile
  });

  testWidgets('Opening an order from the orders tab shows its details', (
    tester,
  ) async {
    await _boot(tester);
    await _enterShop(tester);

    // Switch to the orders tab via the bottom navigation.
    await tester.tap(find.text('داواکارییەکان'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('داریا کاروان').first);
    await tester.pumpAndSettle();

    expect(find.textContaining('#8842'), findsOneWidget);
    expect(find.text('کۆی گشتی'), findsWidgets);
  });

  testWidgets('Order details opens a designed invoice', (tester) async {
    await _boot(tester);
    await _enterShop(tester);

    await tester.tap(find.text('داواکارییەکان'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('داریا کاروان').first);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.receipt_long_rounded));
    await tester.pumpAndSettle();

    expect(find.text('پسووڵەی داواکاری'), findsOneWidget);
    expect(find.text('کۆی گشتی'), findsWidgets);
    expect(find.textContaining('ژمارە #8842'), findsOneWidget);
  });

  testWidgets('Tapping a size field opens the custom number pad', (
    tester,
  ) async {
    await _boot(tester);
    await _enterShop(tester);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    final sizeField = find.widgetWithText(TextField, 'کەمەر');
    expect(sizeField, findsOneWidget);
    await tester.ensureVisible(sizeField);
    await tester.pumpAndSettle();

    await tester.tap(sizeField);
    await tester.pumpAndSettle();

    // The pad is open (its done button is showing).
    expect(_padVisible(tester), isTrue);

    // A tapped digit lands in the field.
    await tester.tap(find.text('7'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, '7'), findsOneWidget);

    // Tapping anywhere else closes the pad.
    await tester.tapAt(const Offset(200, 120));
    await tester.pumpAndSettle();
    expect(_padVisible(tester), isFalse);
  });

  testWidgets('Editing an order updates the customer name', (tester) async {
    await _boot(tester);
    await _enterShop(tester);

    await tester.tap(find.text('داواکارییەکان'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('داریا کاروان').first);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'داریا کاروان').first,
      'ئاراس تێست',
    );
    await tester.tap(find.text('پاشەکەوتکردن'));
    await tester.pumpAndSettle();

    expect(find.text('ئاراس تێست'), findsWidgets);
  });

  testWidgets('Customer tab opens a profile with totals', (tester) async {
    await _boot(tester);
    await _enterShop(tester);

    await tester.tap(find.text('کڕیاران'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('داریا کاروان').first);
    await tester.pumpAndSettle();

    expect(find.text('داواکاری'), findsWidgets);
    expect(find.text('قەرز'), findsWidgets);
  });

  test('Delivering with a partial payment leaves the rest as a loan', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = OrdersProvider();
    await Future<void>.delayed(const Duration(milliseconds: 80));

    // Sample order 8842: total 270.000, already paid 100.000 -> owes 170.000.
    final before = provider.byId('8842')!;
    expect(before.remaining, 170000);

    provider.deliver('8842', paidNow: 70000);

    final after = provider.byId('8842')!;
    expect(after.status, OrderStatus.delivered);
    expect(after.paid, 170000);
    expect(after.remaining, 100000);
    expect(after.loan, 100000); // the unpaid part is a قەرز
    expect(provider.loanOrders.map((o) => o.id), contains('8842'));
  });

  test('Delivering a fully paid order creates no loan', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = OrdersProvider();
    await Future<void>.delayed(const Duration(milliseconds: 80));

    // Sample order 8845 is already paid in full.
    provider.deliver('8845', paidNow: 0);

    final after = provider.byId('8845')!;
    expect(after.status, OrderStatus.delivered);
    expect(after.loan, 0);
  });

  test('Settling a loan records the payment and clears it', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = OrdersProvider();
    await Future<void>.delayed(const Duration(milliseconds: 80));

    provider.deliver('8842', paidNow: 0); // owes the full 170.000
    expect(provider.byId('8842')!.loan, 170000);

    provider.addPayment('8842', provider.byId('8842')!.loan);

    expect(provider.byId('8842')!.loan, 0);
    expect(provider.loanOrders.map((o) => o.id), isNot(contains('8842')));
  });
}
