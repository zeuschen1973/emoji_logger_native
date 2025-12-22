#include "include/emoji_logger_native/emoji_logger_native_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "emoji_logger_native_plugin.h"

void EmojiLoggerNativePluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  emoji_logger_native::EmojiLoggerNativePlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
