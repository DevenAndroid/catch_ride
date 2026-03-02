import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditBarnInfoView extends StatefulWidget {
  const EditBarnInfoView({super.key});

  @override
  State<EditBarnInfoView> createState() => _EditBarnInfoViewState();
}

class _EditBarnInfoViewState extends State<EditBarnInfoView> {
  final ProfileController _profileController = Get.find<ProfileController>();
  late TextEditingController _barnNameController;
  late TextEditingController _locationIController;
  late TextEditingController _locationIIController;

  @override
  void initState() {
    super.initState();
    final String location = _profileController.location;
    final List<String> locationParts = location.split(',');
    
    _barnNameController = TextEditingController(text: _profileController.userData['barnName'] ?? '');
    _locationIController = TextEditingController(text: locationParts.isNotEmpty ? locationParts.first.trim() : '');
    _locationIIController = TextEditingController(text: locationParts.length > 1 ? locationParts.sublist(1).join(', ').trim() : '');
  }

  @override
  void dispose() {
    _barnNameController.dispose();
    _locationIController.dispose();
    _locationIIController.dispose();
    super.dispose();
  }

  Future<void> _saveBarnInfo() async {
    String location = _locationIController.text.trim();
    if (_locationIIController.text.isNotEmpty) {
      location += ', ${_locationIIController.text.trim()}';
    }

    final Map<String, dynamic> updateData = {
      'barnName': _barnNameController.text.trim(),
      'location': location,
    };

    final success = await _profileController.updateProfile(updateData);
    if (success) {
      await _profileController.fetchProfile();
      Get.back();
      
      Get.snackbar('Success', 'Barn information updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } else {
      Get.snackbar('Error', 'Failed to update barn information',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'Barn Information',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border.withOpacity(0.5), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [_buildEditCard(), const SizedBox(height: 32)]),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const CommonText(
                      'Cancel',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() => CommonButton(
                  text: 'Save', 
                  isLoading: _profileController.isLoading.value,
                  onPressed: () => _saveBarnInfo(),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonTextField(
            controller: _barnNameController,
            label: 'Barn Name',
            hintText: 'Enter your business name',
            isRequired: true,
          ),
          const SizedBox(height: 16),
          CommonTextField(
            controller: _locationIController,
            label: 'Location I',
            hintText: 'Enter barn location',
            isRequired: true,
          ),
          const SizedBox(height: 16),
          CommonTextField(
            controller: _locationIIController,
            label: 'Location II',
            hintText: 'Enter your business name',
            suffixLabel: '(optional)',
          ),
        ],
      ),
    );
  }
}
