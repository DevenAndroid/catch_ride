import 'package:get/get.dart';

enum UserRole { trainer, barnManager, vendor }

class UserRoleController extends GetxController {
  final Rx<UserRole> currentRole = UserRole.trainer.obs;
  final RxString linkedTrainerName = 'John Smith'.obs;
  final RxString linkedStableName = 'Wellington Stables'.obs;

  bool get isBarnManager => currentRole.value == UserRole.barnManager;
  bool get isTrainer => currentRole.value == UserRole.trainer;
  bool get isVendor => currentRole.value == UserRole.vendor;

  void setRole(UserRole role) {
    currentRole.value = role;
  }
}
