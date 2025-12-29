import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/power_provider.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Log'),
      ),
      body: Consumer<PowerProvider>(
        builder: (context, provider, _) {
          final events = provider.events;

          if (events.isEmpty) {
            return const Center(
              child: Text('No events recorded yet'),
            );
          }

          return ListView.builder(
            itemCount: events.length,
            padding: const EdgeInsets.all(8.0),
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  leading: Icon(
                    _getEventIcon(event.eventType),
                    color: _getEventColor(event.eventType),
                  ),
                  title: Text(event.message),
                  subtitle: Text(event.timestamp),
                  trailing: Chip(
                    label: Text(
                      event.eventType,
                      style: const TextStyle(fontSize: 10),
                    ),
                    backgroundColor: _getEventColor(event.eventType).withOpacity(0.2),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getEventIcon(String eventType) {
    switch (eventType) {
      case 'SWITCH':
        return Icons.swap_horiz;
      case 'FAULT':
        return Icons.error;
      case 'ALERT':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

  Color _getEventColor(String eventType) {
    switch (eventType) {
      case 'SWITCH':
        return Colors.blue;
      case 'FAULT':
        return Colors.red;
      case 'ALERT':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

