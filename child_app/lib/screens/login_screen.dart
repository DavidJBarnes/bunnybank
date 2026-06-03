import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bunnybank_child/services/auth_service.dart';
import 'package:bunnybank_child/services/platform_audio.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _childIdCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();

  @override
  void dispose() {
    _childIdCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final childId = _childIdCtrl.text.trim();
    final pin = _pinCtrl.text.trim();
    if (childId.isEmpty || pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter both your ID and PIN')),
      );
      return;
    }
    try {
      final audio = context.read<PlatformAudio>();
      await audio.load('assets/sounds/cha_ching.wav');
      await context.read<AuthService>().login(childId, pin);
      audio.play();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wrong PIN. Try again!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.savings, size: 80, color: colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  'BunnyBank',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _childIdCtrl,
                  decoration: InputDecoration(
                    labelText: 'Your ID',
                    border: const OutlineInputBorder(),
                    helperText: 'Ask your parent for your ID',
                    helperMaxLines: 2,
                    prefixIcon: Icon(Icons.person_pin, color: colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pinCtrl,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                  decoration: InputDecoration(
                    labelText: 'PIN',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock, color: colorScheme.primary),
                  ),
                  onFieldSubmitted: (_) => _login(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: auth.loading ? null : _login,
                    child: auth.loading
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Enter'),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.help_outline, size: 20, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text('How to log in', style: Theme.of(context).textTheme.titleSmall),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1. Ask your parent to open their BunnyBank app\n'
                        '2. They tap "My Children", then tap your name\n'
                        '3. They\'ll see your ID – they can copy and send it to you\n'
                        '4. Paste your ID here and enter your PIN',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
