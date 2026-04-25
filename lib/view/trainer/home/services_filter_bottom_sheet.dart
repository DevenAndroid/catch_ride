import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constant/app_colors.dart';
import '../../../../controllers/explore_controller.dart';
import '../../../../widgets/common_text.dart';
import 'package:collection/collection.dart';

class ServicesFilterBottomSheet extends StatefulWidget {
  const ServicesFilterBottomSheet({super.key});

  @override
  State<ServicesFilterBottomSheet> createState() => _ServicesFilterBottomSheetState();
}

class _ServicesFilterBottomSheetState extends State<ServicesFilterBottomSheet> {
  final ExploreController controller = Get.find<ExploreController>();
  
  final TextEditingController minExpController = TextEditingController();
  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();
  final TextEditingController minCapacityController = TextEditingController();
  final TextEditingController maxCapacityController = TextEditingController();

  String _selectedTab = 'Groom';
  final Set<String> _localGroomingServices = {};
  final Set<String> _localBraidingServices = {};
  final Set<String> _localClippingServices = {};
  final Set<String> _localFarrierServices = {};
  final Set<String> _localBodyworkServices = {};
  final Set<String> _localSupport = {};
  final Set<String> _localHandling = {};
  final Set<String> _localAdditional = {};
  final Set<String> _localTravel = {};
  final Set<String> _localDisciplines = {};
  final Set<String> _localLevels = {};
  final Set<String> _localRegions = {};

  final Set<String> _localFarrierIntake = {};
  final Set<String> _localFarrierTimeframe = {};
  String _localFarrierAvailabilityMode = '';

  final Set<String> _localBodyworkTimeframe = {};
  String _localBodyworkLocationType = '';

  final Set<String> _localShippingTravelScope = {};
  final Set<String> _localShippingStallTypes = {};
  final TextEditingController startLocationController = TextEditingController();
  final TextEditingController endLocationController = TextEditingController();

  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    // Initialize from controller
    _selectedTab = controller.selectedServiceTab.value;
    if (controller.minExperience.value != null) {
      minExpController.text = controller.minExperience.value.toString();
    }
    if (controller.minDailyRate.value != null) {
      minPriceController.text = controller.minDailyRate.value.toString();
    }
    if (controller.maxDailyRate.value != null) {
      maxPriceController.text = controller.maxDailyRate.value.toString();
    }
    if (controller.horseMinCapacity.value != null) {
      minCapacityController.text = controller.horseMinCapacity.value.toString();
    }
    if (controller.horseMaxCapacity.value != null) {
      maxCapacityController.text = controller.horseMaxCapacity.value.toString();
    }
    
    _localGroomingServices.addAll(controller.groomingServices);
    _localBraidingServices.addAll(controller.braidingServices);
    _localClippingServices.addAll(controller.clippingServices);
    _localFarrierServices.addAll(controller.farrierServices);
    _localBodyworkServices.addAll(controller.bodyworkServices);
    _localSupport.addAll(controller.groomingSupport);
    _localHandling.addAll(controller.horseHandling);
    _localAdditional.addAll(controller.additionalServices);
    _localTravel.addAll(controller.travelPreferences);
    _localDisciplines.addAll(controller.groomingDisciplines);
    _localLevels.addAll(controller.groomingHorseLevels);
    _localRegions.addAll(controller.regionsCovered);

    _localFarrierIntake.addAll(controller.farrierIntake);
    _localFarrierTimeframe.addAll(controller.farrierTimeframe);
    _localFarrierAvailabilityMode = controller.farrierAvailabilityMode.value;

    _localBodyworkTimeframe.addAll(controller.bodyworkTimeframe);
    _localBodyworkLocationType = controller.bodyworkLocationType.value;

    _localShippingTravelScope.addAll(controller.shippingTravelScope);
    _localShippingStallTypes.addAll(controller.shippingStallTypes);
    startLocationController.text = controller.shippingStartLocation.value;
    endLocationController.text = controller.shippingEndLocation.value;
  }

  void _clearAll() {
    setState(() {
      minExpController.clear();
      minPriceController.clear();
      maxPriceController.clear();
      minCapacityController.clear();
      maxCapacityController.clear();
      _localGroomingServices.clear();
      _localBraidingServices.clear();
      _localClippingServices.clear();
      _localFarrierServices.clear();
      _localBodyworkServices.clear();
      _localSupport.clear();
      _localHandling.clear();
      _localAdditional.clear();
      _localTravel.clear();
      _localDisciplines.clear();
      _localLevels.clear();
      _localRegions.clear();
      _localFarrierIntake.clear();
      _localFarrierTimeframe.clear();
      _localFarrierAvailabilityMode = '';
      _localBodyworkTimeframe.clear();
      _localBodyworkLocationType = '';
      _localShippingTravelScope.clear();
      _localShippingStallTypes.clear();
      startLocationController.clear();
      endLocationController.clear();
      _selectedTab = 'Groom';
    });

    controller.clearAllFilters();
    controller.fetchVendors(showLoading: false);
    controller.fetchServiceTags('Grooming');
  }

  void _applyFilters() async {
    setState(() {
      _isApplying = true;
    });

    controller.isServiceFilterApplied.value = true;
    controller.selectedServiceTab.value = _selectedTab;
    controller.minExperience.value = int.tryParse(minExpController.text);
    controller.minDailyRate.value = double.tryParse(minPriceController.text);
    controller.maxDailyRate.value = double.tryParse(maxPriceController.text);
    controller.horseMinCapacity.value = int.tryParse(minCapacityController.text);
    controller.horseMaxCapacity.value = int.tryParse(maxCapacityController.text);
    
    controller.groomingServices.assignAll(_localGroomingServices.toList());
    controller.braidingServices.assignAll(_localBraidingServices.toList());
    controller.clippingServices.assignAll(_localClippingServices.toList());
    controller.farrierServices.assignAll(_localFarrierServices.toList());
    controller.bodyworkServices.assignAll(_localBodyworkServices.toList());
    controller.groomingSupport.assignAll(_localSupport.toList());
    controller.horseHandling.assignAll(_localHandling.toList());
    controller.additionalServices.assignAll(_localAdditional.toList());
    controller.travelPreferences.assignAll(_localTravel.toList());
    controller.groomingDisciplines.assignAll(_localDisciplines.toList());
    controller.groomingHorseLevels.assignAll(_localLevels.toList());
    controller.regionsCovered.assignAll(_localRegions.toList());

    controller.farrierIntake.assignAll(_localFarrierIntake.toList());
    controller.farrierTimeframe.assignAll(_localFarrierTimeframe.toList());
    controller.farrierAvailabilityMode.value = _localFarrierAvailabilityMode;

    controller.bodyworkTimeframe.assignAll(_localBodyworkTimeframe.toList());
    controller.bodyworkLocationType.value = _localBodyworkLocationType;

    controller.shippingTravelScope.assignAll(_localShippingTravelScope.toList());
    controller.shippingStallTypes.assignAll(_localShippingStallTypes.toList());
    controller.shippingStartLocation.value = startLocationController.text;
    controller.shippingEndLocation.value = endLocationController.text;

    await controller.fetchVendors(showLoading: false);

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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
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
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 20, color: Color(0xFF4B5563)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Service Tabs
          _buildServiceTabs(),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFEAECF0), thickness: 1),
          const SizedBox(height: 16),

          // Scrollable Content
          Flexible(
            child: SingleChildScrollView(
              child: Obx(() {
                if (controller.isServiceTagsLoading.value) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ));
                }

                // Get dynamic options from controller
                final List dynamicTypes = controller.serviceTagTypes;
                
                final disciplineType = dynamicTypes.firstWhereOrNull((t) => t['name'] == 'Disciplines');
                final List<String> disciplineOptions = disciplineType != null
                    ? List<String>.from(disciplineType['values'].map((v) => v['name']))
                    : ['Eventing', 'Jumper', 'Hunter', 'Dressage'];

                final horseLevelType = dynamicTypes.firstWhereOrNull((t) => t['name'] == 'Typical Level of Horses');
                final List<String> levelOptions = horseLevelType != null
                    ? List<String>.from(horseLevelType['values'].map((v) => v['name']))
                    : ['A/AA Circuit', 'Grand Prix', 'Young Horses', 'FEI'];

                final regionType = dynamicTypes.firstWhereOrNull((t) => t['name'] == 'Regions Covered');
                final List<String> regionOptions = regionType != null
                    ? List<String>.from(regionType['values'].map((v) => v['name']))
                    : [
                        'Florida (Wellington • Ocala • Gulf Coast)',
                        'Southwest (Thermal • AZ winter circuit)',
                        'Southeast (Aiken • Tryon • Wills Park • Chatt Hills)'
                      ];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedTab == 'Groom') ...[
                      _buildChipSection('Grooming Services', [
                        'Grooming & Turnout', 'Wrapping & Bandaging', 
                        'Stall Upkeep & Daily Care', 'Show Prep (Non Braiding)'
                      ], _localGroomingServices),
                      
                      const SizedBox(height: 24),
                      _buildChipSection('Show and Barn Support', [
                        'Show Grooming', 'Monthly Jobs', 
                        'Fill-In Daily Grooming Support', 'Weekly Jobs',
                        'Seasonal Jobs', 'Travel Jobs'
                      ], _localSupport),
                      
                      const SizedBox(height: 24),
                      _buildChipSection('Horse Handling', [
                        'Lunging', 'Flat Riding (Exercise Only)', 'Stallion'
                      ], _localHandling),
                      
                      const SizedBox(height: 24),
                      _buildChipSection('Additional Services', [
                        'Hunter Braiding', 'Jumper Braiding', 
                        'Dressage Braiding', 'Clipping'
                      ], _localAdditional),
                    ] else if (_selectedTab == 'Braider') ...[
                      _buildChipSection('Braiding Services', [
                        'Hunter Mane & Tail', 'Hunter Mane Only', 'Hunter Tail Only', 
                        'Jumper Braids', 'Dressage Braids', 'Mane Pull / Clean Up'
                      ], _localBraidingServices),
                    ] else if (_selectedTab == 'Clipping') ...[
                      _buildChipSection('Clipping Services', [
                        'Full Body Clip', 'Hunter Clip', 'Trace Clip', 'Bib Clip', 'Irish Clip', 'Touch Ups'
                      ], _localClippingServices),
                      const SizedBox(height: 24),
                      _buildChipSection('Add - Ons', [
                        'Bath & Clip Prep', 'Show Clean Up'
                      ], _localAdditional),
                    ] else if (_selectedTab == 'Farrier') ...[
                      _buildChipSection('Farrier Services', [
                        'Trimming', 'Front Shoes', 'Hind Shoes', 'Full Set', 'Corrective / Therapeutic Work',
                        'Glue-on Shoes', 'Drill & Tap', 'Specialty Shoes (bar shoes, pads, wedges, etc.)',
                        'Barefoot / Natural Trim Specialist',
                      ], _localFarrierServices),
                      const SizedBox(height: 24),
                      _buildChipSection('Add - Ons', [
                        'Aluminum'
                      ], _localAdditional),
                      const SizedBox(height: 24),
                      _buildChipSection('Client Intake & Scheduling', [
                        'Accepting new clients', 'Limited availability', 'Referral-only', 'Not accepting new clients'
                      ], _localFarrierIntake),
                    ] else if (_selectedTab == 'Bodywork') ...[
                      _buildChipSection('Bodywork Services', [
                        'Sports massage', 'Myofascial release', 'PEMF', 'Chiropractic', 'Acupuncture', 'Laser therapy', 'Red Light'
                      ], _localBodyworkServices),
                    ] else if (_selectedTab == 'Shipping') ...[
                      _buildLabel('Start Location'),
                      const SizedBox(height: 8),
                      _buildLocationField(startLocationController, 'Select Start Location'),
                      const SizedBox(height: 20),
                      _buildLabel('End Location'),
                      const SizedBox(height: 8),
                      _buildLocationField(endLocationController, 'Select Show Venue or City'),
                      const SizedBox(height: 24),
                      _buildChipSection('Travel Scope', [
                        'Local', 'Nationwide', 'State-wide', 'Regional (North East, South East etc.)'
                      ], _localShippingTravelScope),
                      const SizedBox(height: 24),
                      _buildChipSection('Stall Type', [
                        'Box Stall', 'Slant Load', 'Front Facing', 'Rear Facing'
                      ], _localShippingStallTypes),
                    ],

                    if (_selectedTab != 'Shipping') ...[
                      const SizedBox(height: 24),
                      _buildChipSection('Travel Preferences',['Local Only', 'Regional'], _localTravel),
                    ],

                    if (_selectedTab == 'Groom' || _selectedTab == 'Braider' || _selectedTab == 'Farrier' || _selectedTab == 'Bodywork' || _selectedTab=="Clipping") ...[
                      const SizedBox(height: 24),
                      _buildChipSection('Disciplines', disciplineOptions, _localDisciplines),
                      
                      const SizedBox(height: 24),
                      _buildChipSection('Typical Level of Horses', levelOptions, _localLevels),
                    ],

                    const SizedBox(height: 24),
                    _buildChipSection('Regions Covered', regionOptions, _localRegions),

                    if (_selectedTab == 'Farrier' || _selectedTab == 'Bodywork' ||  _selectedTab=="Clipping") ...[
                      const SizedBox(height: 24),
                      _buildChipSection('Timeframe', [
                        'Full Day', 'AM', 'PM'
                      ], _selectedTab == 'Farrier' ? _localFarrierTimeframe : _localBodyworkTimeframe),
                    ],

                    if (_selectedTab == 'Farrier') ...[
                      const SizedBox(height: 24),
                      _buildRadioChipSection('Availability Mode', [
                        'General Bookings', 'Emergency-only'
                      ], _localFarrierAvailabilityMode, (val) => setState(() => _localFarrierAvailabilityMode = val)),
                    ],

                    if (_selectedTab == 'Bodywork') ...[
                      const SizedBox(height: 24),
                      _buildRadioChipSection('Location Type', [
                        'Both', 'Barn', 'Show Venue'
                      ], _localBodyworkLocationType, (val) => setState(() => _localBodyworkLocationType = val)),
                    ],
                    
                    const SizedBox(height: 24),
                    _buildTextFieldRow('Horse Min Capacity', 'Horse Max Capacity', 'Enter Capacity', 'Enter Capacity', minCapacityController, maxCapacityController),
                    const SizedBox(height: 20),
                  ],
                );
              }),
            ),
          ),
          // Buttons
          Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 10, top: 10),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearAll,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFEAECF0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const CommonText('Clear all', color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isApplying ? null : _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00083B),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isApplying
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const CommonText('Show results', color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTabs() {
    final List<String> tabs = ['Groom', 'Braider', 'Clipping', 'Farrier', 'Bodywork', 'Shipping'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.map((tab) {
          final isSelected = _selectedTab == tab;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedTab = tab);
              // Fetch corresponding tags
              if (tab == 'Groom') {
                controller.fetchServiceTags('Grooming');
              } else if (tab == 'Braider') {
                controller.fetchServiceTags('Braiding');
              } else if (tab == 'Clipping') {
                controller.fetchServiceTags('Clipping');
              } else if (tab == 'Farrier') {
                controller.fetchServiceTags('Farrier');
              } else if (tab == 'Bodywork') {
                controller.fetchServiceTags('Bodywork');
              } else if (tab == 'Shipping') {
                controller.fetchServiceTags('Shipping');
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF8B4545) : const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CommonText(
                tab,
                color: isSelected ? Colors.white : const Color(0xFF667085),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return CommonText(text, fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.bold);
  }

  Widget _buildNumberField(TextEditingController controller, String hint) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTextFieldRow(String label1, String label2, String hint1, String hint2, TextEditingController controller1, TextEditingController controller2, {bool isDecimal = false}) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel(label1),
              const SizedBox(height: 8),
              _buildNumberField(controller1, hint1),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel(label2),
              const SizedBox(height: 8),
              _buildNumberField(controller2, hint2),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChipSection(String title, List<String> options, Set<String> localSet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(title),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final isSelected = localSet.contains(opt);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    localSet.remove(opt);
                  } else {
                    localSet.add(opt);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF00083B) : const Color(0xFFEAECF0),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: CommonText(
                  opt,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? const Color(0xFF00083B) : const Color(0xFF475467),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRadioChipSection(String title, List<String> options, String currentValue, Function(String) onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(title),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final isSelected = currentValue == opt;
            return GestureDetector(
              onTap: () => onSelected(opt),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF00083B) : const Color(0xFFEAECF0),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: CommonText(
                  opt,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? const Color(0xFF00083B) : const Color(0xFF475467),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLocationField(TextEditingController controller, String hint) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        readOnly: true, // Assuming it opens a picker
        onTap: () {
          // TODO: Open location picker
        },
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.textSecondary),
          suffixIcon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
