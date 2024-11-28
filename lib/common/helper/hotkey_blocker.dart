import 'dart:developer';

import 'package:flutter/services.dart';

class HotkeyBlocker {
  static const platform =
      EventChannel('com.gariskode.elearning_flutter/hotkey');

  static void blockHotkeys() async {
    try {
      platform.receiveBroadcastStream().listen((event) {
        log('Hotkey pressed: $event');
      });
      // final result = await platform.invokeMethod<bool>('blockHotkeys');
      // log('Hotkeys blocked: $result');
    } on PlatformException catch (e) {
      log("Failed to block hotkeys: '${e.message}'.");
    }
  }
}
