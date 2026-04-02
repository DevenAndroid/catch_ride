import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/groom/groom_view_profile_controller.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/common_textfield.dart';

class ServicesRatesView extends StatefulWidget {
  const ServicesRatesView({super.key});

  @override
  State<ServicesRatesView> createState() => _ServicesRatesViewState();
}

class _ServicesRatesViewState extends State<ServicesRatesView> {
  final controller = Get.put(GroomViewProfileController());

  final dailyController = TextEditingController();
  final weeklyController = TextEditingController();
  final monthlyController = TextEditingController();
  
  final RxString weeklyDays = '5'.obs;
  final RxString monthlyDays = '5'.obs;
  
  final RxList<Map<String, dynamic>> additionalServices = <Map<String, dynamic>>[].obs;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await controller.fetchProfile();
    dailyController.text = controller.dailyRate;
    weeklyController.text = controller.weeklyRate;
    monthlyController.text = controller.monthlyRate;
    weeklyDays.value = controller.weeklyDays;
    monthlyDays.value = controller.monthlyDays;
    additionalServices.assignAll(controller.additionalServices);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const CommonText('Services & Rates', fontSize: AppTextSizes.size18, fontWeight: FontWeight.bold),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildGroomingServicesCard(),
              const SizedBox(height: 20),
              _buildRateCard(),
              const SizedBox(height: 20),
              _buildAdditionalServicesCard(),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  Widget _buildGroomingServicesCard() {
    final services = controller.groomingServices;
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Grooming Services', fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
          const SizedBox(height: 4),
          const CommonText('Select your grooming skills', fontSize: AppTextSizes.size14, color: AppColors.textSecondary),
          const SizedBox(height: 20),
          if (services.isEmpty)
            const CommonText('No services listed', color: AppColors.textSecondary)
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: services.map((s) => _buildSkillChip(s, true)).toList(),
            ),
          const SizedBox(height: 16),
          _buildAddSkillButton(),
        ],
      ),
    );
  }

  Widget _buildRateCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Rate', fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
          const SizedBox(height: 20),
          _buildRateInput('Daily Rate', dailyController),
          const SizedBox(height: 20),
          _buildRateInput('Weekly Rate', weeklyController, showLengthToggle: true, isWeekly: true),
          const SizedBox(height: 20),
          _buildRateInput('Monthly Rate', monthlyController, showLengthToggle: true, isWeekly: false),
        ],
      ),
    );
  }

  Widget _buildRateInput(String label, TextEditingController txtController, {bool showLengthToggle = false, bool isWeekly = true}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(label, fontSize: AppTextSizes.size14, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          const SizedBox(height: 12),
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(color: AppColors.borderLight)),
                    ),
                    child: const CommonText('\$', fontSize: AppTextSizes.size18, color: AppColors.textPrimary),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: txtController,
                        decoration: const InputDecoration(hintText: 'Enter price', border: InputBorder.none, hintStyle: TextStyle(color: Colors.grey, fontSize: 14)),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showLengthToggle) ...[
            const SizedBox(height: 16),
            const CommonText('Choose your week length', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
            const SizedBox(height: 8),
            Obx(() {
              final days = isWeekly ? weeklyDays.value : monthlyDays.value;
              return Row(
                children: [
                  GestureDetector(
                    onTap: () => isWeekly ? weeklyDays.value = '5' : monthlyDays.value = '5',
                    child: _buildLengthToggle('5 days week', days == '5'),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => isWeekly ? weeklyDays.value = '6' : monthlyDays.value = '6',
                    child: _buildLengthToggle('6 days week', days == '6'),
                  ),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildAdditionalServicesCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Additional Services', fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
          const SizedBox(height: 20),
          Obx(() => additionalServices.isEmpty
              ? const CommonText('No additional services', color: AppColors.textSecondary)
              : Column(
                  children: additionalServices.asMap().entries.map((entry) {
                    final index = entry.key;
                    final s = entry.value;
                    return Column(
                      children: [
                        _buildServiceItem(
                          s['name'] ?? 'Service',
                          s['description'] ?? 'Per horse',
                          s['price']?.toString() ?? '0',
                          true,
                          onDelete: () => additionalServices.removeAt(index),
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  }).toList(),
                )),
          const SizedBox(height: 16),
          _buildAddSkillButton(),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? const Color(0xFF000B48) : AppColors.borderLight),
      ),
      child: CommonText(label, fontSize: AppTextSizes.size12, color: isSelected ? const Color(0xFF000B48) : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
    );
  }

  Widget _buildLengthToggle(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF8B4444) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: CommonText(label, fontSize: AppTextSizes.size14, color: isSelected ? Colors.white : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
    );
  }

  Widget _buildServiceItem(String title, String subtitle, String price, bool isSelected, {VoidCallback? onDelete}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? const Color(0xFF000B48) : AppColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: isSelected ? const Color(0xFF000B48) : Colors.grey, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(title, fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
                CommonText(subtitle, fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CommonText('\$ $price', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: isSelected ? AppColors.textPrimary : Colors.grey),
          ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }

  Widget _buildAddSkillButton() {
    return TextButton.icon(
      onPressed: () => _showAddSkillBS(),
      icon: const Icon(Icons.add, size: 18, color: AppColors.linkBlue),
      label: const CommonText('Add Skill', color: AppColors.linkBlue, fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
    );
  }

  void _showAddSkillBS() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            const CommonText('Add Skill', fontSize: AppTextSizes.size20, fontWeight: FontWeight.bold),
            const SizedBox(height: 24),
            CommonTextField(label: 'Skill', hintText: 'Enter your skill', controller: nameController),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CommonText('Price per horse', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
                  const SizedBox(height: 12),
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            border: Border(right: BorderSide(color: AppColors.borderLight)),
                          ),
                          child: const CommonText('\$', fontSize: AppTextSizes.size18, color: AppColors.textPrimary),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextField(
                              controller: priceController,
                              decoration: const InputDecoration(hintText: 'Enter price', border: InputBorder.none, hintStyle: TextStyle(color: Colors.grey, fontSize: 14)),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: CommonButton(
                    text: 'Cancel',
                    backgroundColor: Colors.white,
                    textColor: AppColors.textPrimary,
                    borderColor: AppColors.borderLight,
                    onPressed: () => Get.back(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CommonButton(
                    text: 'Save',
                    onPressed: () {
                      if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                        additionalServices.add({
                          'name': nameController.text,
                          'price': priceController.text,
                          'description': 'Per horse',
                        });
                        Get.back();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.borderLight))),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: CommonButton(
                text: 'Cancel',
                backgroundColor: Colors.white,
                textColor: AppColors.textPrimary,
                borderColor: AppColors.borderLight,
                onPressed: () => Get.back(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CommonButton(
                text: 'Save',
                onPressed: () async {
                  final success = await controller.updateGroomingRates(
                    daily: dailyController.text,
                    weekly: weeklyController.text,
                    weeklyDays: weeklyDays.value,
                    monthly: monthlyController.text,
                    monthlyDays: monthlyDays.value,
                    additional: additionalServices.toList(),
                  );
                  if (success) {
                    Get.back();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }
}
