import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _apiKey = 'AIzaSyAnhNOmrRq1PP7oMbCEVInHn2NMm8DpJ7k';
  static String? idToken;
  static String? email;

  static Future<String?> signIn(String mail, String password) async {
    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_apiKey',
    );
    try {
      final res = await http
          .post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': mail,
          'password': password,
          'returnSecureToken': true,
        }),
      )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) {
        idToken = data['idToken'];
        email = data['email'];
        return null; // success
      }
      final code = (data['error']?['message'] ?? '').toString();
      if (code.contains('INVALID_LOGIN_CREDENTIALS') ||
          code.contains('INVALID_PASSWORD') ||
          code.contains('EMAIL_NOT_FOUND')) {
        return 'Wrong email or password.';
      }
      if (code.contains('INVALID_EMAIL')) return 'Invalid email format.';
      if (code.contains('TOO_MANY_ATTEMPTS')) {
        return 'Too many attempts. Try again later.';
      }
      return 'Sign-in failed ($code).';
    } on SocketException {
      return 'No internet connection.';
    } catch (_) {
      return 'Request timed out. Check your connection.';
    }
  }

  static void signOut() {
    idToken = null;
    email = null;
  }
}