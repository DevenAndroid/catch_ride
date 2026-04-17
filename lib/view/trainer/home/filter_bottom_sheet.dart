import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/controllers/explore_controller.dart';
import 'package:catch_ride/widgets/common_text.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final ExploreController controller = Get.find<ExploreController>();

  final TextEditingController minAgeController = TextEditingController();
  final TextEditingController maxAgeController = TextEditingController();
  final TextEditingController minHeightController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();

  String selectedListingType = '';
  bool _isApplying = false;

  // Local list to store selected tags before applying
  final Set<String> _localSelectedTags = {};

  final List<String> listingTypes = [
    'Sale',
    'Annual Lease',
    'Short Term or Circuit Lease',
    'Weekly Lease',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize from controller
    if (controller.ageMin.value != null) minAgeController.text = controller.ageMin.value.toString();
    if (controller.ageMax.value != null) maxAgeController.text = controller.ageMax.value.toString();
    if (controller.heightMin.value != null) minHeightController.text = controller.heightMin.value.toString();
    if (controller.heightMax.value != null) maxHeightController.text = controller.heightMax.value.toString();
    if (controller.priceMin.value != null) minPriceController.text = controller.priceMin.value.toString();
    if (controller.priceMax.value != null) maxPriceController.text = controller.priceMax.value.toString();
    selectedListingType = controller.listingType.value;
    _localSelectedTags.addAll(controller.selectedTags);
  }

  void _clearAll() {
    setState(() {
      minAgeController.clear();
      maxAgeController.clear();
      minHeightController.clear();
      maxHeightController.clear();
      minPriceController.clear();
      maxPriceController.clear();
      selectedListingType = '';
      _localSelectedTags.clear();
    });
    
    // Hit API again without loader
    controller.ageMin.value = null;
    controller.ageMax.value = null;
    controller.heightMin.value = null;
    controller.heightMax.value = null;
    controller.priceMin.value = null;
    controller.priceMax.value = null;
    controller.listingType.value = '';
    controller.selectedTags.clear();
    
    controller.fetchHorses(showLoading: false);
  }

  void _applyFilters() async {
    setState(() {
      _isApplying = true;
    });

    controller.ageMin.value = int.tryParse(minAgeController.text);
    controller.ageMax.value = int.tryParse(maxAgeController.text);
    controller.heightMin.value = double.tryParse(minHeightController.text);
    controller.heightMax.value = double.tryParse(maxHeightController.text);
    controller.priceMin.value = double.tryParse(minPriceController.text);
    controller.priceMax.value = double.tryParse(maxPriceController.text);
    controller.listingType.value = selectedListingType;
    controller.selectedTags.assignAll(_localSelectedTags.toList());

    await controller.fetchHorses(showLoading: false);

    if (mounted) {
      setState(() {
        _isApplying = false;
      });
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CommonText(
                'Filters',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 20, color: Color(0xFF4B5563)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextFieldRow('Horse Min Age', 'Horse Max Age', 'Enter Age', 'Enter Age', minAgeController, maxAgeController),
                  const SizedBox(height: 16),
                  _buildTextFieldRow('Horse Min Height', 'Horse Max Height', 'Enter Height', 'Enter Height', minHeightController, maxHeightController, isDecimal: true),
                  const SizedBox(height: 20),
                  const CommonText('Listing Type', fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                  const SizedBox(height: 8),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedListingType.isEmpty ? null : selectedListingType,
                        hint: const CommonText('Select Listing Type', color: AppColors.textSecondary),
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                        items: listingTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: CommonText(type, color: AppColors.textPrimary),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedListingType = val ?? '';
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextFieldRow('Min Price', 'Max Price', 'Enter min price', 'Enter max price', minPriceController, maxPriceController, isDecimal: true),
                  const SizedBox(height: 24),
                  
                  // Tags Groups Dynamic Render
                  Obx(() {
                    if (controller.isTagsLoading.value) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: CircularProgressIndicator(),
                      ));
                    }
                    if (controller.tagTypes.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: controller.tagTypes.map<Widget>((tagCategory) {
                        final String catName = tagCategory['name'];
                        final List values = tagCategory['values'] ?? [];
                        if (values.isEmpty) return const SizedBox.shrink();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonText(catName, fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: values.map<Widget>((valObj) {
                                  final String tagName = valObj['name'] ?? '';
                                  final bool isSelected = _localSelectedTags.contains(tagName);
                                  
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          _localSelectedTags.remove(tagName);
                                        } else {
                                          _localSelectedTags.add(tagName);
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected ? const Color(0xFFEFF4FF) : Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected ? AppColors.primary : AppColors.border,
                                        ),
                                      ),
                                      child: CommonText(
                                        tagName,
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  }),
                ],
              ),
            ),
          ),
          // Buttons
          Container(
            padding: const EdgeInsets.only(top: 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearAll,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const CommonText('Clear all', color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00083B),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isApplying
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const CommonText('Show results', color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldRow(String label1, String label2, String hint1, String hint2, TextEditingController c1, TextEditingController c2, {bool isDecimal = false}) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(label1, fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              const SizedBox(height: 8),
              Container(
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: c1,
                  keyboardType: isDecimal ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.number,
                  decoration: InputDecoration(
                    hintText: hint1,
                    hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(label2, fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              const SizedBox(height: 8),
              Container(
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: c2,
                  keyboardType: isDecimal ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.number,
                  decoration: InputDecoration(
                    hintText: hint2,
                    hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
