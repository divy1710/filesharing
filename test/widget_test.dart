// Basic test file for Smart File Share app
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_file_share/main.dart';

void main() {
  testWidgets('App should load without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartFileShareApp());
    expect(find.text('SmartShare'), findsOneWidget);
  });
}
