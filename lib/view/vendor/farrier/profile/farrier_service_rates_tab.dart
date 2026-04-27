import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/farrier/farrier_details_controller.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/controllers/vendor/groom/groom_view_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/price_formatter.dart';

import '../../../../widgets/common_textfield.dart';

class FarrierServiceRatesTab extends StatefulWidget {
  const FarrierServiceRatesTab({super.key});

  @override
  State<FarrierServiceRatesTab> createState() => _FarrierServiceRatesTabState();
}

class _FarrierServiceRatesTabState extends State<FarrierServiceRatesTab> {
  late FarrierDetailsController farrierController;
  final mainController = Get.find<GroomViewProfileController>();

  @override
  void initState() {
    super.initState();
    farrierController = Get.put(FarrierDetailsController());
    _loadSavedData();
  }

  void _loadSavedData() {
    // Wait for farrierController to load defaults from tags
    ever(farrierController.isLoading, (isLoading) {
      if (!isLoading) {
        _syncWithProfile();
      }
    });

    if (!farrierController.isLoading.value) {
      _syncWithProfile();
    }
  }

  void _syncWithProfile() {
    final savedServices = mainController.farrierServices;
    final savedAddOns = mainController.farrierAddOns;

    // Sync Services
    _syncList(savedServices, farrierController.farrierServices, isAddOn: false);

    // Sync Add-Ons
    _syncList(savedAddOns, farrierController.addOns, isAddOn: true);
  }

  void _syncList(List<dynamic> savedItems, RxList<Map<String, dynamic>> targetList, {required bool isAddOn}) {
    for (var saved in savedItems) {
      if (saved == null || saved is! Map) continue;
      final name = saved['name']?.toString() ?? '';
      if (name.isEmpty) continue;

      final priceStr = saved['price']?.toString() ?? '0';
      final existingIndex = targetList.indexWhere((s) => s['name'] == name);

      if (existingIndex != -1) {
        targetList[existingIndex]['isSelected'].value = true;
        (targetList[existingIndex]['price'] as TextEditingController).text = priceStr;
      } else {
        farrierController.addService(name, isAddOn: isAddOn);
        final newIndex = targetList.indexWhere((s) => s['name'] == name);
        if (newIndex != -1) {
          (targetList[newIndex]['price'] as TextEditingController).text = priceStr;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildServiceCard(
            title: 'Farrier Services',
            subtitle: 'Select the services you offer and set your pricing',
            services: farrierController.farrierServices,
            onAddTap: () => _showAddServiceBottomSheet(context, isAddOn: false),
          ),
          const SizedBox(height: 20),
          _buildServiceCard(
            title: 'Add - Ons',
            subtitle: 'Optional services or materials offered in addition to your standard work',
            services: farrierController.addOns,
            onAddTap: () => _showAddServiceBottomSheet(context, isAddOn: true),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String subtitle,
    required RxList<Map<String, dynamic>> services,
    required VoidCallback onAddTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(title, fontSize: AppTextSizes.size18, fontWeight: FontWeight.bold),
          const SizedBox(height: 4),
          CommonText(subtitle, fontSize: AppTextSizes.size14, color: AppColors.textSecondary),
          const SizedBox(height: 20),
          Obx(() => Column(
                children: services.map((service) => _buildServiceItem(service)).toList(),
              )),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onAddTap,
            child: Row(
              children: const [
                Icon(Icons.add, size: 18, color: AppColors.linkBlue),
                SizedBox(width: 4),
                CommonText(
                  'Add Service',
                  color: AppColors.linkBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: AppTextSizes.size14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(Map<String, dynamic> service) {
    final RxBool isSelected = service['isSelected'];
    final TextEditingController priceCtrl = service['price'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Obx(() => Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected.value ? const Color(0xFF001149) : AppColors.borderLight,
                width: isSelected.value ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => isSelected.value = !isSelected.value,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected.value ? const Color(0xFF001149) : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isSelected.value ? const Color(0xFF001149) : AppColors.borderMedium,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.check,
                      size: 14,
                      color: isSelected.value ? Colors.white : Colors.transparent,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        service['name'],
                        fontSize: AppTextSizes.size14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const CommonText(
                        'Per horse',
                        fontSize: AppTextSizes.size12,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [PriceInputFormatter()],
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 12, right: 4),
                        child: Text(
                          '\$',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      hintText: '0',
                      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                    onChanged: (val) {
                      if (val.isNotEmpty) isSelected.value = true;
                    },
                  ),
                ),
              ],
            ),
          )),
    );
  }

  void _showAddServiceBottomSheet(BuildContext context, {required bool isAddOn}) {
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
            const CommonText('Add More Service', fontSize: AppTextSizes.size22, fontWeight: FontWeight.bold),
            const SizedBox(height: 24),
            const CommonText('Skill', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
            const SizedBox(height: 8),
            CommonTextField(
              label: '',
              hintText: 'Enter your skill',
              controller: farrierController.addServiceInputController,
            ),
            const SizedBox(height: 20),
            const CommonText('Price', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
            const SizedBox(height: 8),
            CommonTextField(
              label: '',
              hintText: 'Enter price (e.g. 40)',
              controller: farrierController.addServicePriceController,
              prefixIcon: const Padding(
                padding: EdgeInsets.all(14),
                child: CommonText('\$ ', fontSize: AppTextSizes.size14),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [PriceInputFormatter()],
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
                  child: OutlinedButton(
                    onPressed: () {
                      if (farrierController.addServiceInputController.text.isNotEmpty) {
                        if (isAddOn) {
                          farrierController.addOns.add({
                            'name': farrierController.addServiceInputController.text,
                            'isSelected': true.obs,
                            'price': TextEditingController(text: farrierController.addServicePriceController.text),
                          });
                        } else {
                          farrierController.farrierServices.add({
                            'name': farrierController.addServiceInputController.text,
                            'isSelected': true.obs,
                            'price': TextEditingController(text: farrierController.addServicePriceController.text),
                          });
                        }
                        farrierController.addServiceInputController.clear();
                        farrierController.addServicePriceController.clear();
                      }
                      Get.back();
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const CommonText('Save', color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
