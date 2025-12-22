import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:emoji_logger_native_example/main.dart' as app;

Future<void> pumpFor(WidgetTester tester, Duration duration) async {
  final end = DateTime.now().add(duration);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> waitForFinder(
    WidgetTester tester,
    Finder finder, {
      Duration timeout = const Duration(seconds: 30),
    }) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timeout waiting for: $finder');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('launch app then tap debug & error', (WidgetTester tester) async {
    app.main();

    // ✅ 先让启动过程跑一会（不要求“完全 settle”）
    await pumpFor(tester, const Duration(seconds: 5));

    // ✅ 等待首页关键元素出现（用 finder 作为“就绪信号”）
    await waitForFinder(tester, find.text('Plugin example app'),
        timeout: const Duration(seconds: 45));
    await waitForFinder(tester, find.byKey(const ValueKey('btn_debug')));
    await waitForFinder(tester, find.byKey(const ValueKey('btn_error')));

    // tap debug
    await tester.tap(find.byKey(const ValueKey('btn_debug')));
    await pumpFor(tester, const Duration(seconds: 2));

    // tap error
    await tester.tap(find.byKey(const ValueKey('btn_error')));
    await pumpFor(tester, const Duration(seconds: 2));

    // still alive
    expect(find.text('Plugin example app'), findsOneWidget);
  });
}
