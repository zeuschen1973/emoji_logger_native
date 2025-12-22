#include "emoji_logger_native_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>

namespace emoji_logger_native {

// static
void EmojiLoggerNativePlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "emoji_logger_native",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<EmojiLoggerNativePlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

EmojiLoggerNativePlugin::EmojiLoggerNativePlugin() {}

EmojiLoggerNativePlugin::~EmojiLoggerNativePlugin() {}

    void EmojiLoggerNativePlugin::HandleMethodCall(
            const flutter::MethodCall<flutter::EncodableValue> &method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

        const auto& method = method_call.method_name();

        if (method == "getPlatformVersion") {
            std::ostringstream version_stream;
            version_stream << "Windows ";
            if (IsWindows10OrGreater()) {
                version_stream << "10+";
            } else if (IsWindows8OrGreater()) {
                version_stream << "8";
            } else if (IsWindows7OrGreater()) {
                version_stream << "7";
            }
            result->Success(flutter::EncodableValue(version_stream.str()));
            return;
        }

        if (method == "debug" || method == "error") {
            // arguments() is an EncodableValue, we expect a Map<String, Object>
            const auto* args =
                    std::get_if<flutter::EncodableMap>(method_call.arguments());

            std::string message;

            if (args) {
                auto it = args->find(flutter::EncodableValue("message"));
                if (it != args->end()) {
                    if (const auto* msg = std::get_if<std::string>(&it->second)) {
                        message = *msg;
                    }
                }
            }
            if (message.empty()) {
                message = (method == "debug")
                        ? "🐛 (no message)"
                        : "🧯 (no message)";
            }

            std::wstring wide_msg(message.begin(), message.end());
            OutputDebugStringW(wide_msg.c_str());
            result->Success();
            return;
        }
        result->NotImplemented();
    }


}  // namespace emoji_logger_native
