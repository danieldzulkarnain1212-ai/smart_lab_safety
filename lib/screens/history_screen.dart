import 'package:material_ui/material_ui.dart';
import '../models/sensor_data.dart';
import '../services/lab_service.dart'; // change to lab_service.dart if that is your file name
import '../theme/app_theme.dart';

/// Lists the last saved readings, newest first.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<SensorData>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<SensorData>> _load() async {
    final list = await LabService.fetchHistory(limit: 30);
    return list.reversed.toList(); // newest first
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

  Color _color(SafetyLevel level) {
    switch (level) {
      case SafetyLevel.normal:
        return Colors.green;
      case SafetyLevel.danger:
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _label(SafetyLevel level) {
    switch (level) {
      case SafetyLevel.normal:
        return 'NORMAL';
      case SafetyLevel.danger:
        return 'DANGER';
      default:
        return 'WARNING';
    }
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

  Widget _row(SensorData d) {
    final color = _color(d.level);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 6, color: color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _time(d.timestamp),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _label(d.level),
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 14,
                      runSpacing: 4,
                      children: [
                        Text('${d.temperature.toStringAsFixed(1)} °C'),
                        Text('${d.humidity.toStringAsFixed(0)} %'),
                        Text('Gas ${d.gas}'),
                        Text('Light ${d.light}'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.air,
                          size: 16,
                          color: d.fanOn ? Colors.blue : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(d.fanOn ? 'Fan ON' : 'Fan OFF'),
                        const SizedBox(width: 14),
                        Icon(
                          Icons.notifications_active,
                          size: 16,
                          color: d.buzzerOn ? Colors.red : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(d.buzzerOn ? 'Buzzer ON' : 'Buzzer OFF'),
                        if (d.fault) ...[
                          const SizedBox(width: 14),
                          const Text(
                            'DHT FAULT',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
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
                'Cannot load history.\nCheck the internet connection.',
                onRetry: _refresh,
              );
            }
            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return _message(Icons.history, 'No readings saved yet.');
            }
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              itemBuilder: (context, i) => _row(items[i]),
            );
          },
        ),
      ),
    );
  }
}