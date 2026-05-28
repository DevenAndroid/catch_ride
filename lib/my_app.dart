import 'package:catch_ride/controllers/chat_controller.dart';
import 'package:catch_ride/services/notification_service.dart';
import 'package:catch_ride/view/trainer/splash_screen.dart';
import 'package:catch_ride/services/link_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/constant/app_theme.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.resumed) {
      _syncBadgeOnResume();
    }
  }

  void _syncBadgeOnResume() {
    try {
      if (Get.isRegistered<ChatController>() && Get.isRegistered<NotificationService>()) {
        final chatController = Get.find<ChatController>();
        final notificationService = Get.find<NotificationService>();
        final unreadCount = chatController.totalUnreadCount;
        notificationService.updateBadge(unreadCount);
      }
    } catch (e) {
      debugPrint('Error syncing badge on resume: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "CatchRide",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routingCallback: (routing) {
        if (routing != null && routing.current.isNotEmpty) {
          if (routing.current.contains('/invite')) {
            // Reconstruct the full URI including parameters since GetX might strip them from routing.current in some versions
            final fullUriString = 'https://catchrideapp.com${routing.current}';
            final uri = Uri.parse(fullUriString);
            
            // Also append GetX parameters manually just in case
            final mergedUri = uri.replace(queryParameters: {...uri.queryParameters, ...Get.parameters});
            Get.find<LinkHandler>().handleDeepLink(mergedUri);
          }
        }
      },
      home: const SplashScreen(),
    );
  }
}
