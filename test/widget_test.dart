import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tailor_app/main.dart';

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
    expect(find.text('پێشکەوتنی کارەکان'), findsOneWidget);
  });
}
