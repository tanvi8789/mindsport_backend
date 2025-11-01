import 'dart:convert';
import 'dart:io'; // Needed for SocketException
import 'dart:async'; // Needed for TimeoutException
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  // This is the correct, final base URL.
  final String _baseUrl = "https://mindsport-backend.onrender.com";

  final _storage = const FlutterSecureStorage();
  final String _tokenKey = 'auth_token';
  final _timeoutDuration = const Duration(seconds: 20);

  // Helper to get headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: _tokenKey);
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // --- GENERIC METHODS ---

  /// Generic GET request.
  /// Returns 'dynamic' because the response could be a Map (a single object)
  /// or a List (an array of objects).
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api$endpoint'),
        headers: await _getHeaders(),
      ).timeout(_timeoutDuration);

      return _handleResponse(response);

    } on SocketException {
      return {'error': 'Connection error', 'message': 'Could not connect to the server.'};
    } on TimeoutException {
      return {'error': 'Timeout', 'message': 'The server took too long to respond.'};
    } catch (e) {
      return {'error': 'Unknown error', 'message': 'An unexpected error occurred: $e'};
    }
  }

  /// Generic POST request.
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api$endpoint'),
        headers: await _getHeaders(),
        body: jsonEncode(data),
      ).timeout(_timeoutDuration);

      return _handleResponse(response);

    } on SocketException {
      return {'error': 'Connection error', 'message': 'Could not connect to the server.'};
    } on TimeoutException {
      return {'error': 'Timeout', 'message': 'The server took too long to respond.'};
    } catch (e) {
      return {'error': 'Unknown error', 'message': 'An unexpected error occurred: $e'};
    }
  }

  /// --- UPDATED: Generic PUT request ---
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api$endpoint'),
        headers: await _getHeaders(),
        body: jsonEncode(data),
      ).timeout(_timeoutDuration);

      return _handleResponse(response);

    } on SocketException {
      return {'error': 'Connection error', 'message': 'Could not connect to the server.'};
    } on TimeoutException {
      return {'error': 'Timeout', 'message': 'The server took too long to respond.'};
    } catch (e) {
      return {'error': 'Unknown error', 'message': 'An unexpected error occurred: $e'};
    }
  }

  /// --- NEW: Generic DELETE request ---
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api$endpoint'),
        headers: await _getHeaders(),
      ).timeout(_timeoutDuration);

      return _handleResponse(response);

    } on SocketException {
      return {'error': 'Connection error', 'message': 'Could not connect to the server.'};
    } on TimeoutException {
      return {'error': 'Timeout', 'message': 'The server took too long to respond.'};
    } catch (e) {
      return {'error': 'Unknown error', 'message': 'An unexpected error occurred: $e'};
    }
  }

  // --- Centralized Response Handler ---
  dynamic _handleResponse(http.Response response) {
    // Try to decode the body
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (e) {
      // If decoding fails (e.g., HTML error page), create a JSON error.
      body = {
        'error': 'Invalid Response',
        'message': 'Received an invalid response from the server (Status code: ${response.statusCode})',
      };
    }

    // If the status code is bad, return an error map
    if (response.statusCode < 200 || response.statusCode >= 300) {
      // If the body already has an error message, use it.
      if (body is Map && body['message'] != null) {
        return {'error': body['error'] ?? 'Server Error', 'message': body['message']};
      }
      // Otherwise, create a generic one.
      return {
        'error': 'Server Error',
        'message': 'Server responded with code ${response.statusCode} (Not JSON)',
      };
    }

    // If we're here, the call was successful. Return the decoded body.
    return body;
  }
}

