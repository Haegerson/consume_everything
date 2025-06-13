import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  String? _token;

  ApiClient({required this.baseUrl, String? token}) : _token = token;

  set token(String? t) => _token = t;

  Map<String, String> get _headers {
    final h = {'Content-Type': 'application/json'};
    if (_token != null) h['Authorization'] = 'Bearer $_token';
    return h;
  }

  Future<http.Response> get(String path, {Map<String, String>? qParams}) {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: qParams);
    return http.get(uri, headers: _headers);
  }

  Future<http.Response> post(String path, {Object? body}) => http.post(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
        body: jsonEncode(body),
      );
  Future<http.Response> put(String path, {Object? body}) => http.put(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
        body: jsonEncode(body),
      );
  Future<http.Response> delete(String path) => http.delete(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
      );
}
