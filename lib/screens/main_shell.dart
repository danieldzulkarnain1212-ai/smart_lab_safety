import 'package:material_ui/material_ui.dart';
import 'dashboard_screen.dart';
import 'live_screen.dart';
import 'controls_screen.dart';
import 'package:smart_lab_safety/screens/history_screen.dart';
import 'package:smart_lab_safety/screens/alerts_screen.dart';

/// The main screen that holds the bottom navigation bar.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0; // which tab is selected

  // One page per tab. The order must match the bar below.
  final List<Widget> _pages = const [
    DashboardScreen(),
    LiveScreen(),
    ControlsScreen(),
    HistoryScreen(),
    AlertsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps every page alive, so switching tabs is fast.
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(icon: Icon(Icons.sensors), label: 'Live'),
          NavigationDestination(icon: Icon(Icons.toggle_on), label: 'Controls'),
          NavigationDestination(icon: Icon(Icons.show_chart), label: 'History'),
          NavigationDestination(
            icon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
        ],
      ),
    );
  }
}
