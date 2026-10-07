import 'package:flutter_test/flutter_test.dart';

import 'package:tailor_app/main.dart';

void main() {
  testWidgets('Role select screen renders in Kurdish', (tester) async {
    await tester.pumpWidget(const TailorApp());
    await tester.pumpAndSettle();
    expect(find.text('تەرز'), findsOneWidget);
  });

  testWidgets('Shop dashboard shows greeting and stats', (tester) async {
    await tester.pumpWidget(const TailorApp());
    await tester.pumpAndSettle();

    // Tap the "tailor shop" role card.
    await tester.tap(find.text('دوکانی دروین'));
    await tester.pumpAndSettle();

    expect(find.text('بەخێربێیتەوە'), findsOneWidget); // greeting
    expect(find.text('داهاتی ئەم مانگە'), findsOneWidget); // hero tile
    expect(find.text('دەگات ئەمڕۆ'), findsOneWidget); // bento tile
  });

  testWidgets('Opening an order from the orders tab shows its details', (
    tester,
  ) async {
    await tester.pumpWidget(const TailorApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('دوکانی دروین'));
    await tester.pumpAndSettle();

    // Switch to the orders tab via the bottom navigation.
    await tester.tap(find.text('داواکارییەکان'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('داریا کاروان').first);
    await tester.pumpAndSettle();

    expect(find.textContaining('#8842'), findsOneWidget);
    expect(find.text('پێشکەوتنی کارەکان'), findsOneWidget);
  });
}
