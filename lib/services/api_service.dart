import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService extends GetConnect implements GetxService {
  final Logger _logger = Logger();

  @override
  void onInit() {
    httpClient.baseUrl = AppUrls.baseUrl;
    
    // Request interceptor (for headers/auth)
    httpClient.addRequestModifier<dynamic>((request) async {
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
      
      // Also check body content if statusCode wasn't 401 but message confirms session error
      if (!isSessionError && message != null) {
        if (message.toLowerCase().contains('invalid or expired session token') || 
            message.toLowerCase().contains('authentication required')) {
          isSessionError = true;
        }
      }

      if (response.hasError || isSessionError) {
        _logger.e('❌ API ERROR [$statusCode] $method $url');
        _logger.e('📦 RESPONSE BODY: $body');
        
        // Auto-logout on session error
        if (isSessionError) {
          _logger.w('⚠️ Session error detected. Triggering auto-logout.');
          try {
            if (Get.isRegistered<AuthController>()) {
              Get.find<AuthController>().logout(sessionExpired: true);
            } else {
              // Fallback if controller not registered
               Get.offAllNamed('/login'); // Or alternative direct navigation
            }
          } catch (e) {
            _logger.e('Failed to trigger auto-logout: $e');
          }
        }
      } else {
        _logger.i('✅ API SUCCESS [$statusCode] $method $url');
        _logger.d('📦 RESPONSE BODY: $body');
      }
      return response;
    });

    super.onInit();
  }

  void setToken(String token) {
    _logger.d('🔑 Setting Auth Token for API requests');
    httpClient.addRequestModifier<dynamic>((request) {
      request.headers['Authorization'] = 'Bearer $token';
      return request;
    });
  }

  void clearToken() {
    _logger.d('🔑 Clearing Auth Token');
    httpClient.addRequestModifier<dynamic>((request) {
      request.headers.remove('Authorization');
      return request;
    });
  }

  // Generic methods for common HTTP verbs
  Future<Response> getRequest(String path, {Map<String, dynamic>? query}) {
    final String fullUrl = '${httpClient.baseUrl}$path';
     _logger.i('🔍 GET REQUEST: $fullUrl');
    if (query != null) _logger.d('❓ QUERY PARAMS: $query');
    return get(path, query: query);
  }

  Future<Response> postRequest(String path, dynamic body) {
    final String fullUrl = '${httpClient.baseUrl}$path';
    _logger.i('📤 POST REQUEST: $fullUrl');
    _logger.d('📦 REQUEST BODY: $body');
    return post(path, body);
  }

  Future<Response> putRequest(String path, dynamic body) {
    final String fullUrl = '${httpClient.baseUrl}$path';
    _logger.i('📤 PUT REQUEST: $fullUrl');
    _logger.d('📦 REQUEST BODY: $body');
    return put(path, body);
  }

  Future<Response> deleteRequest(String path) {
    final String fullUrl = '${httpClient.baseUrl}$path';
    _logger.i('🗑️ DELETE REQUEST: $fullUrl');
    return delete(path);
  }
}
