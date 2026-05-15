import 'package:catch_ride/services/api_service.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class SystemConfigController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxList<dynamic> regions = <dynamic>[].obs;
  final RxBool isLoadingRegions = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRegions();
  }

  Future<void> fetchRegions() async {
    try {
      isLoadingRegions.value = true;
      final response = await _apiService.getRequest('/system-config/regions?isActive=true');
      if (response.statusCode == 200 && response.body['success'] == true) {
        regions.assignAll(response.body['data']);
      }
    } catch (e) {
      debugPrint('Error fetching regions: $e');
    } finally {
      isLoadingRegions.value = false;
    }
  }

  List<String> get regionNames => regions
      .map((e) => (e['region'] ?? e['label'] ?? e['name'] ?? '').toString())
      .where((s) => s.isNotEmpty)
      .toList();
}
