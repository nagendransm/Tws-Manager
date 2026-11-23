import 'package:flutter_test/flutter_test.dart';
import 'package:tws_manager/main.dart';

void main() {
  testWidgets('TWS Manager initial load test', (WidgetTester tester) async {
    await tester.pumpWidget(const TwsManagerApp());
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('Mivi DuoPods K2'), findsWidgets);
    expect(find.textContaining('Battery & Playtime'), findsOneWidget);
    expect(find.textContaining('Battle Mode'), findsWidgets);
  });
}
