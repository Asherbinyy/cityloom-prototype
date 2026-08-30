import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cityloom_prototype/main.dart';
import 'package:cityloom_prototype/state/app_state.dart';

void main() {
  testWidgets('CityLoom app smoke test', (WidgetTester tester) async {
    // Disable animations during test to avoid pending timer assertions
    Animate.restartOnHotReload = false;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppState()),
        ],
        child: const CityLoomApp(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));

    // Verify that the title and Start button are present
    expect(find.text('Greyfriars Kirkyard'), findsOneWidget);
    expect(find.text('Start Exploring'), findsOneWidget);
  });
}
