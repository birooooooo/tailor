// Generates real screenshots of the app.
//
// Run with:  flutter test --update-goldens test/screenshots_test.dart
// Output:    test/goldens/*.png
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tailor_app/main.dart';
import 'package:tailor_app/providers/theme_provider.dart';

Future<void> _loadFonts() async {
  final loader = FontLoader('Vazirmatn');
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    loader.addFont(rootBundle.load('assets/fonts/Vazirmatn-$weight.ttf'));
  }
  await loader.load();

  // The test renderer does not load the Material icon font by default.
  const iconPath =
      r'C:\src\flutter\bin\cache\artifacts\material_fonts\MaterialIcons-Regular.otf';
  final iconFile = File(iconPath);
  if (iconFile.existsSync()) {
    final bytes = iconFile.readAsBytesSync();
    final iconLoader = FontLoader('MaterialIcons')
      ..addFont(Future.value(ByteData.sublistView(bytes)));
    await iconLoader.load();
  }
}

void _sizePhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(390 * 2, 844 * 2);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Starts the app and waits for the splash to finish.
Future<void> _boot(WidgetTester tester) async {
  await tester.pumpWidget(const TailorApp());
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

/// On the login screen, continues without an account.
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
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadFonts();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('splash screenshot', (tester) async {
    _sizePhone(tester);
    await tester.pumpWidget(const TailorApp());
    await tester.pump(const Duration(milliseconds: 700));
    await expectLater(
      find.byType(TailorApp),
      matchesGoldenFile('goldens/00_splash.png'),
    );

    // Let the splash timer finish so no timer is left pending.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  testWidgets('shop login screenshot', (tester) async {
    _sizePhone(tester);
    await _boot(tester);
    await expectLater(
      find.byType(TailorApp),
      matchesGoldenFile('goldens/08_shop_login.png'),
    );
  });

  testWidgets('shop screenshots', (tester) async {
    _sizePhone(tester);
    await _boot(tester);
    await _enterShop(tester);

    await expectLater(
      find.byType(TailorApp),
      matchesGoldenFile('goldens/01_dashboard.png'),
    );

    await tester.tap(find.text('داواکارییەکان'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(TailorApp),
      matchesGoldenFile('goldens/02_orders.png'),
    );

    await tester.tap(find.text('داریا کاروان').first);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(TailorApp),
      matchesGoldenFile('goldens/03_order_details.png'),
    );
  });

  testWidgets('new order screenshot', (tester) async {
    _sizePhone(tester);
    await _boot(tester);
    await _enterShop(tester);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(TailorApp),
      matchesGoldenFile('goldens/04_new_order.png'),
    );

    await tester.drag(find.byType(ListView).first, const Offset(0, -1600));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(TailorApp),
      matchesGoldenFile('goldens/05_new_order_bottom.png'),
    );
  });

  testWidgets('incoming requests screenshot', (tester) async {
    _sizePhone(tester);
    await _boot(tester);
    await _enterShop(tester);

    await tester.tap(find.text('داواکاری نوێ'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(TailorApp),
      matchesGoldenFile('goldens/07_requests.png'),
    );
  });

  testWidgets('dark mode dashboard', (tester) async {
    _sizePhone(tester);
    await _boot(tester);
    await _enterShop(tester);

    final ctx = tester.element(find.byType(MaterialApp));
    Provider.of<ThemeProvider>(ctx, listen: false).setDark(true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    await expectLater(
      find.byType(TailorApp),
      matchesGoldenFile('goldens/06_dark_dashboard.png'),
    );
  });
}
