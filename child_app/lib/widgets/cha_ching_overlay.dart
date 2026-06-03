import 'package:flutter/material.dart';

class ChaChingOverlay extends StatefulWidget {
  final double amount;

  const ChaChingOverlay({super.key, required this.amount});

  @override
  State<ChaChingOverlay> createState() => _ChaChingOverlayState();
}

class _ChaChingOverlayState extends State<ChaChingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: 120,
          left: 0,
          right: 0,
          child: Opacity(
            opacity: (1.0 - _controller.value).clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, -_controller.value * 150),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.white, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        '+\$${widget.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
