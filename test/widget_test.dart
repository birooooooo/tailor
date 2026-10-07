import 'package:flutter_test/flutter_test.dart';
import 'package:tailor_app/main.dart';

void main() {
  testWidgets('Role select screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const TailorApp());
    await tester.pumpAndSettle();

    // The app name (Kurdish) should be visible on the role select screen.
    expect(find.text('تەرز'), findsOneWidget);
  });
}
