import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/controllers/system_config_controller.dart';
import 'package:catch_ride/controllers/chat_controller.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/services/socket_service.dart';
import 'package:catch_ride/services/notification_service.dart';
import 'package:catch_ride/services/link_handler.dart';
import 'package:catch_ride/services/referral_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controllers/profile_controller.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'my_app.dart';

 const String googleApiKey = "AIzaSyDRqZ4i4F45x8xZkgRqq31x1CwIBy_QHmM";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock to portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await GetStorage.init();


 // SharedPreferences preferences = await SharedPreferences.getInstance();
   //preferences.clear();


  // Initialize Services
  Get.put(ApiService());
  Get.put(SystemConfigController());
  Get.put(SocketService());
  Get.put(AuthController(), permanent: true);
  Get.put(ProfileController(), permanent: true);
  Get.put(ChatController(), permanent: true);
  
  // Initialize Push Notifications
  await Get.putAsync(() => NotificationService().init());
  
  // Referral + deep linking (invite codes)
  await Get.putAsync(() => ReferralService().init());
  await Get.putAsync(() => LinkHandler().init());

  runApp(const MyApp());
}
