import 'package:flutter_test/flutter_test.dart';
import 'package:aplikasi_kasir/app.dart';

void main() {
  testWidgets('App should render splash screen', (WidgetTester tester) async {
    // Build KasirApp and trigger a frame.
    await tester.pumpWidget(const KasirApp());

    // Verify splash screen is shown
    expect(find.text('Splash Screen'), findsOneWidget);
  });
}
