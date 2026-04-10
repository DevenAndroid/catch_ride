import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/view/vendor/groom/profile_create/setup_groom_application_view.dart';
import 'package:catch_ride/view/vendor/braiding/profile_create/braiding_application_view.dart';
import 'package:catch_ride/controllers/vendor/vendor_select_services_controller.dart';

class VendorSelectServicesView extends StatelessWidget {
  const VendorSelectServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VendorSelectServicesController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'Select your Services',
          fontSize: AppTextSizes.size22,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.borderLight, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Obx(
          () => controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
                      child: CommonText(
                        'Select maximum 2 services',
                        fontSize: AppTextSizes.size16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: controller.services.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final serviceName = controller.services[index];
                          final isSelected = controller.selectedServices.contains(serviceName);
                          return _buildServiceTile(controller, serviceName, isSelected);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      child: CommonButton(
                        text: 'Continue',
                        isLoading: controller.isLoading.value,
                        onPressed: controller.selectedServices.isEmpty
                            ? null
                            : () => controller.submitServices(),
                        backgroundColor: AppColors.primary,
                        borderRadius: 12,
                        height: 56,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildServiceTile(VendorSelectServicesController controller, String serviceName, bool isSelected) {
    return GestureDetector(
      onTap: () => controller.toggleService(serviceName),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: CommonText(
                serviceName,
                fontSize: AppTextSizes.size18,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.borderMedium,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}


