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
