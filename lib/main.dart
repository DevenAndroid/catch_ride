import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/controllers/chat_controller.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Just to keep context, actual file is my_app.dart
import 'my_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  /*
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.clear();
*/

  // Initialize Services
  Get.put(ApiService());
  Get.put(SocketService());
  Get.put(AuthController(), permanent: true);
  Get.lazyPut(() => ChatController(), fenix: true);

  runApp(const MyApp());
}
