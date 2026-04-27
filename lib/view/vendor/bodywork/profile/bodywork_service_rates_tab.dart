import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/bodywork/bodywork_details_controller.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/price_formatter.dart';

class BodyworkServiceRatesTab extends GetView<BodyworkDetailsController> {
  const BodyworkServiceRatesTab({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<BodyworkDetailsController>()) {
      Get.put(BodyworkDetailsController());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildGroupedSection(
            'Bodywork Services',
            description: 'Select all services you are trained and qualified to provide',
            children: [
              Obx(() {
                if (controller.isLoadingServices.value) {
                  return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                }
                return Column(
                  children: controller.services.map((service) => _buildServiceItem(service)).toList(),
                );
              }),
              const SizedBox(height: 12),
 /*             GestureDetector(
                onTap: () => _showAddServiceBottomSheet(context),
                child: Row(
                  children: const [
                    Icon(Icons.add, size: 18, color: AppColors.linkBlue),
                    SizedBox(width: 4),
                    CommonText(
                      'Add Modality',
                      color: AppColors.linkBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: AppTextSizes.size14,
                    ),
                  ],
                ),
              ),*/
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGroupedSection(String title, {String? description, List<Widget> children = const []}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(title, fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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

  Widget _buildServiceItem(Map<String, dynamic> service) {
    bool isSelected = service['isSelected'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    service['isSelected'] = !isSelected;
                    controller.services.refresh();
                  },
                  child: Icon(
                    isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                    color: isSelected ? AppColors.primary : AppColors.borderMedium,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: CommonText(service['name'], fontSize: AppTextSizes.size14, fontWeight: FontWeight.w500)),
                if (isSelected)
                  GestureDetector(
                    onTap: () => _showRatesBottomSheet(service),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const CommonText('Configure Rates', fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
          if (isSelected) ...[
            const Divider(height: 1),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: AppColors.lightGray.withOpacity(0.1),
              child: _buildRatesSummary(service['rates']),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatesSummary(Map<String, dynamic> rates) {
    List<MapEntry<String, dynamic>> activeRates = rates.entries.where((e) => e.value.toString().isNotEmpty).toList();

    if (activeRates.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: CommonText('No rates configured. Tap to configure.', fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(activeRates.length * 2 - 1, (index) {
          if (index.isOdd) {
            return Container(width: 1, height: 24, color: AppColors.borderLight);
          }
          final e = activeRates[index ~/ 2];
          return Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CommonText('\$ ${e.value}', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.accentRed),
                const SizedBox(height: 4),
                CommonText('${e.key} mins', fontSize: 12, color: AppColors.textSecondary),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _showRatesBottomSheet(Map service) {
    // Clone data for editing
    final editingRates = Map<String, dynamic>.from(service['rates']);
    final editingNote = TextEditingController(text: service['note'] ?? '');
    final RxnString trainerPresence = RxnString(service['trainerPresence']);
    final RxnString vetApproval = RxnString(service['vetApproval']);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 24),
              CommonText(service['name'], fontSize: AppTextSizes.size20, fontWeight: FontWeight.bold),
              const SizedBox(height: 24),
              const CommonText('Session Length & Price', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
              const SizedBox(height: 16),
              ...['30', '45', '60', '90'].map((mins) {
                final hasValue = editingRates[mins] != null && editingRates[mins]!.toString().isNotEmpty;
                final RxBool isChecked = (hasValue).obs;
                final textController = TextEditingController(text: editingRates[mins]?.toString() ?? '');

                return Column(
                  children: [
                    Obx(() => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isChecked.value ? AppColors.primary : Colors.transparent),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => isChecked.value = !isChecked.value,
                                    child: Icon(isChecked.value ? Icons.check_box : Icons.check_box_outline_blank, color: isChecked.value ? const Color(0xFF001149) : Colors.grey),
                                  ),
                                  const SizedBox(width: 12),
                                  CommonText('$mins minutes', fontSize: 14, fontWeight: FontWeight.w500),
                                ],
                              ),
                              if (isChecked.value) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.borderLight),
                                  ),
                                  child: Row(
                                    children: [
                                      const CommonText('\$', fontSize: 14, color: AppColors.textSecondary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          controller: textController,
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          inputFormatters: [PriceInputFormatter()],
                                          onChanged: (val) => editingRates[mins] = val,
                                          decoration: const InputDecoration(hintText: 'Enter price', border: InputBorder.none, hintStyle: TextStyle(fontSize: 14)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )),
                  ],
                );
              }).toList(),
              const SizedBox(height: 16),
              const CommonText('Note', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
              const SizedBox(height: 8),
              CommonTextField(label: '', hintText: 'Write here...', controller: editingNote, maxLines: 3),
              const SizedBox(height: 16),
              const CommonText('Trainer Presence', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
              const SizedBox(height: 8),
              Obx(() => _buildDropdown(
                    value: trainerPresence.value,
                    hint: 'Select Trainer Preference',
                    options: ['Required', 'Preferred', 'Not Required'],
                    onChanged: (val) => trainerPresence.value = val,
                  )),
              const SizedBox(height: 16),
              const CommonText('Vet approval', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
              const SizedBox(height: 8),
              Obx(() => _buildDropdown(
                    value: vetApproval.value,
                    hint: 'Select Vet Preference',
                    options: ['Required', 'Sometimes Required', 'Not Required'],
                    onChanged: (val) => vetApproval.value = val,
                  )),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: CommonButton(
                      text: 'Cancel',
                      onPressed: () => Get.back(),
                      backgroundColor: Colors.white,
                      textColor: AppColors.textPrimary,
                      borderColor: AppColors.borderLight,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CommonButton(
                      text: 'Save',
                      onPressed: () {
                        // Cleanup editing rates: if unchecked, clear the value
                        // (Wait, current logic updates editingRates in onChanged, 
                        // but we need to ensure uncheck clears it if we want it to not show in summary)
                        // Actually, the summary logic uses .isNotEmpty.
                        
                        service['rates'] = editingRates;
                        service['note'] = editingNote.text;
                        service['trainerPresence'] = trainerPresence.value;
                        service['vetApproval'] = vetApproval.value;
                        service['isSelected'] = true;
                        controller.services.refresh();
                        Get.back();
                      },
                      backgroundColor: const Color(0xFF001149),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDropdown({String? value, required String hint, required List<String> options, required Function(String) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: CommonText(hint, color: AppColors.textSecondary, fontSize: 14),
          isExpanded: true,
          items: options.map((v) => DropdownMenuItem(value: v, child: CommonText(v))).toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }

  void _showAddServiceBottomSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
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
            const CommonText('Add More Modality', fontSize: AppTextSizes.size22, fontWeight: FontWeight.bold),
            const SizedBox(height: 24),
            const CommonText('Name', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
            const SizedBox(height: 8),
            CommonTextField(
              label: '',
              hintText: 'Enter modality name',
              controller: nameCtrl,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const CommonText('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameCtrl.text.isNotEmpty) {
                        controller.services.add({
                          'name': nameCtrl.text,
                          'isSelected': true,
                          'rates': {'30': '', '45': '', '60': '', '90': ''},
                          'note': '',
                          'trainerPresence': null,
                          'vetApproval': null,
                        });
                        Get.back();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const CommonText('Add', color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
