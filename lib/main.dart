import 'package:elearning_app/presentation/pages/exam_android_page.dart';
import 'package:elearning_app/presentation/pages/exam_windows_page.dart';
import 'package:elearning_app/presentation/pages/splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:window_manager/window_manager.dart';

WebViewEnvironment? webViewEnvironment;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
    final availableVersion = await WebViewEnvironment.getAvailableVersion();
    assert(availableVersion != null,
        'Failed to find an installed WebView2 Runtime or non-stable Microsoft Edge installation.');

    webViewEnvironment = await WebViewEnvironment.create(
        settings:
            WebViewEnvironmentSettings(userDataFolder: 'example-webview'));

    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1920, 1080),
      center: true,
      fullScreen: true,
      skipTaskbar: false,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setFullScreen(true);
      await windowManager.focus();
      // await windowManager.setAlwaysOnTop(true);
      await windowManager.setResizable(false);
    });
  }

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exam App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
      routes: {
        SplashScreen.routeName: (context) => const SplashScreen(),
        ExamWindowsPage.routeName: (context) =>  ExamWindowsPage(),
        ExamAndroidPage.routeName: (context) =>  ExamAndroidPage(),
      },
    );
  }
}
