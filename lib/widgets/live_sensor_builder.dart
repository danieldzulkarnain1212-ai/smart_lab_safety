import 'dart:async';
import 'package:material_ui/material_ui.dart';
import '../models/sensor_data.dart';
import '../services/lab_service.dart';

/// Asks Firebase for the newest reading every 3 seconds and rebuilds
/// the screen inside [builder] with it.
class LiveSensorBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, SensorData data) builder;

  const LiveSensorBuilder({super.key, required this.builder});

  @override
  State<LiveSensorBuilder> createState() => _LiveSensorBuilderState();
}

class _LiveSensorBuilderState extends State<LiveSensorBuilder> {
  SensorData? _data;
  String? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel(); // stop asking when the screen is closed
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await LabService.fetchLatest();
      if (!mounted) return;
      setState(() {
        _data = data;
        _error = data == null ? 'No data in Firebase yet' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Cannot reach Firebase. Check the internet.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    if (data != null) return widget.builder(context, data);

    // Nothing to show yet: loading or error message.
    return Scaffold(
      body: Center(
        child: _error == null
            ? const CircularProgressIndicator()
            : Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error!, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}