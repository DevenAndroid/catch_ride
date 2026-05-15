import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constant/app_colors.dart';
import '../../../../constant/app_text_sizes.dart';
import '../../../../controllers/vendor/groom/groom_view_profile_controller.dart';
import '../../../../utils/grooming_rates_util.dart';
import '../../../../utils/price_formatter.dart';
import '../../../../widgets/common_text.dart';
import '../../../../widgets/common_textfield.dart';
import '../../../../widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constant/app_colors.dart';
import '../../../../constant/app_text_sizes.dart';
import '../../../../controllers/vendor/groom/groom_view_profile_controller.dart';
import '../../../../utils/grooming_rates_util.dart';
import '../../../../utils/price_formatter.dart';
import '../../../../widgets/common_text.dart';
import '../../../../widgets/common_textfield.dart';
import '../../../../widgets/common_button.dart';

class GroomingServiceRatesTab extends StatefulWidget {
  final String serviceType;
  const GroomingServiceRatesTab({super.key, this.serviceType = 'Grooming'});

  @override
  State<GroomingServiceRatesTab> createState() => _GroomingServiceRatesTabState();
}

class _GroomingServiceRatesTabState extends State<GroomingServiceRatesTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final controller = Get.find<GroomViewProfileController>();
  
  // Local variables as requested
  final dailyController = TextEditingController();
  final weeklyController = TextEditingController();
  final monthlyController = TextEditingController();
  final RxString weeklyDays = '5'.obs;
  final RxString monthlyDays = '5'.obs;
  
  final RxList<String> availableGroomingSkills = [
    'Grooming & Turnout',
    'Wrapping & Bandaging',
    'Stall Upkeep & Daily Care',
    'Show Prep (non braiding)',
  ].obs;
  final RxList<String> selectedGroomingSkills = <String>[].obs;
  final RxList<Map<String, dynamic>> additionalServices = <Map<String, dynamic>>[].obs;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    // Fetch data specifically for THIS service type
    final rawData = controller.getProfileDataByType(widget.serviceType);
    final dynamic profileData = rawData['profileData'];

    final dynamic ratesRaw = rawData['rates'] ??
        (profileData is Map ? (profileData as Map)['rates'] : null);
    final Map<String, dynamic> rates = normalizeGroomingRatesMap(ratesRaw);

    dailyController.text = (rates['daily'] ?? '').toString();

    final weekly = rates['weekly'];
    weeklyController.text = weekly is Map
        ? (weekly['price'] ?? '').toString()
        : (weekly ?? '').toString();
    weeklyDays.value =
        weekly is Map ? (weekly['days'] ?? '5').toString() : '5';

    final monthly = rates['monthly'];
    monthlyController.text = monthly is Map
        ? (monthly['price'] ?? '').toString()
        : (monthly ?? '').toString();
    monthlyDays.value =
        monthly is Map ? (monthly['days'] ?? '5').toString() : '5';

    // Sync grooming skills
    final List<dynamic> servicesList = coerceDynamicList(
      rawData['services'] ??
          (profileData is Map ? (profileData as Map)['services'] : null),
    );
    final currentSkills = servicesList.map((e) {
      if (e is Map) return e['name']?.toString() ?? '';
      return e.toString();
    }).where((name) => name.isNotEmpty).toList();


    for (var skill in currentSkills) {
      if (!availableGroomingSkills.contains(skill)) {
        availableGroomingSkills.add(skill);
      }
    }
    selectedGroomingSkills.assignAll(currentSkills);

    // Sync additional services
    final savedAddServices = coerceDynamicList(
      rawData['additionalServices'] ??
          (profileData is Map
              ? (profileData as Map)['additionalServices']
              : null),
    );
    final List<Map<String, dynamic>> defaultAddServices = [
      {'name': 'Hunter Braiding Mane', 'price': '0', 'description': 'Per horse'},
      {'name': 'Jumper Braiding', 'price': '0', 'description': 'Per horse'},
      {'name': 'Dressage Braiding', 'price': '0', 'description': 'Per horse'},
      {'name': 'Hunter Mane + Tail', 'price': '0', 'description': 'Per horse'},
      {'name': 'Hunter Tail Only', 'price': '0', 'description': 'Per horse'},
      {'name': 'Fullbody Clip', 'price': '0', 'description': 'Per horse'},
      {'name': 'Hunter Clip', 'price': '0', 'description': 'Per horse'},
      {'name': 'Trace Clip', 'price': '0', 'description': 'Per horse'},
      {'name': 'Custom Clip', 'price': '0', 'description': 'Per horse'},

    ];

    final List<Map<String, dynamic>> mergedList = [];
    for (var saved in savedAddServices) {
      if (saved is Map) {
        mergedList.add({
          ...Map<String, dynamic>.from(saved),
          'priceController': TextEditingController(text: saved['price']?.toString() ?? '0'),
          'isSelected': RxBool(true),
        });
      }
    }

    for (var def in defaultAddServices) {
      bool alreadyExists = mergedList.any((m) => m['name'].toString().toLowerCase() == def['name'].toString().toLowerCase());
      if (!alreadyExists) {
        mergedList.add({
          ...def,
          'priceController': TextEditingController(text: def['price']?.toString() ?? '0'),
          'isSelected': RxBool(false),
        });
      }
    }
    additionalServices.assignAll(mergedList);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          _buildGroomingServicesCard(),
          const SizedBox(height: 16),
          _buildRateSection(),
          const SizedBox(height: 16),
          _buildAdditionalServicesCard(),
          const SizedBox(height: 32),
          _buildSaveButton(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGroomingServicesCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Grooming Services', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF101828)),
          const SizedBox(height: 4),
          const CommonText('Select the services you offer', fontSize: 14, color: Color(0xFF667085)),
          const SizedBox(height: 20),
          Obx(() => Wrap(
                spacing: 12,
                runSpacing: 12,
                children: availableGroomingSkills.map((s) {
                  final isSelected = selectedGroomingSkills.contains(s);
                  return GestureDetector(
                    onTap: () {
                      if (isSelected) {
                        selectedGroomingSkills.remove(s);
                      } else {
                        selectedGroomingSkills.add(s);
                      }
                    },
                    child: _buildSkillChip(s, isSelected),
                  );
                }).toList(),
              )),
          const SizedBox(height: 16),
          _buildAddServiceLink('Add Service', () => _showAddServicePopup()),
        ],
      ),
    );
  }

  Widget _buildRateSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Rates', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF101828)),
          const SizedBox(height: 4),
          const CommonText('Set your standard rates based on how you typically work', fontSize: 14, color: Color(0xFF667085)),
          const SizedBox(height: 24),
          _buildRateInput('Daily Rate', dailyController),
          const SizedBox(height: 16),
          _buildRateInput('Weekly Rate', weeklyController, showSchedule: true, isWeekly: true),
          const SizedBox(height: 16),
          _buildRateInput('Monthly Rate', monthlyController, showSchedule: true, isWeekly: false),
        ],
      ),
    );
  }

  Widget _buildAdditionalServicesCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Additional Services', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF101828)),
          const SizedBox(height: 4),
          const CommonText('Optional services offered in addition to your standard work', fontSize: 13, color: Color(0xFF667085)),
          const SizedBox(height: 24),
          Obx(() => additionalServices.isEmpty
              ? const CommonText('No additional services', color: Color(0xFF667085))
              : Column(
                  children: additionalServices.asMap().entries.map((entry) {
                    final index = entry.key;
                    final s = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Obx(() => _buildServiceItem(
                        index,
                        s['name'] ?? 'Service',
                        s['description'] ?? 'Per horse',
                        s['priceController'] as TextEditingController,
                        (s['isSelected'] as RxBool).value,
                        onToggle: (val) => (s['isSelected'] as RxBool).value = val ?? false,
                      )),
                    );
                  }).toList(),
                )),
          const SizedBox(height: 12),
          _buildAddServiceLink('Add Service', () => _showAddSkillBS()),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
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
          child: Obx(() => CommonButton(
            text: 'Save',
            isLoading: controller.isLoading.value,
            onPressed: () async {
              final success = await controller.updateGroomingRates(
                services: selectedGroomingSkills.toList(),
                daily: dailyController.text,
                weekly: weeklyController.text,
                weeklyDays: weeklyDays.value,
                monthly: monthlyController.text,
                monthlyDays: monthlyDays.value,
                additional: additionalServices
                    .where((s) => (s['isSelected'] as RxBool).value)
                    .map((s) => {
                          'name': s['name'],
                          'price': (s['priceController'] as TextEditingController).text.replaceAll(',', ''),
                          'description': s['description'],
                        })
                    .toList(),
              );
              if (success) {
                Get.back();
                Get.snackbar('Success', 'Grooming rates saved successfully',
                    backgroundColor: Colors.green, colorText: Colors.white);
              }
            },
          )),
        ),
      ],
    );
  }

  // Helper widgets moved from parent view
  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSkillChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? const Color(0xFF000B48) : const Color(0xFFD0D5DD)),
      ),
      child: CommonText(
        label, 
        fontSize: 13, 
        color: isSelected ? const Color(0xFF000B48) : const Color(0xFF344054), 
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500
      ),
    );
  }

  Widget _buildRateInput(String label, TextEditingController txtController, {bool showSchedule = false, bool isWeekly = true}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(label, fontSize: 13, color: const Color(0xFF344054), fontWeight: FontWeight.bold),
          const SizedBox(height: 12),
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD0D5DD)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    border: Border(right: BorderSide(color: Color(0xFFD0D5DD))),
                  ),
                  child: const CommonText('\$', fontSize: 16, color: Color(0xFF667085)),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: txtController,
                      decoration: const InputDecoration(
                        hintText: 'Enter Price', 
                        border: InputBorder.none, 
                        hintStyle: TextStyle(color: Color(0xFF98A2B3), fontSize: 14)
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [PriceInputFormatter()],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showSchedule) ...[
            const SizedBox(height: 16),
            const CommonText('Select your standard schedule', fontSize: 12, color: Color(0xFF475467)),
            const SizedBox(height: 8),
            Obx(() {
              final days = isWeekly ? weeklyDays.value : monthlyDays.value;
              return Row(
                children: [
                  GestureDetector(
                    onTap: () => isWeekly ? weeklyDays.value = '5' : monthlyDays.value = '5',
                    child: _buildScheduleChip('5 days week', days == '5'),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => isWeekly ? weeklyDays.value = '6' : monthlyDays.value = '6',
                    child: _buildScheduleChip('6 days week', days == '6'),
                  ),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.secondary : const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? null : Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: CommonText(
        label, 
        fontSize: 13, 
        color: isSelected ? Colors.white : const Color(0xFF344054), 
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500
      ),
    );
  }

  Widget _buildServiceItem(int index, String title, String subtitle, TextEditingController priceController, bool isSelected, {required Function(bool?) onToggle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? const Color(0xFF000B48) : const Color(0xFFEAECF0)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isSelected,
            onChanged: onToggle,
            activeColor: const Color(0xFF000B48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(title, fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF101828)),
                CommonText(subtitle, fontSize: 12, color: const Color(0xFF667085)),
              ],
            ),
          ),
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CommonText('\$ ', fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF667085)),
                Expanded(
                  child: TextField(
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [PriceInputFormatter()],
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF101828),
                      fontFamily: 'Outfit',
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.delete_outline, color: Color(0xFFF04438), size: 20),
            onPressed: () => additionalServices.removeAt(index),
          ),
        ],
      ),
    );
  }

  Widget _buildAddServiceLink(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.add, size: 18, color: Color(0xFF2E90FA)),
          const SizedBox(width: 8),
          CommonText(label, color: const Color(0xFF2E90FA), fontSize: 14, fontWeight: FontWeight.bold),
        ],
      ),
    );
  }

  void _showAddServicePopup() {
    final nameController = TextEditingController();
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
            CommonTextField(controller: nameController, hintText: 'i.e. grooming, night check', label: 'Add Service'),
            const SizedBox(height: 24),
            CommonButton(
              text: 'Save',
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  availableGroomingSkills.add(nameController.text);
                  selectedGroomingSkills.add(nameController.text);
                }
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSkillBS() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonTextField(label: 'Service', controller: nameController, hintText: 'Enter service'),
              const SizedBox(height: 20),
              CommonTextField(label: 'Price', controller: priceController, hintText: 'Enter price', keyboardType: TextInputType.number),
              const SizedBox(height: 24),
              CommonButton(
                text: 'Save',
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    additionalServices.add({
                      'name': nameController.text,
                      'priceController': TextEditingController(text: priceController.text),
                      'description': 'Per horse',
                      'isSelected': true.obs,
                    });
                  }
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
