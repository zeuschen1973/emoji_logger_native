import 'package:flutter_test/flutter_test.dart';
import 'package:emoji_logger_native/emoji_logger_native.dart';
import 'package:emoji_logger_native/emoji_logger_native_platform_interface.dart';
import 'package:emoji_logger_native/emoji_logger_native_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockEmojiLoggerNativePlatform
    with MockPlatformInterfaceMixin
    implements EmojiLoggerNativePlatform {
  bool debugCalled = false;
  bool errorCalled = false;
  String? lastDebugMessage;
  String? lastErrorMessage;

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
  @override
  Future<void> debug(String message) async {
    debugCalled = true;
    lastDebugMessage = message;
  }

  @override
  Future<void> error(String message) async {
    errorCalled = true;
    lastErrorMessage = message;
  }
}

void main() {
  final EmojiLoggerNativePlatform initialPlatform = EmojiLoggerNativePlatform.instance;

  test('$MethodChannelEmojiLoggerNative is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelEmojiLoggerNative>());
  });

  test('getPlatformVersion', () async {
    EmojiLoggerNative emojiLoggerNativePlugin = EmojiLoggerNative();
    MockEmojiLoggerNativePlatform fakePlatform = MockEmojiLoggerNativePlatform();
    EmojiLoggerNativePlatform.instance = fakePlatform;

    expect(await emojiLoggerNativePlugin.getPlatformVersion(), '42');
  });
  test('debug is forwarded to platform', () async {
    final mock = MockEmojiLoggerNativePlatform();
    EmojiLoggerNativePlatform.instance = mock;

    await EmojiLoggerNative().debug('hello');

    expect(mock.debugCalled, true);
    expect(mock.lastDebugMessage, 'hello');
  });
}
