import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sensor_data.dart';

/// Talks to the Firebase Realtime Database over its REST address.
/// The ESP32 writes the data, the app only reads it here.
class LabService {
  // Database host (no https://, no trailing slash).
  static const String _host =
      'smart-lab-safety-4371c-default-rtdb.asia-southeast1.firebasedatabase.app';

  /// The newest reading, or null if the database is still empty.
  static Future<SensorData?> fetchLatest() async {
    final uri = Uri.https(_host, '/lab/latest.json');
    final response = await http.get(uri).timeout(const Duration(seconds: 6));
    if (response.statusCode != 200) {
      throw Exception('Firebase error ${response.statusCode}');
    }
    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) return null;
    return SensorData.fromJson(body);
  }

  /// The last [limit] saved readings, oldest first (used by History).
  static Future<List<SensorData>> fetchHistory({int limit = 30}) async {
    final uri = Uri.https(_host, '/lab/history.json', {
      'orderBy': '"\$key"',
      'limitToLast': '$limit',
    });
    final response = await http.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw Exception('Firebase error ${response.statusCode}');
    }
    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) return [];
    final list = body.values
        .whereType<Map<String, dynamic>>()
        .map(SensorData.fromJson)
        .toList();
    list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return list;
  }
}