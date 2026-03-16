import 'package:get/get.dart';
import '../services/api_service.dart';

class BarnManagerController extends GetxController {
  final ApiService _apiService = Get.put(ApiService());
  
  var isLoading = false.obs;

  Future<bool> inviteBarnManager(String email) async {
    try {
      isLoading.value = true;
      final response = await _apiService.postRequest('/barn-managers/invite', {
        'email': email,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        String errorMsg = 'Failed to send invitation';
        if (response.body is Map && response.body['message'] != null) {
          errorMsg = response.body['message'];
        }
        Get.snackbar('Error', errorMsg);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
