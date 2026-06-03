import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bunnybank_child/services/auth_service.dart';
import 'package:bunnybank_child/services/balance_service.dart';
import 'package:bunnybank_child/services/platform_audio.dart';
import 'package:bunnybank_child/widgets/balance_display.dart';
import 'package:bunnybank_child/widgets/cha_ching_overlay.dart';
import 'package:bunnybank_child/screens/transactions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final BalanceService _balanceService;
  StreamSubscription? _moneySub;
  bool _showChaching = false;
  double _lastAmount = 0;
  bool _audioPrimed = false;

  void _primeAudio() {
    if (_audioPrimed) return;
    _audioPrimed = true;
    final audio = context.read<PlatformAudio>();
    audio.load('assets/sounds/cha_ching.wav');
    audio.play();
  }

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthService>();
    _balanceService = BalanceService(auth.api);
    _balanceService.addListener(_onBalanceChanged);
    _balanceService.startPolling();

    _moneySub = _balanceService.moneyStream.listen((data) {
      final amount = double.tryParse(data['amount'] ?? '0') ?? 0;
      setState(() {
        _showChaching = true;
        _lastAmount = amount;
      });
      try {
        context.read<PlatformAudio>().play();
      } catch (_) {}
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showChaching = false);
      });
    });
  }

  void _onBalanceChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _balanceService.stopPolling();
    _balanceService.removeListener(_onBalanceChanged);
    _balanceService.dispose();
    _moneySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Listener(
          onPointerDown: (_) => _primeAudio(),
          child: Stack(
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: colorScheme.primaryContainer,
                  child: Row(
                    children: [
                      Icon(Icons.savings, color: colorScheme.primary, size: 36),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BunnyBank',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              'Hi, ${auth.childName ?? 'there'}!',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: BalanceDisplay(balance: _balanceService.balance),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const TransactionsScreen()),
                            );
                          },
                          icon: const Icon(Icons.history),
                          label: const Text('History'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => auth.logout(),
                          icon: const Icon(Icons.logout),
                          label: const Text('Sign Out'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_showChaching) ChaChingOverlay(amount: _lastAmount),
          ],
        ),
      ),
      ),
    );
  }
}
