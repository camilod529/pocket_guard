import 'package:flutter/material.dart';
import 'package:pocket_guard/utils/shared/number_formatting.dart';

class StatCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final String currency;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                NumberFormatting.formatCompactCurrency(value, currency),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
