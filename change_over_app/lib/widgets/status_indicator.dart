import 'package:flutter/material.dart';

class StatusIndicator extends StatelessWidget {
  final String source;
  final bool isConnected;

  const StatusIndicator({
    super.key,
    required this.source,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    Color sourceColor;
    String sourceText;
    IconData sourceIcon;

    switch (source) {
      case 'GRID':
        sourceColor = Colors.green;
        sourceText = 'GRID';
        sourceIcon = Icons.power;
        break;
      case 'GENERATOR':
        sourceColor = Colors.blue;
        sourceText = 'GENERATOR';
        sourceIcon = Icons.electric_bolt;
        break;
      default:
        sourceColor = Colors.red;
        sourceText = 'NONE';
        sourceIcon = Icons.power_off;
    }

    return Card(
      elevation: 4,
      color: sourceColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  sourceIcon,
                  color: sourceColor,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Power Source',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      sourceText,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: sourceColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Connection',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isConnected ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isConnected ? 'Connected' : 'Disconnected',
                      style: TextStyle(
                        fontSize: 12,
                        color: isConnected ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

