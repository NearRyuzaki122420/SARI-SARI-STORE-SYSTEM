import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Android emulator:
  static const String baseUrl =
      'https://sari-sari-store-system.onrender.com/api';

  // Real phone example:
  // static const String baseUrl = 'http://192.168.1.5:5000/api';

  static Map<String, String> _headers([String? token]) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static dynamic _decode(http.Response response) {
    final dynamic data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    throw Exception(data['message'] ?? 'Request failed');
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    return Map<String, dynamic>.from(_decode(response));
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers(),
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    return Map<String, dynamic>.from(_decode(response));
  }

  static Future<List<dynamic>> getProducts(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: _headers(token),
    );
    return List<dynamic>.from(_decode(response));
  }

  static Future<List<dynamic>> getSales(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/sales'),
      headers: _headers(token),
    );
    return List<dynamic>.from(_decode(response));
  }

  static Future<List<dynamic>> getProfitReport(
    String token,
    String filter,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/sales/profit-report?filter=$filter'),
      headers: _headers(token),
    );
    return List<dynamic>.from(_decode(response));
  }

  static Future<Map<String, dynamic>> addProduct(
    String token,
    Map<String, dynamic> payload,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: _headers(token),
      body: jsonEncode(payload),
    );
    return Map<String, dynamic>.from(_decode(response));
  }

  static Future<Map<String, dynamic>> restockProduct(
    String token,
    int productId,
    Map<String, dynamic> payload,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/products/restock/$productId'),
      headers: _headers(token),
      body: jsonEncode(payload),
    );
    return Map<String, dynamic>.from(_decode(response));
  }

  static Future<Map<String, dynamic>> sellProduct(
    String token,
    int productId,
    int quantitySold,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/products/sold/$productId'),
      headers: _headers(token),
      body: jsonEncode({'quantity_sold': quantitySold}),
    );
    return Map<String, dynamic>.from(_decode(response));
  }

  static Future<Map<String, dynamic>> deleteProduct(
    String token,
    int productId,
  ) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/products/$productId'),
      headers: _headers(token),
    );
    return Map<String, dynamic>.from(_decode(response));
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
  final response = await http.post(
    Uri.parse('$baseUrl/auth/forgot-password'),
    headers: _headers(),
    body: jsonEncode({'email': email}),
  );
  return Map<String, dynamic>.from(_decode(response));
}

static Future<Map<String, dynamic>> resetPassword(String token, String newPassword) async {
  final response = await http.post(
    Uri.parse('$baseUrl/auth/reset-password'),
    headers: _headers(),
    body: jsonEncode({
      'token': token,
      'newPassword': newPassword,
    }),
  );
  return Map<String, dynamic>.from(_decode(response));
}
}
