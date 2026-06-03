import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:bunnybank_parent/services/auth_service.dart';
import 'package:bunnybank_parent/screens/login_screen.dart';
import 'package:bunnybank_parent/screens/home_screen.dart';

class BunnyBankParentApp extends StatelessWidget {
  const BunnyBankParentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BunnyBank Parent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C4DFF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.nunitoTextTheme(),
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
