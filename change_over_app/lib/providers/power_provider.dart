import 'package:flutter/foundation.dart';
import '../models/power_status.dart';
import '../models/event_log.dart';
import '../services/mqtt_service.dart';

class PowerProvider with ChangeNotifier {
  final MQTTService _mqttService;
  
  PowerStatus? _currentStatus;
  List<EventLog> _events = [];
  bool _isConnected = false;
  
  PowerStatus? get currentStatus => _currentStatus;
  List<EventLog> get events => List.unmodifiable(_events);
  bool get isConnected => _isConnected;
  
  PowerProvider(this._mqttService) {
    _setupListeners();
  }
  
  void _setupListeners() {
    _mqttService.statusStream.listen((status) {
      _currentStatus = status;
      notifyListeners();
    });
    
    _mqttService.eventStream.listen((event) {
      _events.insert(0, event);
      if (_events.length > 100) {
        _events = _events.take(100).toList();
      }
      notifyListeners();
    });
    
    // Monitor connection status
    _isConnected = _mqttService.isConnected;
    notifyListeners();
  }
  
  Future<void> connect() async {
    final connected = await _mqttService.connect();
    _isConnected = connected;
    notifyListeners();
  }
  
  void disconnect() {
    _mqttService.disconnect();
    _isConnected = false;
    notifyListeners();
  }
  
  void switchToGrid() {
    _mqttService.switchToGrid();
  }
  
  void switchToGenerator() {
    _mqttService.switchToGenerator();
  }
  
  void enableAutoMode() {
    _mqttService.enableAutoMode();
  }
}

