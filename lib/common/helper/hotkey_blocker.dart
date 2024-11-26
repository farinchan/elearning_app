import 'dart:developer';

import 'package:flutter/services.dart';

class HotkeyBlocker {
  static const platform =
      MethodChannel('com.gariskode.elearning_flutter/hotkey');

  static Future<void> blockHotkeys() async {
    try {
      await platform.invokeMethod('blockHotkeys');
    } on PlatformException catch (e) {
      log("Failed to block hotkeys: '${e.message}'.");
    }
  }
}
