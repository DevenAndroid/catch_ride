import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/braiding/braiding_details_controller.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:catch_ride/utils/price_formatter.dart';
import 'package:get/get.dart';

class BraidingDetailsView extends StatefulWidget {
  const BraidingDetailsView({super.key});

  @override
  State<BraidingDetailsView> createState() => _BraidingDetailsViewState();
}

class _BraidingDetailsViewState extends State<BraidingDetailsView> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BraidingDetailsController());

    return GestureDetector(
      behavior: HitTestBehavior.opaque, // ensures taps are detected on empty space
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
            onPressed: () => Get.back(),
          ),
          title: const CommonText(
            'Braiding Details',
            fontSize: AppTextSizes.size18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: AppColors.border, height: 1.0),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCoreBraidingServices(controller),
                const SizedBox(height: 24),
                _buildTravelPreferences(controller),
                const SizedBox(height: 24),
                _buildReadOnlyInfo(controller),
                const SizedBox(height: 24),
                _buildCancellationPolicy(controller),
                const SizedBox(height: 32),
                Obx(() => CommonButton(
                  text: 'Continue',
                  isLoading: controller.isSubmitting.value,
                  backgroundColor: AppColors.primary,
                  onPressed: controller.submit,
                )),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoreBraidingServices(BraidingDetailsController controller) {
    return _buildSectionContainer(
      title: 'Braiding Services',
      description: 'Select your braiding skills',
      children: [
        Obx(() => Column(
              children: controller.braidingServices.map((service) {
                final isSelected = service['isSelected'].value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => service['isSelected'].value = !isSelected,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF001149) : AppColors.borderLight,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isSelected,
                            onChanged: (val) => service['isSelected'].value = val!,
                            activeColor: const Color(0xFF001149),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CommonText(
                                  service['name'] as String,
                                  fontSize: AppTextSizes.size14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                const SizedBox(height: 4),
                                const CommonText(
                                  'Per horse',
                                  fontSize: AppTextSizes.size12,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 100,
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const CommonText('\$ ', fontSize: AppTextSizes.size14, color: AppColors.textSecondary),
                                Expanded(
                                  child: TextField(
                                    controller: service['price'] as TextEditingController,
                                    decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero, hintText: '0', hintStyle: TextStyle(color: Colors.grey)),
                                    style: const TextStyle(fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: [PriceInputFormatter()],
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _showAddMoreBottomSheet(context, controller),
          child: Row(
            children: const [
              Icon(Icons.add, size: 18, color: AppColors.linkBlue),
              SizedBox(width: 4),
              CommonText('Add Skills', color: AppColors.linkBlue, fontWeight: FontWeight.bold, fontSize: AppTextSizes.size14),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTravelPreferences(BraidingDetailsController controller) {
    return _buildSectionContainer(
      title: 'Travel Preferences',
      children: [
        Obx(() => Wrap(
              spacing: 8,
              runSpacing: 12,
              children: controller.travelOptions.map((item) {
                final isSelected = controller.selectedTravel.contains(item);
                return _buildSelectableChip(item, isSelected: isSelected, onTap: () => controller.toggleTravel(item));
              }).toList(),
            )),
      ],
    );
  }

  Widget _buildReadOnlyInfo(BraidingDetailsController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
      }
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryItem('Location', controller.location.value),
          const SizedBox(height: 24),
          _buildEditableExperience(controller),
          const SizedBox(height: 24),
          _buildEditableChips('Disciplines', 'Select the disciplines you most commonly work with.', controller.disciplines, controller.disciplineOptions, controller.toggleDiscipline),
          const SizedBox(height: 24),
          _buildEditableChips('Typical Level of Horses', 'Select the types of horses you most frequently work with.', controller.horseLevels, controller.horseLevelOptions, controller.toggleHorseLevel),
          const SizedBox(height: 24),
          _buildEditableRegions(controller),
        ],
      );
    });
  }

  Widget _buildSummaryItem(String label, String value) {
    return _buildSectionContainer(
      title: label,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6), 
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: CommonText(value, fontSize: AppTextSizes.size14, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildEditableExperience(BraidingDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Years of experience'),
        const SizedBox(height: 12),
        Obx(() => GestureDetector(
          onTap: () => _showPickerBottomSheet(
            title: 'Experience',
            options: controller.experienceOptions,
            onSelected: (val) => controller.experience.value = val,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6), 
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CommonText(controller.experience.value ?? 'Select years of experience', fontSize: AppTextSizes.size14, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                ),
                const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 20),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildEditableChips(String label, String description, RxList<String> selectedItems, RxList<String> allOptions, Function(String) onToggle) {
    return _buildSectionContainer(
      title: label,
      description: description,
      children: [
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allOptions.map((it) {
            final isSelected = selectedItems.contains(it);
            return GestureDetector(
              onTap: () => onToggle(it),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF3F4FF) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? const Color(0xFF001149) : Colors.transparent),
                ),
                child: CommonText(
                  it, 
                  fontSize: 12, 
                  color: isSelected ? const Color(0xFF001149) : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        )),
      ],
    );
  }

  Widget _buildEditableRegions(BraidingDetailsController controller) {
    return _buildSectionContainer(
      title: 'Regions covered',
      description: 'Select the regions you have the most experience with',
      children: [
        Obx(() => Column(
          children: [
            GestureDetector(
              onTap: () => _showMultiSelectBottomSheet(
                title: 'Select Regions',
                options: controller.regionOptions,
                selectedItems: controller.operatingRegions,
                onToggle: controller.toggleRegion,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6), 
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonText('Select Regions...', fontSize: 13, color: const Color(0xFF999999), fontWeight: FontWeight.w500),
                    const Icon(Icons.add, color: Color(0xFF001144), size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.operatingRegions.map((region) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF001144)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: CommonText(region, fontSize: 12, color: const Color(0xFF001144), fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => controller.toggleRegion(region),
                      child: const Icon(Icons.close, size: 14, color: Color(0xFF001144)),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ],
        )),
      ],
    );
  }

  void _showPickerBottomSheet({required String title, required List<String> options, required Function(String) onSelected}) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonText(title, fontSize: 20, fontWeight: FontWeight.bold),
            const SizedBox(height: 24),
            ...options.map((opt) => ListTile(
              title: CommonText(opt),
              onTap: () {
                onSelected(opt);
                Get.back();
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showMultiSelectBottomSheet({required String title, required List<String> options, required RxList<String> selectedItems, required Function(String) onToggle}) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonText(title, fontSize: 20, fontWeight: FontWeight.bold),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: options.map((opt) => Obx(() => CheckboxListTile(
                  title: CommonText(opt),
                  value: selectedItems.contains(opt),
                  onChanged: (val) => onToggle(opt),
                  activeColor: const Color(0xFF001144),
                ))).toList(),
              ),
            ),
            CommonButton(text: 'Done', onPressed: () => Get.back()),
          ],
        ),
      ),
    );
  }

  Widget _buildCancellationPolicy(BraidingDetailsController controller) {
    return _buildSectionContainer(
      title: 'Cancellation policy',
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: DropdownButtonHideUnderline(
            child: Obx(() => DropdownButton<String>(
                  value: controller.cancellationPolicy.value,
                  hint: const CommonText('Select cancellation policy', color: AppColors.textSecondary, fontSize: AppTextSizes.size14),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                  items: ['Flexible (24+ hrs)', 'Moderate (48+ hrs)', 'Strict (72+ hrs)'].map((s) => DropdownMenuItem(value: s, child: CommonText(s))).toList(),
                  onChanged: (val) => controller.cancellationPolicy.value = val,
                )),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Obx(() => GestureDetector(
                  onTap: () => controller.isCustomCancellation.value = !controller.isCustomCancellation.value,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: controller.isCustomCancellation.value ? const Color(0xFF001149) : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: controller.isCustomCancellation.value ? const Color(0xFF001149) : AppColors.borderLight),
                    ),
                    child: Icon(Icons.check, size: 16, color: controller.isCustomCancellation.value ? Colors.white : Colors.transparent),
                  ),
                )),
            const SizedBox(width: 8),
            const CommonText('Custom', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w500),
          ],
        ),
        Obx(() => AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: controller.isCustomCancellation.value
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: TextField(
                        controller: controller.customCancellationController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Write here...',
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF001149))),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    )
                  : const SizedBox(height: 0, width: double.infinity),
            )),
      ],
    );
  }

  void _showAddMoreBottomSheet(BuildContext context, BraidingDetailsController controller) {
    Get.bottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      Container(
        padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
             CommonText('Add More Service', fontSize: AppTextSizes.size22, fontWeight: FontWeight.bold),
            const SizedBox(height: 24),
            const CommonText('Skill', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
            const SizedBox(height: 8),
            TextField(
              controller: controller.addServiceInputController,
              decoration: InputDecoration(
                hintText: 'Enter your skill',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      controller.addServiceInputController.clear();
                      Get.back();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.borderLight),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const CommonText('Cancel', fontSize: AppTextSizes.size16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CommonButton(
                    text: 'Save',
                    backgroundColor: AppColors.primary,
                    onPressed: () {
                      controller.addBraidingService(controller.addServiceInputController.text);
                      Get.back();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Helpers ---
  Widget _buildSectionContainer({required String title, String? description, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(title),
          if (description != null) ...[
            const SizedBox(height: 4),
            CommonText(description, fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
          ],
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return CommonText(title, fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold);
  }

  Widget _buildSelectableChip(String text, {required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF5F8FF) : const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? const Color(0xFF001144) : const Color(0xFFE5E5E5),
          ),
        ),
        child: CommonText(
          text,
          fontSize: 12.5,
          color: isSelected ? const Color(0xFF001144) : const Color(0xFF444444),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionLink(String text, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: CommonText(text, color: AppColors.linkBlue, fontWeight: FontWeight.w600, fontSize: AppTextSizes.size14),
    );
  }

}
