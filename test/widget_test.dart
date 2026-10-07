import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tailor_app/main.dart';

void main() {
  testWidgets('Role select screen renders in Kurdish', (tester) async {
    await tester.pumpWidget(const TailorApp());
    await tester.pumpAndSettle();
    expect(find.text('تەرز'), findsOneWidget);
  });

  testWidgets('Shop dashboard opens with stats and recent orders',
      (tester) async {
    await tester.pumpWidget(const TailorApp());
    await tester.pumpAndSettle();

    // Tap the "tailor shop" role card.
    await tester.tap(find.text('دوکانی دروین'));
    await tester.pumpAndSettle();

    expect(find.text('داواکاری نوێ'), findsOneWidget); // New order button
    expect(find.text('دوایین داواکارییەکان'), findsOneWidget);
    expect(find.text('داریا کاروان'), findsOneWidget);
  });

  testWidgets('Opening an order shows its details', (tester) async {
    await tester.pumpWidget(const TailorApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('دوکانی دروین'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('داریا کاروان').first);
    await tester.pumpAndSettle();

    expect(find.textContaining('#8842'), findsOneWidget);
    expect(find.text('پێشکەوتنی کارەکان'), findsOneWidget);
  });
}
