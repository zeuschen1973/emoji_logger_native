import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'emoji_logger_native_platform_interface.dart';

/// An implementation of [EmojiLoggerNativePlatform] that uses method channels.
class MethodChannelEmojiLoggerNative extends EmojiLoggerNativePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('emoji_logger_native');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
  @override
  Future<void> debug(String message)  async {
    await methodChannel.invokeMethod('debug',{ 'message' : '🐛 $message',});
  }
  @override
  Future<void> error(String message)  async {
    await methodChannel.invokeMethod('error',{ 'message' : '🧯 $message',});
  }
}
