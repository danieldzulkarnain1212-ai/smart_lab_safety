import 'package:material_ui/material_ui.dart';
import '../services/auth_service.dart';
import '../services/control_service.dart';
import '../theme/app_theme.dart';
import '../widgets/live_sensor_builder.dart';
import 'login_screen.dart';

class ControlsScreen extends StatefulWidget {
  const ControlsScreen({super.key});

  @override
  State<ControlsScreen> createState() => _ControlsScreenState();
}

class _ControlsScreenState extends State<ControlsScreen> {
  bool _autoMode = true; // true = automatic, false = manual
  bool _fanOn = false; // what the user asked for in manual mode
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final c = await ControlService.read();
    if (c != null && mounted) {
      setState(() {
        _autoMode = c['mode'] != 'manual';
        _fanOn = c['fan'] == true;
      });
    }
  }

  Future<void> _push({required bool auto, required bool fan}) async {
    final prevAuto = _autoMode;
    final prevFan = _fanOn;
    setState(() {
      _autoMode = auto;
      _fanOn = fan;
      _sending = true;
    });
    final err = await ControlService.send(auto: auto, fan: fan);
    if (!mounted) return;
    setState(() {
      _sending = false;
      if (err != null) {
        _autoMode = prevAuto;
        _fanOn = prevFan;
      }
    });
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LiveSensorBuilder(
      builder: (context, data) {
        // In an emergency the manual switch is locked.
        final emergency = data.level == SafetyLevel.danger;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Controls'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Log out',
                onPressed: () {
                  AuthService.signOut();
                  Navigator.of(context, rootNavigator: true)
                      .pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (_) => false,
                  );
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (emergency)
                Card(
                  color: AppColors.danger,
                  child: const ListTile(
                    leading: Icon(Icons.warning, color: Colors.white),
                    title: Text(
                      'Emergency: safety system is in control',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              Card(
                child: SwitchListTile(
                  title: const Text('Automatic safety mode'),
                  subtitle: Text(
                    _autoMode
                        ? 'The ESP32 controls the fan by itself'
                        : 'Manual mode. Safety still overrides in danger',
                  ),
                  value: _autoMode,
                  onChanged: (emergency || _sending)
                      ? null
                      : (value) => _push(
                    auto: value,
                    fan: value ? _fanOn : data.fanOn,
                  ),
                ),
              ),
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.air),
                  title: const Text('Exhaust fan'),
                  subtitle: Text(
                    _autoMode
                        ? 'Switch to manual mode to control it'
                        : (_fanOn ? 'Running' : 'Stopped'),
                  ),
                  value: _autoMode ? data.fanOn : _fanOn,
                  onChanged: (_autoMode || emergency || _sending)
                      ? null
                      : (value) => _push(auto: false, fan: value),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.volume_up),
                  title: const Text('Buzzer'),
                  subtitle: const Text('Controlled automatically for safety'),
                  trailing: Text(
                    data.buzzerOn ? 'ON' : 'OFF',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}