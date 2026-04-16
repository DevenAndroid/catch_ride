import 'dart:convert';
import 'dart:developer';

import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/view/login_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService extends GetConnect implements GetxService {
  @override
  void onInit() {
    httpClient.baseUrl = AppUrls.baseUrl;
    httpClient.timeout = const Duration(seconds: 300);

    // Request interceptor (for headers/auth)
    httpClient.addRequestModifier<dynamic>((request) async {
      httpClient.timeout = const Duration(seconds: 300);
      return request;
    });

    // Add response interceptor
    httpClient.addResponseModifier((request, response) {
      final String url = request.url.toString();
      final int statusCode = response.statusCode ?? 0;
      final String method = request.method.toUpperCase();
      final dynamic body = response.body;

      // Extract message from body safely
      String? message;
      if (body is Map) {
        message = body['message']?.toString();
      }

      bool isSessionError = (statusCode == 401);

      // EXCEPTION: Don't trigger "Session Expired" on authentication paths
      // These endpoints return 401 for wrong credentials/invalid OTPs, not session expiry.
      if (url.toLowerCase().contains('/auth/')) {
        isSessionError = false;
      }

      // Also check body content if statusCode wasn't 401 but message confirms session error
      if (!isSessionError && message != null) {
        if (message.toLowerCase().contains(
              'invalid or expired session token',
            ) ||
            message.toLowerCase().contains('authentication required')) {
          isSessionError = true;
        }
      }

      if (response.hasError || isSessionError) {
        debugPrint('❌ API ERROR [$statusCode] $method $url');
        if (body != null) {
          try {
            debugPrint('📦 RESPONSE BODY: ${jsonEncode(body)}');
          } catch (_) {
            debugPrint('📦 RESPONSE BODY: $body');
          }
        }

        // Auto-logout on session error
        if (isSessionError) {
          debugPrint('⚠️ Session error detected. Triggering auto-logout.');
          _triggerAutoLogout();
        }
      } else {
        debugPrint('✅ API SUCCESS [$statusCode] $method $url');
        log('✅ API SUCCESS [$statusCode] ${jsonEncode(body)}');
      }
      return response;
    });

    super.onInit();
  }

  void setToken(String token) {
    debugPrint('🔑 Setting Auth Token for API requests');
    httpClient.addRequestModifier<dynamic>((request) {
      request.headers['Authorization'] = 'Bearer $token';
      return request;
    });
  }

  void clearToken() {
    debugPrint('🔑 Clearing Auth Token');
    httpClient.addRequestModifier<dynamic>((request) {
      request.headers.remove('Authorization');
      return request;
    });
  }

  // Helper to check token for non-auth paths
  Future<bool> _isAuthorized(String path) async {
    if (path.toLowerCase().contains('/auth/')) return true;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      debugPrint('Request to $path blocked: No auth token');
      await _triggerAutoLogout();
      return false;
    }
    return true;
  }

  Future<void> _triggerAutoLogout() async {
    try {
      if (Get.isRegistered<AuthController>()) {
        await Get.find<AuthController>().logout(sessionExpired: true);
      } else {
        // Fallback: Clear everything manually if controller is missing
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        clearToken();
        Get.offAll(() => const LoginView());
      }
    } catch (e) {
      debugPrint('Failed to trigger auto-logout: $e');
    }
  }

  // Generic methods with internal auth checks
  Future<Response> getRequest(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    if (!await _isAuthorized(path)) {
      return const Response(statusCode: 401, statusText: 'Unauthorized');
    }
    final String fullUrl = '${httpClient.baseUrl}$path';
    debugPrint('🔍 GET REQUEST: $fullUrl');
    if (query != null) debugPrint('❓ QUERY PARAMS: $query');
    return get(path, query: query);
  }

  Future<Response> postRequest(String path, dynamic body) async {
    if (!await _isAuthorized(path)) {
      return const Response(statusCode: 401, statusText: 'Unauthorized');
    }
    final String fullUrl = '${httpClient.baseUrl}$path';
    debugPrint('📤 POST REQUEST: $fullUrl');
    debugPrint('📦 REQUEST BODY: $body');
    return post(path, body);
  }

  Future<Response> putRequest(String path, dynamic body) async {
    if (!await _isAuthorized(path)) {
      return const Response(statusCode: 401, statusText: 'Unauthorized');
    }
    final String fullUrl = '${httpClient.baseUrl}$path';
    debugPrint('📤 PUT REQUEST: $fullUrl');
    debugPrint('📦 REQUEST BODY: ${jsonEncode(body)}');
    return put(path, body);
  }

  Future<Response> deleteRequest(String path) async {
    if (!await _isAuthorized(path)) {
      return const Response(statusCode: 401, statusText: 'Unauthorized');
    }
    final String fullUrl = '${httpClient.baseUrl}$path';
    debugPrint('🗑️ DELETE REQUEST: $fullUrl');
    return delete(path);
  }
}
