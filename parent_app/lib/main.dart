import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bunnybank_parent/app.dart';
import 'package:bunnybank_parent/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authService = AuthService();
  await authService.tryAutoLogin();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authService),
      ],
      child: const BunnyBankParentApp(),
    ),
  );
}
