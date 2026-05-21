import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/vendor_availability_controller.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:catch_ride/models/show_venue_location.dart';
import 'package:catch_ride/models/vendor_availability_model.dart';
import 'package:catch_ride/widgets/vendor/vendor_show_venue_section.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../controllers/vendor/groom/groom_view_profile_controller.dart';

class BraidingAddAvailabilityView extends StatefulWidget {
  const BraidingAddAvailabilityView({super.key});

  @override
  State<BraidingAddAvailabilityView> createState() =>
      _BraidingAddAvailabilityViewState();
}

class _BraidingAddAvailabilityViewState
    extends State<BraidingAddAvailabilityView> {
  final controller = Get.put(VendorAvailabilityController());
  final profileController = Get.put(ProfileController());
  final GroomViewProfileController groomController = Get.put(
    GroomViewProfileController(),
  );

  final RxBool _isSubmitting = false.obs;
  VendorAvailabilityModel? _editingBlock;

  // Form State
  DateTime? _startDate;
  DateTime? _endDate;
  final _notesController = TextEditingController();
  final RxList<ShowVenueLocation> _selectedVenues = <ShowVenueLocation>[].obs;
  final RxInt _maxHorses = 6.obs;
  final RxInt _maxDays = 12.obs;

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
    _notesController.text = _editingBlock!.notes ?? '';
    _maxHorses.value = _editingBlock!.maxBookings;
    _maxDays.value = _editingBlock!.maxDays ?? 12;
    _selectedVenues.assignAll(_editingBlock!.showVenues);

    // Handle service types
    for (var s in _editingBlock!.serviceTypes) {
      if (s == 'Braiding') continue;
      if (_availableWorkTypes.contains(s)) {
        _selectedWorkTypes.add(s);
      } else {
        _selectedServiceTypes.add(s);
      }
    }
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
              primary: AppColors.primaryDark,
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

  void _submit() async {
    if (_startDate == null || _endDate == null) {
      Get.snackbar(
        'Error',
        'Please select start and end dates',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_selectedVenues.isEmpty) {
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

      final String? vendorId = user.vendorProfileId;
      final String? userId = user.id;

      if (vendorId == null || userId == null) {
        Get.snackbar(
          'Error',
          'Vendor profile not found',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Combine categories, work types, and services into serviceTypes
      final allServices = <String>{};
      allServices.add('Braiding');
      allServices.addAll(_selectedWorkTypes);
      allServices.addAll(_selectedServiceTypes);

      final payload = {
        'vendorId': vendorId,
        'vendorName': user.fullName,
        'createdBy': userId,
        'availabilityType': 'one-time',
        'dayOfWeek': _startDate!.weekday == 7 ? 0 : _startDate!.weekday,
        'specificDate': _startDate!.toIso8601String(),
        'startDate': _startDate!.toIso8601String(),
        'endDate': _endDate!.toIso8601String(),
        'showVenues': ShowVenueLocation.listToApiPayload(_selectedVenues),
        'serviceTypes': allServices.toList(),
        'maxBookings': _maxHorses.value,
        'maxDays': _maxDays.value,
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
        _editingBlock != null
            ? 'Availability block updated'
            : 'Availability block created',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('Error creating/updating availability block: $e');
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
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'Add Availability Block',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF2F4F7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
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
                  CommonText(
                    _editingBlock != null ? 'Edit Block' : 'Block 1',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDateSection(),
              const SizedBox(height: 24),
              VendorShowVenueSection(
                venues: _selectedVenues,
                includeGooglePlaces: false,
              ),
              const SizedBox(height: 24),
              _buildCapacitySection(),
              const SizedBox(height: 24),
              _buildNotesSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  Widget _buildSectionHeader(String title) {
    return CommonText(
      title,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    );
  }

  List<String> get _availableWorkTypes => [
    'Show week support',
    'Daily barn help',
    'Fill In/ daily show support',
    'Seasonal / Temporary',
  ];
  List<String> get _availableServiceTypes => [
    'Hunter Braiding Mane',
    'Jumper Braiding',
  ];

  final RxList<String> _selectedWorkTypes = <String>[].obs;
  final RxList<String> _selectedServiceTypes = <String>[].obs;

  Widget _buildSelectionWrap(List<String> items, RxList<String> selectionList) {
    return Obx(
      () => Wrap(
        spacing: 12,
        runSpacing: 12,
        children: items.map((t) {
          final isSelected = selectionList.contains(t);
          return InkWell(
            onTap: () {
              isSelected ? selectionList.remove(t) : selectionList.add(t);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFF5F8FF) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryDark
                      : const Color(0xFFD0D5DD),
                  width: 1,
                ),
              ),
              child: CommonText(
                t,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? AppColors.primaryDark
                    : const Color(0xFF344054),
              ),
            ),
          );
        }).toList(),
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
                  color: _startDate != null
                      ? const Color(0xFF344054)
                      : const Color(0xFF98A2B3),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: Color(0xFF667085),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField(
    String label,
    DateTime? date,
    VoidCallback onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          label,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF344054),
        ),
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
                  date != null
                      ? DateFormat('MMMM d, yyyy').format(date)
                      : 'Select date',
                  fontSize: 14,
                  color: date != null
                      ? const Color(0xFF344054)
                      : const Color(0xFF98A2B3),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: Color(0xFF667085),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCapacitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText(
          'Capacity (optional)',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF344054),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildCounter('Max Horses', _maxHorses)),
            const SizedBox(width: 16),
            Expanded(child: _buildCounter('Max Days', _maxDays)),
          ],
        ),
      ],
    );
  }

  Widget _buildCounter(String label, RxInt count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          label,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF344054),
        ),
        const SizedBox(height: 8),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFEAECF0)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  if (count.value > 0) count.value--;
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.remove,
                    size: 16,
                    color: Color(0xFF667085),
                  ),
                ),
              ),
              Obx(
                () => CommonText(
                  '${count.value}',
                  fontSize: 18,
                  color: const Color(0xFF344054),
                ),
              ),
              GestureDetector(
                onTap: () => count.value++,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 16,
                    color: Color(0xFF667085),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText(
          'Notes For Trainers (optional)',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF344054),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText:
                'Any specific preference, requirements, or information trainers should know...',
            hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 14),
            fillColor: const Color(0xFFF9FAFB),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.white,
              ),
              child: const CommonText(
                'Cancel',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Obx(
              () => ElevatedButton(
                onPressed: _isSubmitting.value ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF000B3D),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : CommonText(
                        _editingBlock != null ? 'Save Changes' : 'Add Block',
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
