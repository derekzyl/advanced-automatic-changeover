import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../models/power_status.dart';
import '../models/event_log.dart';

class MQTTService {
  late MqttServerClient client;
  final String broker;
  final int port;
  final String clientId;
  
  final StreamController<PowerStatus> _statusController = StreamController<PowerStatus>.broadcast();
  final StreamController<EventLog> _eventController = StreamController<EventLog>.broadcast();
  
  Stream<PowerStatus> get statusStream => _statusController.stream;
  Stream<EventLog> get eventStream => _eventController.stream;
  
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  MQTTService({
    this.broker = '192.168.1.100',
    this.port = 1883,
    this.clientId = 'flutter_changeover_app',
  }) {
    client = MqttServerClient.withPort(broker, clientId, port);
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;
  }

  Future<bool> connect() async {
    try {
      print('Connecting to MQTT broker: $broker:$port');
      await client.connect();
      
      if (client.connectionStatus?.state == MqttConnectionState.connected) {
        _isConnected = true;
        subscribeToTopics();
        listenToMessages();
        return true;
      }
      return false;
    } catch (e) {
      print('MQTT connection error: $e');
      return false;
    }
  }

  void disconnect() {
    client.disconnect();
    _isConnected = false;
  }

  void onConnected() {
    print('MQTT Connected');
    _isConnected = true;
  }

  void onDisconnected() {
    print('MQTT Disconnected');
    _isConnected = false;
  }

  void onSubscribed(String topic) {
    print('Subscribed to: $topic');
  }

  void subscribeToTopics() {
    client.subscribe('changeover/status', MqttQos.atLeastOnce);
    client.subscribe('changeover/events', MqttQos.atLeastOnce);
  }

  void listenToMessages() {
    client.updates?.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final topic = c[0].topic;
      final message = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      
      print('Received message: $topic - $message');
      
      try {
        final jsonData = jsonDecode(message);
        
        if (topic == 'changeover/status') {
          final status = PowerStatus.fromJson(jsonData);
          _statusController.add(status);
        } else if (topic == 'changeover/events') {
          final event = EventLog.fromJson(jsonData);
          _eventController.add(event);
        }
      } catch (e) {
        print('Error parsing message: $e');
      }
    });
  }

  void publishCommand(String command) {
    if (!_isConnected) {
      print('MQTT not connected, cannot publish command');
      return;
    }
    
    final builder = MqttClientPayloadBuilder();
    builder.addString(command);
    
    client.publishMessage(
      'changeover/control',
      MqttQos.atLeastOnce,
      builder.payload!,
    );
    
    print('Published command: $command');
  }

  void switchToGrid() {
    publishCommand('GRID');
  }

  void switchToGenerator() {
    publishCommand('GENERATOR');
  }

  void enableAutoMode() {
    publishCommand('AUTO');
  }
}

