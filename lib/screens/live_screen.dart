import 'package:material_ui/material_ui.dart';
import '../theme/app_theme.dart';
import '../widgets/live_sensor_builder.dart';

class LiveScreen extends StatelessWidget {
  const LiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LiveSensorBuilder(
      builder: (context, data) => Scaffold(
        appBar: AppBar(title: const Text('Live Monitoring')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SensorGauge(
              icon: Icons.thermostat,
              label: 'Temperature (DHT11)',
              valueText: '${data.temperature.toStringAsFixed(1)} °C',
              progress: data.temperature / Thresholds.tempBarMax,
              color: _colorFor(
                data.temperature,
                Thresholds.tempWarning,
                Thresholds.tempDanger,
              ),
              note: 'Warning at ${Thresholds.tempWarning.toInt()} °C and above, '
                  'danger at ${Thresholds.tempDanger.toInt()} °C and above',
            ),
            _SensorGauge(
              icon: Icons.water_drop,
              label: 'Humidity (DHT11)',
              valueText: '${data.humidity.toStringAsFixed(0)} %',
              progress: data.humidity / 100,
              color: AppColors.primary,
              note: 'Informational only, no safety limit',
            ),
            _SensorGauge(
              icon: Icons.cloud,
              label: 'Gas / Smoke (MQ-2)',
              valueText: '${data.gas}',
              progress: data.gas / Thresholds.gasBarMax,
              color: _colorFor(
                data.gas.toDouble(),
                Thresholds.gasWarning.toDouble(),
                Thresholds.gasDanger.toDouble(),
              ),
              note: 'Warning at ${Thresholds.gasWarning} and above, '
                  'danger at ${Thresholds.gasDanger} and above',
            ),
            _SensorGauge(
              icon: Icons.light_mode,
              label: 'Light level (LDR)',
              valueText: '${data.light}',
              progress: data.light / Thresholds.lightBarMax,
              color: AppColors.primary,
              note: 'Informational only. Higher number means more light',
            ),
          ],
        ),
      ),
    );
  }

  /// Picks green, amber or red from a value and two limits.
  /// A level starts AT the limit (>=), the same as the ESP32.
  static Color _colorFor(double value, double warning, double danger) {
    if (value >= danger) return AppColors.danger;
    if (value >= warning) return AppColors.warning;
    return AppColors.normal;
  }
}

/// A card with a value and a progress bar.
class _SensorGauge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valueText;
  final double progress; // 0.0 to 1.0
  final Color color;
  final String note;

  const _SensorGauge({
    required this.icon,
    required this.label,
    required this.valueText,
    required this.progress,
    required this.color,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(fontSize: 16)),
                const Spacer(),
                Text(
                  valueText,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 10,
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 8),
            Text(note, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}