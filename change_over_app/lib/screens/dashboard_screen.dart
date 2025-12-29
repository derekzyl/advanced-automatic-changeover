import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/power_provider.dart';
import '../widgets/status_indicator.dart';
import '../widgets/voltage_gauge.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Changeover Dashboard'),
        actions: [
          Consumer<PowerProvider>(
            builder: (context, provider, _) {
              return IconButton(
                icon: Icon(
                  provider.isConnected ? Icons.wifi : Icons.wifi_off,
                  color: provider.isConnected ? Colors.green : Colors.red,
                ),
                onPressed: () {
                  if (provider.isConnected) {
                    provider.disconnect();
                  } else {
                    provider.connect();
                  }
                },
                tooltip: provider.isConnected ? 'Disconnect' : 'Connect',
              );
            },
          ),
        ],
      ),
      body: Consumer<PowerProvider>(
        builder: (context, provider, _) {
          final status = provider.currentStatus;
          
          if (status == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Waiting for data...'),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StatusIndicator(
                  source: status.source,
                  isConnected: provider.isConnected,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: VoltageGauge(
                        title: 'Grid Voltage',
                        voltage: status.gridVoltage,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: VoltageGauge(
                        title: 'Generator Voltage',
                        voltage: status.generatorVoltage,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Load Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '${status.loadCurrent.toStringAsFixed(2)} A',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Current',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '${(status.loadPower / 1000).toStringAsFixed(2)} kW',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Power',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'System Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Status: ${status.status}'),
                        Text('Uptime: ${_formatUptime(status.uptime)}'),
                        Text('Last Update: ${status.timestamp}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Manual Control',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => provider.switchToGrid(),
                        icon: const Icon(Icons.power),
                        label: const Text('Switch to Grid'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => provider.switchToGenerator(),
                        icon: const Icon(Icons.electric_bolt),
                        label: const Text('Switch to Generator'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => provider.enableAutoMode(),
                    icon: const Icon(Icons.auto_mode),
                    label: const Text('Enable Auto Mode'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatUptime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hours}h ${minutes}m ${secs}s';
  }
}

