// Generates real screenshots of the shop screens.
//
// Run with:  flutter test --update-goldens test/screenshots_test.dart
// Output:    test/goldens/*.png
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

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

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadFonts();
  });

  testWidgets('shop screenshots', (tester) async {
    _sizePhone(tester);
    await tester.pumpWidget(const TailorApp());
    await tester.pumpAndSettle();

    // Enter the shop side.
    await tester.tap(find.text('دوکانی دروین'));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(TailorApp),
      matchesGoldenFile('goldens/01_dashboard.png'),
    );

    // Orders list.
    await tester.tap(find.text('داواکارییەکان'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(TailorApp),
      matchesGoldenFile('goldens/02_orders.png'),
    );

    // Order details.
    await tester.tap(find.text('داریا کاروان').first);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(TailorApp),
      matchesGoldenFile('goldens/03_order_details.png'),
    );
  });

  testWidgets('new order screenshot', (tester) async {
    _sizePhone(tester);
    await tester.pumpWidget(const TailorApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('دوکانی دروین'));
    await tester.pumpAndSettle();

    // The centre "+" opens the new-order screen directly.
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(TailorApp),
      matchesGoldenFile('goldens/04_new_order.png'),
    );
  });

  testWidgets('dark mode dashboard', (tester) async {
    _sizePhone(tester);
    await tester.pumpWidget(const TailorApp());
    await tester.pumpAndSettle();

    // Go to the shop while still light.
    await tester.tap(find.text('دوکانی دروین'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    // Toggle dark mode.
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
