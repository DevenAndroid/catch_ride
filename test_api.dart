import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🧪 Starting Login API Integration Test...');
  
  const String url = 'http://localhost:5000/api/auth/login';
  final Map<String, String> body = {
    'email': 'dev@test.com',
    'password': 'password123',
  };

  try {
    print('🚀 Sending POST request to: $url');
    print('📦 Payload: $body');

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    print('✅ Status Code: ${response.statusCode}');
    print('📝 Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['data']['token'];
      final userEmail = data['data']['user']['email'];
      
      print('--- Verification Result ---');
      print('✅ Token received: $token');
      print('✅ User Email: $userEmail');
      print('🏆 Integration Test PASSED');
    } else {
      print('❌ Integration Test FAILED with status: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error during test: $e');
  }
}
