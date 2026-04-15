import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/vendor_availability_controller.dart';
import 'package:catch_ride/models/vendor_availability_model.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../controllers/profile_controller.dart';

class AddFarrierAvailabilityView extends StatefulWidget {
  const AddFarrierAvailabilityView({super.key});

  @override
  State<AddFarrierAvailabilityView> createState() => _AddFarrierAvailabilityViewState();
}

class _AddFarrierAvailabilityViewState extends State<AddFarrierAvailabilityView> {
  final controller = Get.put(VendorAvailabilityController());
  final profileController = Get.put(ProfileController());

  final RxBool _isSubmitting = false.obs;
  VendorAvailabilityModel? _editingBlock;

  // Date state
  DateTime? _startDate;
  DateTime? _endDate;

  // Farrier specific state
  final RxString _timeWindow = 'Full Day'.obs;
  final RxString _availabilityMode = 'General bookings'.obs;
  final RxInt _minHorses = 6.obs;
  final RxString _newClientPolicy = 'Accepting new clients'.obs;
  final RxList<String> _addedVenues = <String>[].obs;
  final _notesController = TextEditingController();

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
    _minHorses.value = _editingBlock!.maxBookings;
    
    if (_editingBlock!.timeBlockType != null) _timeWindow.value = _editingBlock!.timeBlockType!;
    if (_editingBlock!.availabilityMode != null) _availabilityMode.value = _editingBlock!.availabilityMode!;
    if (_editingBlock!.newClientPolicy != null) _newClientPolicy.value = _editingBlock!.newClientPolicy!;
    
    _addedVenues.assignAll(_editingBlock!.showVenues);
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
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
        if (isStart) _startDate = picked;
        else _endDate = picked;
      });
    }
  }

  void _submit() async {
    if (_startDate == null || _endDate == null) {
      Get.snackbar('Error', 'Please select start and end dates', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (_addedVenues.isEmpty) {
      Get.snackbar('Error', 'Please add at least one venue', backgroundColor: Colors.red, colorText: Colors.white);
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
        'showVenues': _addedVenues.toList(),
        'serviceTypes': ['Farrier'],
        'maxBookings': _minHorses.value,
        'notes': _notesController.text.trim(),
        'status': 'available',
        'timeBlockType': _timeWindow.value,
        'availabilityMode': _availabilityMode.value,
        'newClientPolicy': _newClientPolicy.value,
      };

      if (_editingBlock != null && _editingBlock!.id != null) {
        await controller.updateAvailabilityBlock(_editingBlock!.id!, payload);
      } else {
        await controller.createAvailabilityBlock(payload);
      }
      
      Get.back();
      Get.snackbar('Success', _editingBlock != null ? 'Availability updated' : 'Availability created', backgroundColor: Colors.green, colorText: Colors.white);
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
        title: const CommonText('Add Availability Block', fontSize: AppTextSizes.size18, fontWeight: FontWeight.bold),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
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
                  CommonText(_editingBlock != null ? 'Edit Block' : 'Block 1', fontSize: 16, fontWeight: FontWeight.bold),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close, color: Colors.grey, size: 20)),
                ],
              ),
              const SizedBox(height: 24),
              _buildDateSection(),
              const SizedBox(height: 24),
              const CommonText('Timeframe', fontSize: 14, fontWeight: FontWeight.bold),
              const SizedBox(height: 8),
              _buildDropdownField(_timeWindow, ['Full Day', 'AM', 'PM']),
              const SizedBox(height: 24),
              _buildVenueSection(),
              const SizedBox(height: 24),
              const CommonText('Availability Mode', fontSize: 14, fontWeight: FontWeight.bold),
              const SizedBox(height: 8),
              _buildDropdownField(_availabilityMode, ['General bookings', 'Emergency-only']),
              const SizedBox(height: 24),
              const CommonText('Minimum horses per stop', fontSize: 14, fontWeight: FontWeight.bold),
              const SizedBox(height: 12),
              _buildCounter(_minHorses),
              const SizedBox(height: 24),
              const CommonText('New Client Policy', fontSize: 14, fontWeight: FontWeight.bold),
              const SizedBox(height: 12),
              _buildRadioGroup(_newClientPolicy, ['Accepting new clients', 'Limited availability', 'Referral-only', 'Not accepting new clients']),
              const SizedBox(height: 24),
              const CommonText('Notes For Trainers (optional)', fontSize: 14, fontWeight: FontWeight.bold),
              const SizedBox(height: 12),
              _buildNotesField(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  Widget _buildDateSection() {
    return Row(
      children: [
        Expanded(child: _buildDateField('Start Date', _startDate, () => _selectDate(context, true))),
        const SizedBox(width: 16),
        Expanded(child: _buildDateField('End Date', _endDate, () => _selectDate(context, false))),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: 14, fontWeight: FontWeight.bold),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonText(date != null ? DateFormat('MM/dd/yyyy').format(date) : 'Select date', fontSize: 14, color: date != null ? AppColors.textPrimary : Colors.grey),
                const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
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
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
      child: DropdownButtonHideUnderline(
        child: Obx(() => DropdownButton<String>(
          value: selectedValue.value,
          isExpanded: true,
          items: options.map((opt) => DropdownMenuItem(value: opt, child: CommonText(opt, fontSize: 14))).toList(),
          onChanged: (val) { if (val != null) selectedValue.value = val; },
        )),
      ),
    );
  }

  Widget _buildVenueSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText('Show Venue or City', fontSize: 14, fontWeight: FontWeight.bold),
        const SizedBox(height: 8),
        InkWell(
          onTap: _showVenueSelectionSheet,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => CommonText(_addedVenues.isEmpty ? 'Enter Show Venue or City' : '${_addedVenues.length} Venues selected', fontSize: 14, color: _addedVenues.isEmpty ? Colors.grey : AppColors.textPrimary)),
                const Icon(Icons.search, size: 20, color: Colors.grey),
              ],
            ),
          ),
        ),
        Obx(() => _addedVenues.isEmpty ? const SizedBox.shrink() : Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Wrap(
            spacing: 8, runSpacing: 8,
            children: _addedVenues.map((v) => Chip(
              label: CommonText(v, fontSize: 12),
              onDeleted: () => _addedVenues.remove(v),
              backgroundColor: const Color(0xFFF2F4F7),
            )).toList(),
          ),
        )),
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
        height: Get.height * 0.8,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CommonText('Select Venues', fontSize: 18, fontWeight: FontWeight.bold),
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
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() => ListView.builder(
                itemCount: filteredVenues.length,
                itemBuilder: (ctx, i) {
                  final venueItem = filteredVenues[i];
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
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () => Get.back(), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const CommonText('Done', color: Colors.white))),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildCounter(RxInt count) {
    return Container(
      height: 52,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: () { if (count.value > 1) count.value--; }, icon: const Icon(Icons.remove)),
          Obx(() => CommonText('${count.value}', fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(onPressed: () => count.value++, icon: const Icon(Icons.add)),
        ],
      ),
    );
  }

  Widget _buildRadioGroup(RxString selected, List<String> options) {
    return Column(children: options.map((opt) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => selected.value = opt,
        child: Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: selected.value == opt ? AppColors.primary : AppColors.borderLight, width: selected.value == opt ? 1.5 : 1)),
          child: Row(children: [
            Icon(selected.value == opt ? Icons.radio_button_checked : Icons.radio_button_off, color: selected.value == opt ? AppColors.primary : Colors.grey, size: 20),
            const SizedBox(width: 12),
            CommonText(opt, fontSize: 14, fontWeight: selected.value == opt ? FontWeight.bold : FontWeight.w500),
          ]),
        )),
      ),
    )).toList());
  }

  Widget _buildNotesField() {
    return TextField(
      controller: _notesController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Any specific info...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      color: Colors.white,
      child: Row(children: [
        Expanded(child: CommonButton(text: 'Cancel', backgroundColor: Colors.white, textColor: AppColors.textPrimary, borderColor: AppColors.borderLight, onPressed: () => Get.back())),
        const SizedBox(width: 16),
        Expanded(child: Obx(() => CommonButton(text: _editingBlock != null ? 'Save' : 'Add Block', backgroundColor: AppColors.primary, isLoading: _isSubmitting.value, onPressed: _submit))),
      ]),
    );
  }
}
