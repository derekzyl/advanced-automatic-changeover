class PowerStatus {
  final String timestamp;
  final String source; // "GRID", "GENERATOR", "NONE"
  final double gridVoltage;
  final double generatorVoltage;
  final double loadCurrent;
  final double loadPower;
  final String status; // "NORMAL", "FAULT", "WARNING"
  final int uptime;

  PowerStatus({
    required this.timestamp,
    required this.source,
    required this.gridVoltage,
    required this.generatorVoltage,
    required this.loadCurrent,
    required this.loadPower,
    required this.status,
    required this.uptime,
  });

  factory PowerStatus.fromJson(Map<String, dynamic> json) {
    return PowerStatus(
      timestamp: json['timestamp'] ?? '',
      source: json['source'] ?? 'NONE',
      gridVoltage: (json['grid_voltage'] ?? 0.0).toDouble(),
      generatorVoltage: (json['generator_voltage'] ?? 0.0).toDouble(),
      loadCurrent: (json['load_current'] ?? 0.0).toDouble(),
      loadPower: (json['load_power'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'NORMAL',
      uptime: json['uptime'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'source': source,
      'grid_voltage': gridVoltage,
      'generator_voltage': generatorVoltage,
      'load_current': loadCurrent,
      'load_power': loadPower,
      'status': status,
      'uptime': uptime,
    };
  }
}

