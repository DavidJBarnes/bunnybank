import 'package:flutter/material.dart';

class BalanceDisplay extends StatefulWidget {
  final double balance;

  const BalanceDisplay({super.key, required this.balance});

  @override
  State<BalanceDisplay> createState() => _BalanceDisplayState();
}

class _BalanceDisplayState extends State<BalanceDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  double _previousBalance = 0;

  @override
  void initState() {
    super.initState();
    _previousBalance = widget.balance;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(BalanceDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.balance > _previousBalance) {
      _controller.forward().then((_) => _controller.reverse());
    }
    _previousBalance = widget.balance;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Your Balance',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Text(
                '\$${widget.balance.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 48,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.currency_exchange, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              const Text(
                'Bunny Bucks',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
