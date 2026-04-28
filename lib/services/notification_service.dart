import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/view/trainer/chats/single_chat_view.dart';
import 'package:catch_ride/view/barn_manager/chats/barn_manager_single_chat_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger();

  Future<NotificationService> init() async {
    // 1. Request Permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      _logger.i('User granted permission');
    } else {
      _logger.w('User declined or has not accepted permission');
    }

    // 2. Setup Local Notifications for Foreground
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Create Android Notification Channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          try {
            final data = jsonDecode(details.payload!);
            _navigateToChat(data);
          } catch (e) {
            _logger.e('Error parsing notification payload: $e');
          }
        }
      },
    );

    // 3. Listen for Messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 4. Get FCM Token and Update Backend
    await updateToken();

    // 5. Clear Badge
    await clearBadge();

    _logger.i('Notification Service Initialized Successfully');
    return this;
  }

  Future<void> updateToken() async {
    try {
      // On iOS, we must have an APNS token before requesting the FCM token.
      // This is often null on simulators or before the user has fully registered.
      if (Platform.isIOS) {
        final apnsToken = await _fcm.getAPNSToken();
        if (apnsToken == null) {
          _logger.w('APNS token not yet available. Skipping FCM token update.');
          return;
        }
      }

      String? token = await _fcm.getToken();
      if (token != null) {
        _logger.i('FCM Token: $token');
        
        final authController = Get.find<AuthController>();
        if (authController.isLoggedIn.value) {
           await Get.find<ApiService>().putRequest('/users/update-token', {
            'fcmToken': token,
            'platform': Platform.isAndroid ? 'android' : 'ios'
          });
          _logger.i('FCM Token updated on backend');
        }
      }
    } catch (e) {
      _logger.e('Error updating FCM token: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    _logger.i('=========================================');
    _logger.i('[FCM] Foreground Message Received!');
    _logger.i('[FCM] Data: ${message.data}');
    _logger.i('[FCM] Notification: ${message.notification?.title}');
    _logger.i('=========================================');
    
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    Map<String, dynamic> data = message.data;

    // Even if notification object is null, try to show it from data if possible
    String? title = notification?.title ?? data['title'] ?? 'New Message';
    String? body = notification?.body ?? data['body'] ?? data['content'] ?? '';

    if (title != null) {
      _localNotifications.show(
        notification.hashCode,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: false,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    _logger.i('Message opened app: ${message.notification?.title}');
    _navigateToChat(message.data);
  }

  void _navigateToChat(Map<String, dynamic> data) {
    if (data['type'] == 'message' && data['conversationId'] != null) {
      final String conversationId = data['conversationId'];
      final String senderId = data['senderId'] ?? '';
      final String senderName = data['senderName'] ?? 'Chat';
      final String senderImage = data['senderImage'] ?? '';

      final authController = Get.find<AuthController>();
      final String role = authController.currentUser.value?.role ?? '';

      if (role == 'barn_manager') {
        Get.to(() => BarnManagerSingleChatView(
          name: senderName,
          image: senderImage,
          conversationId: conversationId,
          otherId: senderId,
        ));
      } else {
        Get.to(() => SingleChatView(
          name: senderName,
          image: senderImage,
          conversationId: conversationId,
          otherId: senderId,
        ));
      }
    }
  }

  Future<void> clearBadge() async {
    try {
      if (Platform.isIOS) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.getNotificationAppLaunchDetails(); // Just ensuring plugin is ready
        
        // This is the standard way to clear the badge in flutter_local_notifications
        await _localNotifications
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.show(
              -1,
              '',
              '',
              notificationDetails: const DarwinNotificationDetails(
                badgeNumber: 0,
                presentAlert: false,
                presentSound: false,
                presentBadge: false,
              ),
            );
        _logger.i('iOS Notification badge cleared');
      }
    } catch (e) {
      _logger.e('Error clearing notification badge: $e');
    }
  }
}

// Top-level function for background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}
