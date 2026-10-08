import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tailor_app/main.dart';

/// Taps the shop role card and, if the login screen shows up, continues
/// without an account (offline mode).
Future<void> _enterShop(WidgetTester tester) async {
  await tester.tap(find.text('دوکانی دروین'));
  await tester.pumpAndSettle();

  final guest = find.text('بەردەوامبوون بێ هەژمار');
  if (guest.evaluate().isNotEmpty) {
    await tester.ensureVisible(guest);
    await tester.pumpAndSettle();
    await tester.tap(guest);
    await tester.pumpAndSettle();
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Role select screen renders in Kurdish', (tester) async {
    await tester.pumpWidget(const TailorApp());
    await tester.pumpAndSettle();
    expect(find.text('تەرز'), findsOneWidget);
  });

  testWidgets('Shop dashboard shows greeting and stats', (tester) async {
    await tester.pumpWidget(const TailorApp());
    await tester.pumpAndSettle();

    await _enterShop(tester);

    expect(find.text('بەخێربێیتەوە'), findsOneWidget); // greeting
    expect(find.text('داهاتی ئەم مانگە'), findsOneWidget); // hero tile
    expect(find.text('ئامادەیە'), findsOneWidget); // bento tile
  });

  testWidgets('Opening an order from the orders tab shows its details', (
    tester,
  ) async {
    await tester.pumpWidget(const TailorApp());
    await tester.pumpAndSettle();

    await _enterShop(tester);

    // Switch to the orders tab via the bottom navigation.
    await tester.tap(find.text('داواکارییەکان'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('داریا کاروان').first);
    await tester.pumpAndSettle();

    expect(find.textContaining('#8842'), findsOneWidget);
    expect(find.text('پێشکەوتنی کارەکان'), findsOneWidget);
  });
}
