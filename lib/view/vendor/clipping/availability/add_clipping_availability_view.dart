import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/vendor_availability_controller.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:catch_ride/models/vendor_availability_model.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddClippingAvailabilityView extends StatefulWidget {
  const AddClippingAvailabilityView({super.key});

  @override
  State<AddClippingAvailabilityView> createState() => _AddClippingAvailabilityViewState();
}

class _AddClippingAvailabilityViewState extends State<AddClippingAvailabilityView> {
  final controller = Get.put(VendorAvailabilityController());
  final profileController = Get.put(ProfileController());

  final RxBool _isSubmitting = false.obs;
  VendorAvailabilityModel? _editingBlock;

  // Form State
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _unStart;
  DateTime? _unEnd;

  final RxString _locationType = 'Both'.obs;
  final RxString _availabilityType = 'Full Day'.obs;
  final RxString _capacityType = 'Max horses per day'.obs;
  final RxInt _maxHorses = 6.obs;
  
  final _notesController = TextEditingController();
  final _venueSearchController = TextEditingController();
  final RxList<String> _addedVenues = <String>[].obs;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map && args['block'] is VendorAvailabilityModel) {
      _editingBlock = args['block'];
      _preFillForm();
    }
  }

  void _preFillForm() {
    if (_editingBlock == null) return;
    _startDate = _editingBlock!.startDate;
    _endDate = _editingBlock!.endDate;
    _unStart = _editingBlock!.unavailableStart;
    _unEnd = _editingBlock!.unavailableEnd;
    
    _notesController.text = _editingBlock!.notes ?? '';
    _maxHorses.value = _editingBlock!.maxBookings;
    
    if (_editingBlock!.locationType != null) _locationType.value = _editingBlock!.locationType!;
    if (_editingBlock!.timeBlockType != null) _availabilityType.value = _editingBlock!.timeBlockType!;
    if (_editingBlock!.capacityType != null) _capacityType.value = _editingBlock!.capacityType!;
    
    _addedVenues.assignAll(_editingBlock!.showVenues);
  }

  Future<void> _selectDate(BuildContext context, {required bool isStart, bool isUnavailability = false}) async {
    DateTime initial = DateTime.now();
    if (isUnavailability) {
      initial = isStart ? (_unStart ?? initial) : (_unEnd ?? initial);
    } else {
      initial = isStart ? (_startDate ?? initial) : (_endDate ?? initial);
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        if (isUnavailability) {
          if (isStart) _unStart = picked; else _unEnd = picked;
        } else {
          if (isStart) _startDate = picked; else _endDate = picked;
        }
      });
    }
  }

  void _submit() async {
    if (_startDate == null || _endDate == null) {
      Get.snackbar('Error', 'Please select availability dates', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (_addedVenues.isEmpty) {
      Get.snackbar('Error', 'Please add at least one venue or city', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    _isSubmitting.value = true;
    try {
      final user = controller.authController.currentUser.value;
      if (user == null) return;

      int mongoDay = _startDate!.weekday == 7 ? 0 : _startDate!.weekday;

      final payload = {
        'vendorId': user.vendorProfileId,
        'vendorName': user.fullName,
        'createdBy': user.id,
        'availabilityType': 'one-time',
        'dayOfWeek': mongoDay,
        'specificDate': _startDate!.toIso8601String(),
        'startDate': _startDate!.toIso8601String(),
        'endDate': _endDate!.toIso8601String(),
        'unavailableStart': _unStart?.toIso8601String(),
        'unavailableEnd': _unEnd?.toIso8601String(),
        'showVenues': _addedVenues.toList(),
        'serviceTypes': ['Clipping'],
        'locationType': _locationType.value,
        'timeBlockType': _availabilityType.value,
        'capacityType': _capacityType.value,
        'maxBookings': _maxHorses.value,
        'notes': _notesController.text.trim(),
        'status': 'available',
      };

      if (_editingBlock != null && _editingBlock!.id != null) {
        await controller.updateAvailabilityBlock(_editingBlock!.id!, payload);
      } else {
        await controller.createAvailabilityBlock(payload);
      }
      
      Get.back();
      Get.snackbar('Success', 'Availability saved successfully', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      _isSubmitting.value = false;
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: CommonText(_editingBlock != null ? 'Edit Availability' : 'Add Availability', fontSize: AppTextSizes.size18, fontWeight: FontWeight.bold),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildBlockCard(),
            const SizedBox(height: 32),
            _buildFooterButtons(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CommonText('Block 1', fontSize: 16, fontWeight: FontWeight.bold),
              const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Availability'),
          Row(
            children: [
              Expanded(child: _buildDatePickerField('Start Date', _startDate, () => _selectDate(context, isStart: true))),
              const SizedBox(width: 16),
              Expanded(child: _buildDatePickerField('End Date', _endDate, () => _selectDate(context, isStart: false))),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Mark Unavailability'),
          Row(
            children: [
              Expanded(child: _buildDatePickerField('Start Date', _unStart, () => _selectDate(context, isStart: true, isUnavailability: true))),
              const SizedBox(width: 16),
              Expanded(child: _buildDatePickerField('End Date', _unEnd, () => _selectDate(context, isStart: false, isUnavailability: true))),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Location Type'),
          _buildDropdownField(_locationType, ['Both', 'Barn', 'Show Venue']),
          const SizedBox(height: 24),
          _buildVenueSection(),
          const SizedBox(height: 24),
          _buildSectionHeader('Time Block & Capacity'),
          const CommonText('Availability Type', fontSize: 13, fontWeight: FontWeight.bold),
          const SizedBox(height: 8),
          _buildDropdownField(_availabilityType, ['Full Day', 'AM', 'PM']),
          const SizedBox(height: 16),
          const CommonText('Capacity', fontSize: 13, fontWeight: FontWeight.bold),
          const SizedBox(height: 8),
          _buildDropdownField(_capacityType, ['No capacity limit', 'Max horses per time block', 'Max horses per day']),
          const SizedBox(height: 16),
          const CommonText('Max Horses', fontSize: 13, fontWeight: FontWeight.bold),
          const SizedBox(height: 8),
          _buildStepperField(),
          const SizedBox(height: 24),
          const CommonText('Notes For Trainers (optional)', fontSize: 14, fontWeight: FontWeight.bold),
          const SizedBox(height: 8),
          _buildNotesField(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CommonText(title, fontSize: 14, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDatePickerField(String label, DateTime? date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: 12, color: AppColors.textSecondary),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonText(
                  date != null ? DateFormat('MM/dd/yyyy').format(date) : 'Select Date',
                  fontSize: 14, 
                  color: date != null ? AppColors.textPrimary : AppColors.textSecondary
                ),
                const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(RxString selectedValue, List<String> options) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: DropdownButtonHideUnderline(
        child: Obx(() => DropdownButton<String>(
          value: selectedValue.value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          items: options.map((opt) => DropdownMenuItem(value: opt, child: CommonText(opt, fontSize: 14))).toList(),
          onChanged: (val) { if (val != null) selectedValue.value = val; },
        )),
      ),
    );
  }

  Widget _buildStepperField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: () { if (_maxHorses.value > 1) _maxHorses.value--; }, icon: const Icon(Icons.remove, size: 18, color: AppColors.textSecondary)),
          Obx(() => CommonText('${_maxHorses.value}', fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(onPressed: () => _maxHorses.value++, icon: const Icon(Icons.add, size: 18, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildVenueSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Show Venue or City'),
        const SizedBox(height: 12),
        TextField(
          controller: _venueSearchController,
          readOnly: true,
          onTap: _showVenueSelectionSheet,
          decoration: InputDecoration(
            hintText: 'Select Show Venue or City',
            hintStyle: const TextStyle(color: Color(0xFF667085), fontSize: 14),
            suffixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF667085)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        Obx(() {
          if (_addedVenues.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _addedVenues.map((v) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7), 
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFEAECF0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(child: CommonText(v, fontSize: 13, color: AppColors.textPrimary, overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _addedVenues.remove(v),
                      child: const Icon(Icons.close, size: 14, color: Color(0xFF98A2B3)),
                    ),
                  ],
                ),
              )).toList(),
            ),
          );
        }),
      ],
    );
  }

  void _showVenueSelectionSheet() {
    final searchController = TextEditingController();
    
    // Deduplicate venues by display name before showing the list
    final seenNames = <String>{};
    final List<Map<String, dynamic>> allVenues = profileController.rawHorseShows.where((v) {
      final name = v['showVenue']?.toString() ?? v['name']?.toString() ?? 'Unknown';
      if (seenNames.contains(name)) return false;
      seenNames.add(name);
      return true;
    }).toList();

    final RxList<Map<String, dynamic>> filteredVenues = RxList<Map<String, dynamic>>(allVenues);
    
    Get.bottomSheet(
      Container(
        height: Get.height * 0.85,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CommonText('Select Venues', fontSize: 18, fontWeight: FontWeight.bold),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search venues or city...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) {
                final search = val.toLowerCase();
                filteredVenues.assignAll(allVenues.where((v) {
                  final name = v['name']?.toString().toLowerCase() ?? '';
                  final showVenue = v['showVenue']?.toString().toLowerCase() ?? '';
                  final city = v['city']?.toString().toLowerCase() ?? '';
                  return name.contains(search) || showVenue.contains(search) || city.contains(search);
                }).toList());
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() => ListView.builder(
                itemCount: filteredVenues.length,
                itemBuilder: (context, index) {
                  final venueItem = filteredVenues[index];
                  // Prioritize 'showVenue' key as requested, then 'name'
                  final venueName = venueItem['showVenue']?.toString() ?? venueItem['name']?.toString() ?? 'Unknown';
                  final city = venueItem['city']?.toString() ?? '';
                  
                  return Obx(() {
                    final isSelected = _addedVenues.contains(venueName);
                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (selected) {
                        if (selected == true) {
                          if (!_addedVenues.contains(venueName)) _addedVenues.add(venueName);
                        } else {
                          _addedVenues.remove(venueName);
                        }
                      },
                      title: CommonText(venueName),
                      subtitle: city.isNotEmpty ? CommonText(city, fontSize: 12, color: Colors.grey) : null,
                      activeColor: AppColors.primary,
                    );
                  });
                },
              )),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const CommonText('Done', color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      maxLines: 4,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText: 'Any specific preference, requirements, or information trainers should know...',
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        fillColor: const Color(0xFFF9FAFB),
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEAECF0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEAECF0))),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildFooterButtons() {
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
            text: _editingBlock != null ? 'Save Changes' : 'Add Block',
            backgroundColor: AppColors.primary,
            isLoading: _isSubmitting.value,
            onPressed: _submit,
          )),
        ),
      ],
    );
  }
}
