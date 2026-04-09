import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/controllers/chat_controller.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/services/socket_service.dart';
import 'package:catch_ride/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Just to keep context, actual file is my_app.dart
import 'my_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await GetStorage.init();

  //
  // SharedPreferences preferences = await SharedPreferences.getInstance();
  // preferences.clear();


  // Initialize Services
  Get.put(ApiService());
  Get.put(SocketService());
  Get.put(AuthController(), permanent: true);
  Get.lazyPut(() => ChatController(), fenix: true);
  
  // Initialize Push Notifications
  await Get.putAsync(() => NotificationService().init());

  runApp(const MyApp());
}
