import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/vendor_availability_controller.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:catch_ride/models/show_venue_location.dart';
import 'package:catch_ride/models/vendor_availability_model.dart';
import 'package:catch_ride/widgets/vendor/vendor_show_venue_section.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../controllers/vendor/groom/groom_view_profile_controller.dart';

class AddClippingAvailabilityView extends StatefulWidget {
  const AddClippingAvailabilityView({super.key});

  @override
  State<AddClippingAvailabilityView> createState() =>
      _AddClippingAvailabilityViewState();
}

class _AddClippingAvailabilityViewState
    extends State<AddClippingAvailabilityView> {
  final controller = Get.put(VendorAvailabilityController());
  final profileController = Get.put(ProfileController());
  final GroomViewProfileController groomController = Get.put(GroomViewProfileController());
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
  final RxList<ShowVenueLocation> _addedVenues = <ShowVenueLocation>[].obs;

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

    if (_editingBlock!.locationType != null)
      _locationType.value = _editingBlock!.locationType!;
    if (_editingBlock!.timeBlockType != null)
      _availabilityType.value = _editingBlock!.timeBlockType!;
    if (_editingBlock!.capacityType != null)
      _capacityType.value = _editingBlock!.capacityType!;

    _addedVenues.assignAll(_editingBlock!.showVenues);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: (_startDate != null && _endDate != null)
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _selectBlackoutDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _unStart ?? DateTime.now(),
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
        _unStart = picked;
        _unEnd = picked; // Set both to the same date for single day blackout
      });
    }
  }

  void _submit() async {
    if (_startDate == null || _endDate == null) {
      Get.snackbar(
        'Error',
        'Please select availability dates',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (_addedVenues.isEmpty) {
      Get.snackbar(
        'Error',
        'Please add at least one venue or city',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
        'showVenues': ShowVenueLocation.listToApiPayload(_addedVenues),
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
groomController.fetchProfile();
      Get.back();
      Get.snackbar(
        'Success',
        'Availability saved successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
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
        title: CommonText(
          _editingBlock != null ? 'Edit Availability' : 'Add Availability',
          fontSize: AppTextSizes.size18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            _buildBlockCard(),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  Widget _buildBlockCard() {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommonText(_editingBlock != null ? 'Edit Block' : 'Block 1', fontSize: 16, fontWeight: FontWeight.bold),
            ],
          ),
          const SizedBox(height: 24),
          _buildDateSection(),
          const SizedBox(height: 24),
          _buildSectionHeader('Black out days'),
          const SizedBox(height: 12),
          _buildDateField('Date', _unStart, _selectBlackoutDate),
          const SizedBox(height: 24),
          _buildSectionHeader('Location Type'),
          _buildDropdownField(_locationType, ['Both', 'Barn', 'Show Venue']),
          const SizedBox(height: 24),
          VendorShowVenueSection(
            venues: _addedVenues,
            includeGooglePlaces: false,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Time Block & Capacity'),
          const CommonText(
            'Availability Type',
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 8),
          _buildDropdownField(_availabilityType, ['Full Day', 'Morning window', 'Afternoon window']),
          const SizedBox(height: 16),
          const CommonText(
            'Capacity',
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 8),
          _buildDropdownField(_capacityType, [
            'No capacity limit',
            'Max horses per time block',
            'Max horses per day',
          ]),
          const SizedBox(height: 16),
          const CommonText(
            'Max Horses',
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 8),
          _buildStepperField(),
          const SizedBox(height: 24),
          const CommonText(
            'Notes For Trainers (optional)',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
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



  Widget _buildDropdownField(RxString selectedValue, List<String> options) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: DropdownButtonHideUnderline(
        child: Obx(
          () => DropdownButton<String>(
            value: selectedValue.value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down, size: 20),
            items: options
                .map(
                  (opt) => DropdownMenuItem(
                    value: opt,
                    child: CommonText(opt, fontSize: 14),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) selectedValue.value = val;
            },
          ),
        ),
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
          IconButton(
            onPressed: () {
              if (_maxHorses.value > 1) _maxHorses.value--;
            },
            icon: const Icon(
              Icons.remove,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
          Obx(
            () => CommonText(
              '${_maxHorses.value}',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () => _maxHorses.value++,
            icon: const Icon(
              Icons.add,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      maxLines: 4,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText:
            'Any specific preference, requirements, or information trainers should know...',
        hintStyle: const TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
        fillColor: const Color(0xFFF9FAFB),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEAECF0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEAECF0)),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Availability'),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD0D5DD)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonText(
                  (_startDate != null && _endDate != null)
                      ? '${DateFormat('MMMM d, yyyy').format(_startDate!)} - ${DateFormat('MMMM d, yyyy').format(_endDate!)}'
                      : 'Select Date Range',
                  fontSize: 14,
                  color: _startDate != null ? const Color(0xFF344054) : const Color(0xFF98A2B3),
                ),
                const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF667085)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF344054)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD0D5DD)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonText(
                  date != null ? DateFormat('MMMM d, yyyy').format(date) : 'Select date',
                  fontSize: 14,
                  color: date != null ? const Color(0xFF344054) : const Color(0xFF98A2B3),
                ),
                const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF667085)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF2F4F7))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFEAECF0)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: Colors.white,
              ),
              child: const CommonText('Cancel', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Obx(() => ElevatedButton(
              onPressed: _isSubmitting.value ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF000B3D),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSubmitting.value
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : CommonText(_editingBlock != null ? 'Save Changes' : 'Add Block', color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            )),
          ),
        ],
      ),
    );
  }
}
