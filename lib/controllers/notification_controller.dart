import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/models/notification_model.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class NotificationController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final Logger _logger = Logger();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      final response = await _apiService.getRequest(AppUrls.notifications);

      if (response.statusCode == 200) {
        final List data = response.body['data'] ?? [];
        notifications.assignAll(
          data.map((e) => NotificationModel.fromJson(e)).toList(),
        );
        _updateUnreadCount();
        _logger.i('Fetched ${notifications.length} notifications');
      } else {
        _logger.e('Failed to fetch notifications: ${response.statusText}');
      }
    } catch (e) {
      _logger.e('Error fetching notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.read).length;
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await _apiService.putRequest(
        '${AppUrls.notifications}/$notificationId/read',
        {},
      );
      if (response.statusCode == 200) {
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          notifications[index] = NotificationModel.fromJson(
            response.body['data'],
          );
          _updateUnreadCount();
        }
      }
    } catch (e) {
      _logger.e('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await _apiService.putRequest(
        '${AppUrls.notifications}/read-all',
        {},
      );
      if (response.statusCode == 200) {
        await fetchNotifications();
      }
    } catch (e) {
      _logger.e('Error marking all notifications as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      final response = await _apiService.deleteRequest(
        '${AppUrls.notifications}/$notificationId',
      );
      if (response.statusCode == 200) {
        notifications.removeWhere((n) => n.id == notificationId);
        _updateUnreadCount();
      }
    } catch (e) {
      _logger.e('Error deleting notification: $e');
    }
  }
}
