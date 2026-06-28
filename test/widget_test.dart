import 'package:flutter_test/flutter_test.dart';
import 'package:pddikti_explorer/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App compiles and loads home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PddiktiApp()));
    expect(find.byType(PddiktiApp), findsOneWidget);
  });
}
