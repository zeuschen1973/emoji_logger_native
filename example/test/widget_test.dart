import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:emoji_logger_native_example/main.dart'; // adjust if needed

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock channel for emoji_logger_native (used in initState)
  const MethodChannel emojiLoggerChannel =
  MethodChannel('emoji_logger_native');

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(emojiLoggerChannel, (call) async {
      if (call.method == 'getPlatformVersion') {
        return 'test-platform';
      }
      return null;
    });
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(emojiLoggerChannel, null);
  });

  testWidgets('MyApp loads page', (WidgetTester tester) async {
    // Act
    await tester.pumpWidget(const MyApp());
    await tester.pump(); // allow initState async to complete

    // Assert
    expect(find.text('Plugin example app'), findsOneWidget);
    expect(find.textContaining('Running on:'), findsOneWidget);
    expect(find.text('debug'), findsOneWidget);
    expect(find.text('error'), findsOneWidget);
  });
}
