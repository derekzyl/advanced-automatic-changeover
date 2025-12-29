class EventLog {
  final String timestamp;
  final String eventType;
  final String message;

  EventLog({
    required this.timestamp,
    required this.eventType,
    required this.message,
  });

  factory EventLog.fromJson(Map<String, dynamic> json) {
    return EventLog(
      timestamp: json['timestamp'] ?? '',
      eventType: json['event_type'] ?? 'UNKNOWN',
      message: json['event_data'] != null 
          ? (json['event_data']['message'] ?? '') 
          : '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'event_type': eventType,
      'event_data': {'message': message},
    };
  }
}

