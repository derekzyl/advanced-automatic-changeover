import 'package:flutter/material.dart';

class VoltageGauge extends StatelessWidget {
  final String title;
  final double voltage;
  final Color color;

  const VoltageGauge({
    super.key,
    required this.title,
    required this.voltage,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    final isNormal = voltage >= 200 && voltage <= 240;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${voltage.toStringAsFixed(1)} V',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isNormal ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (voltage / 250).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: isNormal ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

