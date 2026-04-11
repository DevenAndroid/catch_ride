import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/groom/groom_view_profile_controller.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BraidingServiceRatesTab extends StatefulWidget {
  const BraidingServiceRatesTab({super.key});

  @override
  State<BraidingServiceRatesTab> createState() => _BraidingServiceRatesTabState();
}

class _BraidingServiceRatesTabState extends State<BraidingServiceRatesTab> {
  final controller = Get.find<GroomViewProfileController>();
  final RxList<Map<String, dynamic>> services = <Map<String, dynamic>>[].obs;

  final List<String> defaultServiceNames = [
    'Hunter Mane & Tail',
    'Hunter Mane Only',
    'Hunter Tail Only',
    'Jumper Braids',
    'Dressage Braids',
    'Mane Pull / Clean Up'
  ];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  void _loadServices() {
    final existing = controller.groomingServices; // This actually contains core services for the active role
    
    // Create map for easy lookup
    final Map<String, Map<String, dynamic>> existingMap = {};
    for (var s in existing) {
      if (s is Map<String, dynamic>) {
        existingMap[s['name'] ?? ''] = s;
      }
    }

    // Initialize with default services + any existing ones not in defaults
    final List<Map<String, dynamic>> initialList = [];
    
    for (var name in defaultServiceNames) {
      final found = existingMap[name];
      initialList.add({
        'name': name,
        'price': TextEditingController(text: found?['price']?.toString() ?? '0'),
        'isSelected': (found != null).obs,
      });
      existingMap.remove(name);
    }

    // Add remaining custom services
    existingMap.forEach((key, value) {
      initialList.add({
        'name': key,
        'price': TextEditingController(text: value['price']?.toString() ?? '0'),
        'isSelected': true.obs,
      });
    });

    services.assignAll(initialList);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMainCard(),
        const SizedBox(height: 32),
        _buildBottomButtons(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildMainCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Braiding Services', fontSize: AppTextSizes.size18, fontWeight: FontWeight.bold),
          const SizedBox(height: 4),
          const CommonText('Select the services you offer and set your pricing.', fontSize: AppTextSizes.size14, color: AppColors.textSecondary),
          const SizedBox(height: 24),
          Obx(() => Column(
            children: services.map((service) => _buildServiceItem(service)).toList(),
          )),
          const SizedBox(height: 12),
          _buildAddServiceLink(),
        ],
      ),
    );
  }

  Widget _buildServiceItem(Map<String, dynamic> service) {
    return Obx(() {
      final isSelected = service['isSelected'].value;
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF00083B) : const Color(0xFFE4E7EC),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => service['isSelected'].value = !service['isSelected'].value,
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF00083B) : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: isSelected ? const Color(0xFF00083B) : const Color(0xFFD0D5DD), width: 2),
                      ),
                      child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonText(service['name'], fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          const CommonText('Per horse', fontSize: 12, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 100,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CommonText('\$ ', fontSize: 14, fontWeight: FontWeight.bold, color: isSelected ? AppColors.textPrimary : const Color(0xFF98A2B3)),
                  Expanded(
                    child: TextField(
                      controller: service['price'],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isSelected ? AppColors.textPrimary : const Color(0xFF98A2B3)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAddServiceLink() {
    return InkWell(
      onTap: () => _showAddServiceBottomSheet(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: const [
            Icon(Icons.add, color: AppColors.linkBlue, size: 20),
            SizedBox(width: 4),
            CommonText('Add Service', color: AppColors.linkBlue, fontSize: 14, fontWeight: FontWeight.bold),
          ],
        ),
      ),
    );
  }

  void _showAddServiceBottomSheet() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CommonText('Add Service', fontSize: 20, fontWeight: FontWeight.bold),
            const SizedBox(height: 24),
            CommonTextField(label: 'Service', hintText: 'i.e hunter mane & tail, mane pulling', controller: nameController),
            const SizedBox(height: 20),
            const CommonText('Price per horse', fontSize: 14, fontWeight: FontWeight.bold),
            const SizedBox(height: 8),
            Container(
              height: 56,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(border: Border(right: BorderSide(color: AppColors.borderLight))),
                    child: const CommonText('\$', fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'Enter price', border: InputBorder.none),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(child: CommonButton(text: 'Cancel', backgroundColor: Colors.white, textColor: AppColors.textPrimary, borderColor: AppColors.borderLight, onPressed: () => Get.back())),
                const SizedBox(width: 16),
                Expanded(child: CommonButton(text: 'Save', onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    services.add({
                      'name': nameController.text,
                      'price': TextEditingController(text: priceController.text),
                      'isSelected': true.obs,
                    });
                    Get.back();
                  }
                })),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildBottomButtons() {
    return Row(
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
              final payload = services
                  .where((s) => s['isSelected'].value)
                  .map((s) => {
                        'name': s['name'],
                        'price': double.tryParse(s['price'].text) ?? 0.0,
                      })
                  .toList();
              final success = await controller.updateBraidingServices(payload);
              if (success) {
                Get.back();
                Get.snackbar('Success', 'Saved successfully',
                    backgroundColor: Colors.green, colorText: Colors.white);
              }
            },
          ),
        ),
      ],
    );
  }
}
