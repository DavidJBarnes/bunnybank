import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bunnybank_child/app.dart';
import 'package:bunnybank_child/services/auth_service.dart';
import 'package:bunnybank_child/services/notification_service.dart';
import 'package:bunnybank_child/services/platform_audio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authService = AuthService();
  await authService.tryAutoLogin();

  final notificationService = NotificationService();
  // Register the device's FCM token with the API so the server can push the
  // cha-ching (works before or after login; queued until authenticated).
  notificationService.onToken = authService.setFcmToken;
  await notificationService.initialize();

  final audio = createPlatformAudio();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authService),
        Provider.value(value: notificationService),
        Provider.value(value: audio),
      ],
      child: const BunnyBankChildApp(),
    ),
  );
}
