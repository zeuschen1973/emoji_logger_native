import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AppSentryLogger {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static late final PackageInfo _pkg;

  static IosDeviceInfo? _ios;
  static AndroidDeviceInfo? _android;
  static WebBrowserInfo? _web;
  static WindowsDeviceInfo? _windows;
  static MacOsDeviceInfo? _macos;
  static LinuxDeviceInfo? _linux;

  static final Map<String, DateTime> _rateLimit = {};

  static Future<void> init() async {
    _pkg = await PackageInfo.fromPlatform();

    if (kIsWeb) {
      _web = await _deviceInfo.webBrowserInfo;
      return;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        _ios = await _deviceInfo.iosInfo;
        break;
      case TargetPlatform.android:
        _android = await _deviceInfo.androidInfo;
        break;
      case TargetPlatform.windows:
        _windows = await _deviceInfo.windowsInfo;
        break;
      case TargetPlatform.macOS:
        _macos = await _deviceInfo.macOsInfo;
        break;
      case TargetPlatform.linux:
        _linux = await _deviceInfo.linuxInfo;
        break;
      default:
      // fuchsia / unknown：不取 device info
        break;
    }
  }

  static String _platformSuffix() {
    if (kIsWeb) return 'Web';

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'iOS';
      case TargetPlatform.android:
        return 'Android';
      case TargetPlatform.windows:
        return 'Windows';
      case TargetPlatform.macOS:
        return 'macOS';
      case TargetPlatform.linux:
        return 'Linux';
      default:
        return 'Unknown';
    }
  }

  static String _env({String? override}) {
    if (override != null) return override;
    if (kDebugMode) return 'debug';
    if (kProfileMode) return 'staging';
    return 'production';
  }

  static String _hash(String input) =>
      sha256.convert(utf8.encode(input)).toString();

  static String? _hashOrNull(String? input, bool hashSensitive) {
    if (input == null) return null;
    return hashSensitive ? _hash(input) : input;
  }

  static bool _shouldSend(String key, Duration window) {
    final now = DateTime.now();
    final last = _rateLimit[key];
    if (last != null && now.difference(last) < window) return false;
    _rateLimit[key] = now;
    return true;
  }

  static Future<SentryId?> logEnvEvent({
    String baseName = 'getSentryEnvEvent',
    SentryLevel level = SentryLevel.info,
    Duration rateLimitWindow = const Duration(seconds: 0),
    bool hashSensitive = true,
    String? environmentOverride,
    Map<String, String>? tags,
    Map<String, dynamic>? extra,
  }) async {
    final platform = _platformSuffix();
    final eventName = '$baseName-$platform';

    final release = '${_pkg.packageName}@${_pkg.version}+${_pkg.buildNumber}';

    final mergedTags = <String, String>{
      'buildNumber': _pkg.buildNumber,
      'platform': platform.toLowerCase(),
      ...?tags,
    };

    final mergedExtra = <String, dynamic>{
      ...?extra,

      /// ---- iOS ----
      if (_ios != null) ...{
        'iosName': _hashOrNull(_ios!.name, hashSensitive),
        'systemName': _ios!.systemName,
        'systemVersion': _ios!.systemVersion,
        'model': _ios!.model,
        'localizedModel': _ios!.localizedModel,
        'utsname.machine': _ios!.utsname.machine,
      },

      /// ---- Android ----
      if (_android != null) ...{
        'brand': _android!.brand,
        'model': _android!.model,
        'device': _android!.device,
        'manufacturer': _android!.manufacturer,
        'version': _android!.version.release,
        'sdkInt': _android!.version.sdkInt,
        'isPhysicalDevice': _android!.isPhysicalDevice,
        'type': _android!.type,
        'id': _android!.id,
        'display': _android!.display,
        'hardware': _android!.hardware,
        'product': _android!.product,
        'supported32BitAbis': _android!.supported32BitAbis,
        'supported64BitAbis': _android!.supported64BitAbis,
        'supportedAbis': _android!.supportedAbis,
        // 'androidId': _hashOrNull(_android!.androidId, hashSensitive),
      },

      /// ---- Web ----
      if (_web != null) ...{
        'browserName': _web!.browserName.name,
        'appName': _web!.appName,
        'appVersion': _web!.appVersion,
        'userAgent': _web!.userAgent,
        'language': _web!.language,
        'platformInfo': _web!.platform,
        'vendor': _web!.vendor,
        'hardwareConcurrency': _web!.hardwareConcurrency,
        'deviceMemory': _web!.deviceMemory,
        'maxTouchPoints': _web!.maxTouchPoints,
      },

      /// ---- Windows ----
      if (_windows != null) ...{
        'computerName': _hashOrNull(_windows!.computerName, hashSensitive),
        'userName': _hashOrNull(_windows!.userName, hashSensitive),
        'numberOfCores': _windows!.numberOfCores,
        'systemMemoryInMegabytes': _windows!.systemMemoryInMegabytes,
        'majorVersion': _windows!.majorVersion,
        'minorVersion': _windows!.minorVersion,
        'buildNumber': _windows!.buildNumber,
        'platformId': _windows!.platformId,
      },

      /// ---- macOS ----
      if (_macos != null) ...{
        'model': _macos!.model,
        'arch': _macos!.arch,
        'kernelVersion': _macos!.kernelVersion,
        'osRelease': _macos!.osRelease,
        'activeCPUs': _macos!.activeCPUs,
        'memorySize': _macos!.memorySize,
        'computerName': _hashOrNull(_macos!.computerName, hashSensitive),
        'hostName': _hashOrNull(_macos!.hostName, hashSensitive),
      },

      /// ---- Linux ----
      if (_linux != null) ...{
        'name': _linux!.name,
        'version': _linux!.version,
        'id': _linux!.id,
        'idLike': _linux!.idLike,
        'variant': _linux!.variant,
        'variantId': _linux!.variantId,
        'prettyName': _linux!.prettyName,
        'machineId': _hashOrNull(_linux!.machineId, hashSensitive),
      },
    };

    final fingerprint = ['custom-event', baseName, mergedTags['platform']!];

    final rateKey = fingerprint.join('|');
    if (rateLimitWindow > Duration.zero &&
        !_shouldSend(rateKey, rateLimitWindow)) {
      return null;
    }

    final event = SentryEvent(
      message: SentryMessage(eventName),
      level: level,
      release: release,
      environment: _env(override: environmentOverride),
      tags: mergedTags,
      fingerprint: fingerprint,
    );

    return Sentry.captureEvent(
      event,
      withScope: (scope) {
        if (mergedExtra.isNotEmpty) {
          // All your extra info goes into a structured context, e.g., "deviceInfo"
          scope.setContexts('deviceInfo', mergedExtra);
        }
      },
    );
  }
}
