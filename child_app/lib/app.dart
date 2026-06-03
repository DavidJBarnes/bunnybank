import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:bunnybank_child/services/auth_service.dart';
import 'package:bunnybank_child/screens/login_screen.dart';
import 'package:bunnybank_child/screens/home_screen.dart';

class BunnyBankChildApp extends StatelessWidget {
  const BunnyBankChildApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BunnyBank',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00C853),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.fredokaTextTheme(),
      ),
      home: Consumer<AuthService>(
        builder: (context, auth, _) {
          if (auth.isAuthenticated) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
