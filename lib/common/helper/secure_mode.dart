import 'dart:io';
import 'package:fraud_protection/fraud_protection.dart';

Future<void> enableSecureMode() async {
  if (!Platform.isAndroid) return;

  // 1. Android 12+ : sembunyikan overlay non-system (chat head, floating recorder, dll)
  await FraudProtection.setHideOverlayWindows(true);

  // 2. Semua versi Android: blok sentuhan kalau view tertutup overlay
  await FraudProtection.setBlockOverlayTouches(true);
}

Future<void> disableSecureMode() async {
  if (!Platform.isAndroid) return;

  await FraudProtection.setHideOverlayWindows(false);
  await FraudProtection.setBlockOverlayTouches(false);
}
