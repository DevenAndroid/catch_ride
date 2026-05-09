import 'package:catch_ride/constant/app_strings.dart';
import 'package:catch_ride/controllers/chat_controller.dart';
import 'package:catch_ride/services/notification_service.dart';
import 'package:catch_ride/view/trainer/splash_screen.dart';
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
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
          behavior: HitTestBehavior.opaque,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: MediaQuery.of(context).textScaler.clamp(
                    minScaleFactor: .9,
                    maxScaleFactor: .9,
                  ),
            ),
            child: child!,
          ),
        );
      },
      home: const SplashScreen(),
    );
  }
}
