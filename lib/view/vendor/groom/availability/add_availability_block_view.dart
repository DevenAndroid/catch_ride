import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/vendor_availability_controller.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../controllers/profile_controller.dart';
import '../../../../models/vendor_availability_model.dart';

class AddAvailabilityBlockView extends StatefulWidget {
  const AddAvailabilityBlockView({super.key});

  @override
  State<AddAvailabilityBlockView> createState() => _AddAvailabilityBlockViewState();
}

class _AddAvailabilityBlockViewState extends State<AddAvailabilityBlockView> {
  final controller = Get.put(VendorAvailabilityController());
  final profileController = Get.put(ProfileController());

  late int _categoryIndex;
  late String _categoryName;
  final RxBool _isSubmitting = false.obs;
  VendorAvailabilityModel? _editingBlock;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    
    // Initialize category first to prevent LateInitializationError
    if (args is Map) {
      _categoryIndex = args['categoryIndex'] ?? 0;
    } else {
      _categoryIndex = args ?? 0;
    }
    _categoryName = _categoryIndex == 0 ? 'Grooming' : (_categoryIndex == 1 ? 'Braiding' : (_categoryIndex == 2 ? 'Clipping' : 'Bodywork'));

    // Now handle pre-filling if editing
    if (args is Map && args['block'] is VendorAvailabilityModel) {
      _editingBlock = args['block'];
      _preFillForm();
    }
    
    // Auto-select the category itself in serviceTypes if not editing
    if (_editingBlock == null) {
      _selectedServiceTypes.add(_categoryName);
    }
  }

  void _preFillForm() {
    if (_editingBlock == null) return;
    _startDate = _editingBlock!.startDate;
    _endDate = _editingBlock!.endDate;
    _notesController.text = _editingBlock!.notes ?? '';
    
    // Explicitly set non-reactive fields immediately
    _maxHorses.value = _editingBlock!.maxBookings;
    _maxDays.value = 12; 

    // Clipping specific pre-filling
    _unStart = _editingBlock!.unavailableStart;
    _unEnd = _editingBlock!.unavailableEnd;
    
    if (_editingBlock!.locationType != null) {
      _locationType.value = _editingBlock!.locationType!;
    }
    if (_editingBlock!.timeBlockType != null) {
      _availabilityType.value = _editingBlock!.timeBlockType!;
    }
    if (_editingBlock!.capacityType != null) {
      _capacityType.value = _editingBlock!.capacityType!;
    }
    if (_editingBlock!.bufferTime != null) {
      _bufferTime.value = _editingBlock!.bufferTime!;
    }

    // Use a slight delay to ensure UI systems are fully hooked up
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      
      setState(() {
        _addedVenues.clear();
        
        // 1. Check primary field: showVenues (list)
        if (_editingBlock!.showVenues.isNotEmpty) {
          _addedVenues.assignAll(List<String>.from(_editingBlock!.showVenues));
        } 
        
        // 2. Check fallback: location.city (if legacy data)
        if (_addedVenues.isEmpty && _editingBlock!.location != null) {
          final city = _editingBlock!.location!.city;
          if (city.isNotEmpty) _addedVenues.add(city);
        }

        // 3. Re-process service types to ensure chips show up correctly
        _selectedWorkTypes.clear();
        _selectedServiceTypes.clear();
        for (var s in _editingBlock!.serviceTypes) {
          if (s == 'Grooming' || s == 'Braiding' || s == 'Clipping' || s == 'Bodywork') continue;
          
          if (_availableWorkTypes.contains(s)) {
            _selectedWorkTypes.add(s);
          } else {
            _selectedServiceTypes.add(s);
          }
        }
      });
      
      _addedVenues.refresh();
      _selectedWorkTypes.refresh();
      _selectedServiceTypes.refresh();
    });
  }

  // Date state
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _unStart;
  DateTime? _unEnd;

  // Text controllers
  final _notesController = TextEditingController();
  final _venueController = TextEditingController();

  // Lists
  final RxList<String> _addedVenues = <String>[].obs;
  final RxInt _maxHorses = 6.obs;
  final RxInt _maxDays = 12.obs;

  // Clipping strings
  final RxString _locationType = 'Both'.obs;
  final RxString _availabilityType = 'Full Day'.obs;
  final RxString _capacityType = 'Max horses per day'.obs;
  final RxString _bufferTime = '15 min'.obs;

  List<String> get _availableWorkTypes {
    return ['Show week support', 'Daily barn help', 'Fill In/ daily show support', 'Seasonal / Temporary'];
  }

  List<String> get _availableServiceTypes {
    return ['Hunter Braiding Mane', 'Jumper Braiding'];
  }

  final RxList<String> _selectedWorkTypes = <String>[].obs;
  final RxList<String> _selectedServiceTypes = <String>[].obs;

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime.now().subtract(const Duration(days: 365)), // Allow past for edit
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.secondary,
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

      final String? vendorId = user.vendorProfileId;
      final String? userId = user.id;

      if (vendorId == null || userId == null) {
        Get.snackbar('Error', 'Vendor profile not found', backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      // Combine categories, work types, and services into serviceTypes
      final allServices = <String>{};
      allServices.add(_categoryName);
      allServices.addAll(_selectedWorkTypes);
      allServices.addAll(_selectedServiceTypes);

      // Backend expects dayOfWeek as numeric: 0 (Sun) - 6 (Sat)
      int mongoDay = _startDate!.weekday == 7 ? 0 : _startDate!.weekday;

      final payload = {
        'vendorId': vendorId,
        'vendorName': user.fullName,
        'createdBy': userId,
        'availabilityType': 'one-time',
        'dayOfWeek': mongoDay,
        'specificDate': _startDate!.toIso8601String(),
        'startDate': _startDate!.toIso8601String(),
        'endDate': _endDate!.toIso8601String(),
        'showVenues': _addedVenues.toList(),
        'serviceTypes': allServices.toList(),
        'maxBookings': _maxHorses.value,
        'maxDays': _maxDays.value,
        'notes': _notesController.text.trim(),
        'status': 'available',
        'unavailableStart': _unStart?.toIso8601String(),
        'unavailableEnd': _unEnd?.toIso8601String(),
        'locationType': _locationType.value,
        'capacityType': _capacityType.value,
        'timeBlockType': _availabilityType.value,
        'bufferTime': _bufferTime.value,
      };

      if (_editingBlock != null && _editingBlock!.id != null) {
        await controller.updateAvailabilityBlock(_editingBlock!.id!, payload);
      } else {
        await controller.createAvailabilityBlock(payload);
      }
      
      Get.back();
      Get.snackbar('Success', _editingBlock != null ? 'Availability block updated' : 'Availability block created', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      debugPrint('Error creating/updating availability block: $e');
    } finally {
      _isSubmitting.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: _editingBlock != null
            ? Obx(() => CommonText(
                'Edit Block (DB:${_editingBlock!.showVenues.length}|UI:${_addedVenues.length})',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ))
            : const CommonText('Add Availability Block', fontSize: 16, fontWeight: FontWeight.bold),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textPrimary),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF2F4F7)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
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
                    CommonText(_editingBlock != null ? 'Edit Block' : 'Block 1', fontSize: 16, fontWeight: FontWeight.bold),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Icon(Icons.close, color: Colors.grey, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDateSection(),
                const SizedBox(height: 24),
                if (_categoryName == 'Bodywork') ...[
                  _buildSectionHeader('Time window'),
                  const SizedBox(height: 8),
                  _buildDropdownField('Full Day', _availabilityType, ['Full Day', 'Morning Window', 'Afternoon Window']),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Location Type'),
                  const SizedBox(height: 8),
                  _buildDropdownField('Select a Location Type', _locationType, ['Both', 'Barn', 'Show Venue']),
                  const SizedBox(height: 24),
                  _buildVenueSection(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Daily Session Capacity'),
                  const SizedBox(height: 12),
                  _buildCapacitySection(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Buffer Between Sessions'),
                  const SizedBox(height: 8),
                  _buildDropdownField('15 min', _bufferTime, ['15 min', '30 min', '45 min']),
                ] else if (_categoryName == 'Clipping') ...[
                  _buildSectionHeader('Location Type'),
                  const SizedBox(height: 8),
                  _buildDropdownField('Select a Location Type', _locationType, ['Both', 'Barn', 'Show Venue']),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Mark Unavailability'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildDateField('Start Date', _unStart, () => _selectUnavailabilityDate(true))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildDateField('End Date', _unEnd, () => _selectUnavailabilityDate(false))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildVenueSection(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Time Block & Capacity'),
                  const SizedBox(height: 12),
                  const CommonText('Availability Type', fontSize: 13, fontWeight: FontWeight.bold),
                  const SizedBox(height: 8),
                  _buildDropdownField('Full Day', _availabilityType, ['Full Day', 'AM', 'PM']),
                  const SizedBox(height: 16),
                  const CommonText('Capacity', fontSize: 13, fontWeight: FontWeight.bold),
                  const SizedBox(height: 8),
                  _buildDropdownField('Max horses per day', _capacityType, ['No capacity limit', 'Max horses per time block', 'Max horses per day']),
                  const SizedBox(height: 16),
                  _buildCapacitySection(),
                ] else if (_categoryName == 'Grooming' || _categoryName == 'Braiding') ...[
                  _buildVenueSection(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Work Type'),
                  const SizedBox(height: 12),
                  _buildSelectionWrap(_availableWorkTypes, _selectedWorkTypes),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Additional Services'),
                  const SizedBox(height: 12),
                  _buildSelectionWrap(_availableServiceTypes, _selectedServiceTypes),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Capacity (optional)'),
                  const SizedBox(height: 12),
                  _buildCapacitySection(),
                ],
                const SizedBox(height: 24),
                _buildSectionHeader('Notes For Trainers (optional)'),
                const SizedBox(height: 12),
                _buildNotesField(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  Widget _buildBlockHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CommonText('Block 1', fontSize: 16, fontWeight: FontWeight.bold),
          IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close, color: Colors.grey, size: 20)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return CommonText(title, fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary);
  }

  Widget _buildDateSection() {
    return Row(
      children: [
        Expanded(
          child: _buildDateField('Start Date', _startDate, () => _selectDate(context, true)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDateField('End Date', _endDate, () => _selectDate(context, false)),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF344054)),
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
                  date != null ? DateFormat('MM/dd/yyyy').format(date) : 'Select Date',
                  fontSize: 14,
                  color: date != null ? AppColors.textPrimary : const Color(0xFF667085),
                ),
                const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF667085)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVenueSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Show Venue or City'),
        const SizedBox(height: 12),
        TextField(
          controller: _venueController,
          readOnly: true,
          onTap: _showVenueSelectionSheet,
          decoration: InputDecoration(
            hintText: 'Select Show Venue or City',
            hintStyle: const TextStyle(color: Color(0xFF667085), fontSize: 14),
            prefixIcon: null,
            suffixIcon: GestureDetector(
              onTap: _showVenueSelectionSheet,
              child: const Icon(Icons.search, size: 20, color: Color(0xFF667085)),
            ),
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
    final List<String> allVenues = profileController.allHorseShows;
    final RxList<String> filteredVenues = RxList<String>(allVenues);
    
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
                hintText: 'Search venues...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) {
                filteredVenues.assignAll(allVenues.where((v) => v.toLowerCase().contains(val.toLowerCase())).toList());
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() => ListView.builder(
                itemCount: filteredVenues.length,
                itemBuilder: (context, index) {
                  final venue = filteredVenues[index];
                  return Obx(() {
                    final isSelected = _addedVenues.contains(venue);
                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (selected) {
                        if (selected == true) _addedVenues.add(venue);
                        else _addedVenues.remove(venue);
                      },
                      title: CommonText(venue),
                      activeColor: const Color(0xFF030D3B),
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
                  backgroundColor: const Color(0xFF030D3B),
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

  Widget _buildSelectionWrap(List<String> items, RxList<String> selectionList) {
    return Obx(() => Wrap(
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
              color: isSelected ? const Color(0xFF030D3B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? const Color(0xFF030D3B) : const Color(0xFFD0D5DD), 
                width: 1
              ),
            ),
            child: CommonText(
              t,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF344054),
            ),
          ),
        );
      }).toList(),
    ));
  }

  Widget _buildCapacitySection() {
    return Row(
      children: [
        Expanded(child: _buildCounter('Max Horses', _maxHorses)),
        const SizedBox(width: 16),
        Expanded(child: _buildCounter('Max Days', _maxDays)),
      ],
    );
  }

  Widget _buildCounter(String label, RxInt count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF344054)),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD0D5DD)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () { if (count.value > 1) count.value--; }, 
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.remove, size: 16, color: Color(0xFF667085)),
                )
              ),
              Obx(() => CommonText('${count.value}', fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF101828))),
              IconButton(
                onPressed: () => count.value++, 
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.add, size: 16, color: Color(0xFF667085)),
                )
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return TextField(
      controller: _notesController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Any specific preference, requirements, or information trainers should know...',
        hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 14),
        fillColor: const Color(0xFFF9FAFB),
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEAECF0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEAECF0))),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFEAECF0)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const CommonText('Cancel', fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
              child: Obx(() => ElevatedButton(
                onPressed: _isSubmitting.value ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF030D3B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  Future<void> _selectUnavailabilityDate(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      if (isStart) setState(() => _unStart = picked);
      else setState(() => _unEnd = picked);
    }
  }

  Widget _buildDropdownField(String hint, RxString selectedValue, List<String> options) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: DropdownButtonHideUnderline(
        child: Obx(() => DropdownButton<String>(
          value: selectedValue.value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: CommonText(value, fontSize: 14),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) selectedValue.value = val;
          },
        )),
      ),
    );
  }

  Widget _buildCapacityCounter() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEAECF0)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: () { if (_maxHorses.value > 1) _maxHorses.value--; }, icon: const Icon(Icons.remove, size: 20)),
          Obx(() => CommonText('${_maxHorses.value}', fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(onPressed: () => _maxHorses.value++, icon: const Icon(Icons.add, size: 20)),
        ],
      ),
    );
  }
}
