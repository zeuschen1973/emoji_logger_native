// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:js_interop';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

import 'emoji_logger_native_platform_interface.dart';

/// A web implementation of the EmojiLoggerNativePlatform of the EmojiLoggerNative plugin.
class EmojiLoggerNativeWeb extends EmojiLoggerNativePlatform {
  EmojiLoggerNativeWeb();

  static void registerWith(Registrar registrar) {
    EmojiLoggerNativePlatform.instance = EmojiLoggerNativeWeb();
  }

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = web.window.navigator.userAgent;
    return version;
  }

  @override
  Future<void> debug(String message) async {
    web.console.log('🐛 $message'.toJS);
  }

  @override
  Future<void> error(String message) async {
    web.console.error('🧯 $message'.toJS);
  }

}

