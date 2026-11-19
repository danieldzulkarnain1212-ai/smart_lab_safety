import 'package:material_ui/material_ui.dart';

import '../models/sensor_data.dart';
import '../services/lab_service.dart'; // change to lab_services.dart if that is your file name
import '../theme/app_theme.dart';

/// Shows only the WARNING and DANGER readings, newest first.
class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  late Future<List<SensorData>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<SensorData>> _load() async {
    final list = await LabService.fetchHistory(limit: 200);
    return list
        .where((d) => d.level != SafetyLevel.normal)
        .toList()
        .reversed
        .toList(); // newest first
  }

  Future<void> _refresh() async {
    final next = _load();
    setState(() => _future = next);
    try {
      await next;
    } catch (_) {
      // The error is shown by the FutureBuilder.
    }
  }

  // Same limits as the ESP32 sketch.
  String _cause(SensorData d) {
    final causes = <String>[];
    if (d.fault) causes.add('Temperature sensor fault');
    if (d.gas >= 230) {
      causes.add('Gas very high (${d.gas})');
    } else if (d.gas >= 150) {
      causes.add('Gas high (${d.gas})');
    }
    if (d.temperature >= 38) {
      causes.add('Temperature very high (${d.temperature.toStringAsFixed(1)} °C)');
    } else if (d.temperature >= 32) {
      causes.add('Temperature high (${d.temperature.toStringAsFixed(1)} °C)');
    }
    if (causes.isEmpty) causes.add('Level changed');
    return causes.join(' · ');
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  String _time(DateTime t) =>
      '${_two(t.day)}/${_two(t.month)}  ${_two(t.hour)}:${_two(t.minute)}:${_two(t.second)}';

  Widget _message(IconData icon, String text, {VoidCallback? onRetry}) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Icon(icon, size: 48, color: Colors.grey),
        const SizedBox(height: 12),
        Text(text, textAlign: TextAlign.center),
        if (onRetry != null) ...[
          const SizedBox(height: 12),
          Center(
            child: OutlinedButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _summary(List<SensorData> items) {
    final danger = items.where((d) => d.level == SafetyLevel.danger).length;
    final warning = items.length - danger;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          Expanded(child: _countCard('DANGER', danger, Colors.red)),
          const SizedBox(width: 10),
          Expanded(child: _countCard('WARNING', warning, Colors.orange)),
        ],
      ),
    );
  }

  Widget _countCard(String label, int count, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(SensorData d) {
    final isDanger = d.level == SafetyLevel.danger;
    final color = isDanger ? Colors.red : Colors.orange;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: ListTile(
        leading: Icon(
          isDanger ? Icons.warning_amber_rounded : Icons.error_outline,
          color: color,
          size: 32,
        ),
        title: Text(
          '${isDanger ? 'DANGER' : 'WARNING'}: ${_cause(d)}',
          style: TextStyle(fontWeight: FontWeight.w600, color: color),
        ),
        subtitle: Text(
          '${_time(d.timestamp)}\n'
              'Fan ${d.fanOn ? 'ON' : 'OFF'} · Buzzer ${d.buzzerOn ? 'ON' : 'OFF'}',
        ),
        isThreeLine: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alerts')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<SensorData>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _message(
                Icons.cloud_off,
                'Cannot load alerts.\nCheck the internet connection.',
                onRetry: _refresh,
              );
            }
            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return _message(
                Icons.check_circle_outline,
                'No alerts. Everything has been NORMAL.',
              );
            }
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 8),
              itemCount: items.length + 1,
              itemBuilder: (context, i) =>
              i == 0 ? _summary(items) : _row(items[i - 1]),
            );
          },
        ),
      ),
    );
  }
}