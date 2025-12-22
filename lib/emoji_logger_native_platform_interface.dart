import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'emoji_logger_native_method_channel.dart';

abstract class EmojiLoggerNativePlatform extends PlatformInterface {
  /// Constructs a EmojiLoggerNativePlatform.
  EmojiLoggerNativePlatform() : super(token: _token);

  static final Object _token = Object();

  static EmojiLoggerNativePlatform _instance = MethodChannelEmojiLoggerNative();

  /// The default instance of [EmojiLoggerNativePlatform] to use.
  ///
  /// Defaults to [MethodChannelEmojiLoggerNative].
  static EmojiLoggerNativePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [EmojiLoggerNativePlatform] when
  /// they register themselves.
  static set instance(EmojiLoggerNativePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
  Future<void> debug(String message) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
  Future<void> error(String message) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
