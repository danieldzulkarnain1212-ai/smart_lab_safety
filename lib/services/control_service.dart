import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ControlService {
  static const String _base =
      'https://smart-lab-safety-4371c-default-rtdb.asia-southeast1.firebasedatabase.app';

  /// Returns null on success, or an error message.
  static Future<String?> send({required bool auto, required bool fan}) async {
    final token = AuthService.idToken;
    if (token == null) return 'Not signed in.';
    try {
      final res = await http
          .put(
        Uri.parse('$_base/lab/control.json?auth=$token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mode': auto ? 'auto' : 'manual', 'fan': fan}),
      )
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) return null;
      if (res.statusCode == 401) {
        return 'Session expired. Log out and sign in again.';
      }
      return 'Command failed (${res.statusCode}).';
    } catch (_) {
      return 'No connection.';
    }
  }

  static Future<Map<String, dynamic>?> read() async {
    try {
      final res = await http
          .get(Uri.parse('$_base/lab/control.json'))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body);
      return data is Map<String, dynamic> ? data : null;
    } catch (_) {
      return null;
    }
  }
}