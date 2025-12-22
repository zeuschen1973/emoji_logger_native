//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <emoji_logger_native/emoji_logger_native_plugin_c_api.h>
#include <firebase_core/firebase_core_plugin_c_api.h>
#include <sentry_flutter/sentry_flutter_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  EmojiLoggerNativePluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("EmojiLoggerNativePluginCApi"));
  FirebaseCorePluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FirebaseCorePluginCApi"));
  SentryFlutterPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("SentryFlutterPlugin"));
}
