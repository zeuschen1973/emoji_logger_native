
import 'emoji_logger_native_platform_interface.dart';

class EmojiLoggerNative {
  Future<String?> getPlatformVersion() {
    return EmojiLoggerNativePlatform.instance.getPlatformVersion();
  }
  Future<void> debug(String message) {
    return EmojiLoggerNativePlatform.instance.debug(message);
  }
  Future<void> error(String message) {
    return EmojiLoggerNativePlatform.instance.error(message);
  }
}
