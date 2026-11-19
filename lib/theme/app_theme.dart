import 'package:material_ui/material_ui.dart';

/// The three safety levels used all over the app.
enum SafetyLevel { normal, warning, danger }

/// Central place for all colours.
class AppColors {
  static const Color normal = Color(0xFF2E9E5B);   // green
  static const Color warning = Color(0xFFF5A524);  // amber
  static const Color danger = Color(0xFFE5484D);   // red
  static const Color primary = Color(0xFF1F6FEB);  // blue, brand colour
  static const Color background = Color(0xFFF4F6FA);
  static const Color textDark = Color(0xFF1B2430);

  /// Returns the colour that matches a safety level.
  static Color forLevel(SafetyLevel level) {
    switch (level) {
      case SafetyLevel.normal:
        return normal;
      case SafetyLevel.warning:
        return warning;
      case SafetyLevel.danger:
        return danger;
    }
  }
}

/// The theme used by the whole app.
class AppTheme {
  static ThemeData light() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
    );
  }
}

/// Limits that match the ESP32 sketch (safety_logic).
/// Calibrated for this sensor, this room and the MQ-2 on 3.3V.
/// Educational prototype, not a certified safety system.
/// A level starts AT the limit (>=), the same as the ESP32.
class Thresholds {
  // DHT11 (reads 0 to 50 °C, about ±2 °C accuracy)
  static const double tempWarning = 32;
  static const double tempDanger = 38;

  // MQ-2 on 3.3V (clean air about 80 to 90, gas up to about 260)
  static const int gasWarning = 150;
  static const int gasDanger = 230;

  // Only used to scale the progress bars on the Live screen.
  static const double tempBarMax = 50; // DHT11 upper range
  static const double gasBarMax = 400; // so 260 visibly fills the bar
  static const double lightBarMax = 4095; // ESP32 12-bit maximum
}
