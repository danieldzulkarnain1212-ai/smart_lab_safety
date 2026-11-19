import 'package:material_ui/material_ui.dart';
import '../models/sensor_data.dart';
import '../theme/app_theme.dart';
import '../widgets/live_sensor_builder.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // LiveSensorBuilder asks Firebase every 3 seconds and rebuilds this page.
    return LiveSensorBuilder(
      builder: (context, data) {
        return Scaffold(
          appBar: AppBar(title: const Text('Dashboard')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatusBanner(level: data.level, online: data.isOnline),
              const SizedBox(height: 16),
              _DeviceCard(data: data),
              if (data.fault)
                const Card(
                  color: AppColors.danger,
                  child: ListTile(
                    leading: Icon(Icons.warning, color: Colors.white),
                    title: Text(
                      'Sensor fault: DHT11 not responding',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              _ReadingCard(
                icon: Icons.thermostat,
                label: 'Temperature (DHT11)',
                value: '${data.temperature.toStringAsFixed(1)} °C',
              ),
              _ReadingCard(
                icon: Icons.water_drop,
                label: 'Humidity (DHT11)',
                value: '${data.humidity.toStringAsFixed(0)} %',
              ),
              _ReadingCard(
                icon: Icons.cloud,
                label: 'Gas / Smoke (MQ-2)',
                value: '${data.gas}',
              ),
              _ReadingCard(
                icon: Icons.light_mode,
                label: 'Light level (LDR)',
                value: '${data.light}',
              ),
              _ReadingCard(
                icon: Icons.air,
                label: 'Exhaust Fan',
                value: data.fanOn ? 'ON' : 'OFF',
              ),
              _ReadingCard(
                icon: Icons.volume_up,
                label: 'Buzzer',
                value: data.buzzerOn ? 'ON' : 'OFF',
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Big coloured banner showing NORMAL / WARNING / DANGER.
/// If the device is offline the banner goes grey, so an old status
/// is never shown as if it were current.
class _StatusBanner extends StatelessWidget {
  final SafetyLevel level;
  final bool online;
  const _StatusBanner({required this.level, required this.online});

  @override
  Widget build(BuildContext context) {
    final color = online ? AppColors.forLevel(level) : Colors.grey;
    final text = online ? level.name.toUpperCase() : 'OFFLINE';
    final subtitle = online
        ? 'Laboratory safety status'
        : 'No recent data from the ESP32. Its own safety logic still runs.';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            online ? Icons.shield : Icons.cloud_off,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

/// Shows whether the ESP32 is online and when it last sent data.
class _DeviceCard extends StatelessWidget {
  final SensorData data;
  const _DeviceCard({required this.data});

  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final t = data.timestamp;
    final time = '${_two(t.hour)}:${_two(t.minute)}:${_two(t.second)}';
    final color = data.isOnline ? AppColors.normal : AppColors.danger;

    return Card(
      child: ListTile(
        leading: Icon(Icons.memory, color: color),
        title: const Text('Device (ESP32)'),
        subtitle: Text('Last update: $time'),
        trailing: Text(
          data.isOnline ? 'ONLINE' : 'OFFLINE',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}

/// One row card showing a single reading.
class _ReadingCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ReadingCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}