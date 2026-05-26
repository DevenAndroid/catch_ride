import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/controllers/barn_manager/barn_manager_booking_controller.dart';
import 'package:catch_ride/controllers/booking_controller.dart';
import 'package:get/get.dart';

/// Returns the booking controller instance used for bottom-nav badges and lists.
/// Barn managers use [BarnManagerBookingController]; trainers/vendors use [BookingController].
BookingController lookupBookingController({bool createIfMissing = true}) {
  if (Get.isRegistered<BarnManagerBookingController>()) {
    return Get.find<BarnManagerBookingController>();
  }
  if (Get.isRegistered<BookingController>()) {
    return Get.find<BookingController>();
  }
  if (!createIfMissing) {
    throw StateError('No BookingController registered');
  }
  final role = Get.isRegistered<AuthController>()
      ? (Get.find<AuthController>().currentUser.value?.role ?? '')
      : '';
  if (role == 'barn_manager') {
    return Get.put(BarnManagerBookingController());
  }
  return Get.put(BookingController());
}
