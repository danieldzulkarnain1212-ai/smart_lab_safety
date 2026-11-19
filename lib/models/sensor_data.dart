import '../theme/app_theme.dart';

/// One snapshot of everything the ESP32 reports.
class SensorData {
  final double temperature; // degrees Celsius (DHT11)
  final double humidity; // percent (DHT11)
  final int gas; // raw MQ-2 value; about 80 to 90 in clean air on 3.3V
  final int light; // raw LDR value, 0 to 4095; higher = more light
  final bool fanOn;
  final bool buzzerOn;
  final bool fault; // true = the DHT11 stopped responding
  final SafetyLevel level; // decided by the ESP32, the app only shows it
  final DateTime timestamp; // server time when the ESP32 sent this

  const SensorData({
    required this.temperature,
    required this.humidity,
    required this.gas,
    required this.light,
    required this.fanOn,
    required this.buzzerOn,
    required this.level,
    required this.timestamp,
    this.fault = false,
  });

  /// The device counts as online if it sent data in the last 30 seconds.
  /// (The ESP32 sends every 5 seconds.)
  bool get isOnline =>
      DateTime.now().difference(timestamp).abs() < const Duration(seconds: 30);

  /// Builds one reading from the data Firebase sends back.
  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      temperature: (json['temp'] as num?)?.toDouble() ?? 0,
      humidity: (json['hum'] as num?)?.toDouble() ?? 0,
      gas: (json['gas'] as num?)?.toInt() ?? 0,
      light: (json['light'] as num?)?.toInt() ?? 0,
      fanOn: json['fan'] == true,
      buzzerOn: json['buzzer'] == true,
      fault: json['fault'] == true,
      level: _levelFromText(json['status'] as String?),
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (json['ts'] as num?)?.toInt() ?? 0,
      ),
    );
  }

  /// Turns the ESP32's text into a SafetyLevel.
  /// Anything unknown is treated as WARNING, to be on the safe side.
  static SafetyLevel _levelFromText(String? text) {
    switch (text) {
      case 'NORMAL':
        return SafetyLevel.normal;
      case 'DANGER':
        return SafetyLevel.danger;
      default:
        return SafetyLevel.warning;
    }
  }

  /// A normal, safe example reading (kept for testing the screens).
  static SensorData fakeNormal() => SensorData(
    temperature: 29.2,
    humidity: 70,
    gas: 90,
    light: 3000,
    fanOn: false,
    buzzerOn: false,
    level: SafetyLevel.normal,
    timestamp: DateTime.now(),
  );
}