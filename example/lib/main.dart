import 'package:emoji_logger_native_example/sentry_event.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:emoji_logger_native/emoji_logger_native.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class AppPlatform {
  static bool get isWeb => kIsWeb;

  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static bool get isIOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  static bool get isMobile => isAndroid || isIOS;
}

Future<void> main() async {
  await SentryFlutter.init(
        (options) {
      options.dsn =
      'https://d27c644085cd5c1d172a3bf134aeafe5@o4510523949187072.ingest.us.sentry.io/4510523960655872';
      options.sendDefaultPii = true;
      options.debug = true;
      options.diagnosticLevel = SentryLevel.debug;
      options.tracesSampleRate = 1.0;
    },
    appRunner: () async {
      // ✅ 只在 Mobile 初始化 Firebase
      if (AppPlatform.isMobile) {
        await Firebase.initializeApp();
      }

      await AppSentryLogger.init();

      // Flutter 同步错误
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);

        if (AppPlatform.isMobile) {
          FirebaseCrashlytics.instance
              .recordFlutterFatalError(details);
        }

        if (!kReleaseMode) {
          FlutterError.dumpErrorToConsole(details);
        }
      };

      // Dart / async 错误
      PlatformDispatcher.instance.onError =
          (Object error, StackTrace stack) {
        if (AppPlatform.isMobile) {
          FirebaseCrashlytics.instance
              .recordError(error, stack, fatal: true);
        }

        Sentry.captureException(error, stackTrace: stack);
        return true;
      };

      // ✅ runApp 与 Sentry 同 Zone
      runApp(
        SentryWidget(
          child: const MyApp(),
        ),
      );
    },
  );
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _emojiLoggerNativePlugin = EmojiLoggerNative();
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    _initPlatform();
  }

  Future<void> _initPlatform() async {
    try {
      final version =
      await _emojiLoggerNativePlugin.getPlatformVersion();
      if (!mounted) return;
      setState(() {
        _platformVersion = version ?? 'Unknown';
      });
    } on PlatformException {
      setState(() {
        _platformVersion = 'Failed to get platform version';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Running on: $_platformVersion'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    key: const ValueKey('btn_debug'),
                    onPressed: () async {
                      _emojiLoggerNativePlugin
                          .debug('Debug button clicked');

                      await FirebaseAnalytics.instance.logEvent(
                        name: 'debug_click',
                        parameters: {
                          'source': 'button',
                        },
                      );

                      await AppSentryLogger.logEnvEvent(
                        baseName: 'DebugClick',
                        level: SentryLevel.info,
                        rateLimitWindow:
                        const Duration(seconds: 10),
                        extra: {'button': 'debug'},
                      );
                    },
                    child: const Text('debug'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    key: const ValueKey('btn_error'),
                    onPressed: () async {
                      _emojiLoggerNativePlugin
                          .error('Error button clicked');
                      try {
                        throw Exception('sync error in onPressed');
                      }catch(e,s) {
                        await FirebaseCrashlytics.instance.recordError(e, s, fatal: true);
                        //rethrow;
                      }
                    },
                    child: const Text('error'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


