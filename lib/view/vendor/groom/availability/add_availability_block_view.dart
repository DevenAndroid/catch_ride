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
    _categoryName = _categoryIndex == 0 ? 'Grooming' : 'Braiding';

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
          if (s == 'Grooming' || s == 'Braiding') continue;
          
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

  // Text controllers
  final _notesController = TextEditingController();
  final _venueController = TextEditingController();

  // Lists
  final RxList<String> _addedVenues = <String>[].obs;
  final RxInt _maxHorses = 6.obs;
  final RxInt _maxDays = 12.obs;

  List<String> get _availableWorkTypes {
    if (_categoryName == 'Braiding') {
      return ['Show week support', 'Daily barn help', 'Fill In/ daily show support', 'Seasonal / Temporary'];
    }
    return ['Daily barn help', 'Show week support', 'Seasonal / Temporary'];
  }

  List<String> get _availableServiceTypes {
    if (_categoryName == 'Braiding') {
      return ['Hunter Braiding Mane', 'Jumper Braiding', 'Mane Pulling', 'Tail Braiding'];
    }
    return ['Basic Grooming', 'Full Grooming', 'Body Clipping', 'Bathing', 'Braiding'];
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
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEAECF0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonText(_editingBlock != null ? 'Edit Block' : 'Block 1', fontSize: 16, fontWeight: FontWeight.bold),
                    IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close, color: Colors.grey, size: 20)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateSection(),
                    const SizedBox(height: 24),
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
                    const SizedBox(height: 24),
                    _buildSectionHeader('Notes For Trainers (optional)'),
                    const SizedBox(height: 12),
                    _buildNotesField(),
                  ],
                ),
              ),
            ],
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
        CommonText(label, fontSize: 14, fontWeight: FontWeight.bold),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFEAECF0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonText(
                  date != null ? DateFormat('MM/dd/yyyy').format(date) : 'Select Date',
                  fontSize: 14,
                  color: date != null ? AppColors.textPrimary : Colors.grey,
                ),
                const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
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
        InkWell(
          onTap: _showVenueSelectionSheet,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFEAECF0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => CommonText(
                  _addedVenues.isEmpty ? 'Enter Show Venue or City' : '${_addedVenues.length} Venues Selected',
                  fontSize: 14,
                  color: _addedVenues.isEmpty ? Colors.grey : AppColors.textPrimary,
                )),
                const Icon(Icons.search, size: 20, color: Colors.grey),
              ],
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
                decoration: BoxDecoration(color: const Color(0xFFF2F4F7), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CommonText(v, fontSize: 13, color: AppColors.textPrimary),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _addedVenues.remove(v),
                      child: const Icon(Icons.close, size: 14, color: Colors.grey),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? const Color(0xFF030D3B) : const Color(0xFFEAECF0), width: isSelected ? 1.5 : 1),
            ),
            child: CommonText(
              t,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? const Color(0xFF030D3B) : AppColors.textPrimary,
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
        CommonText(label, fontSize: 12, color: Colors.grey),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFEAECF0)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(onPressed: () { if (count.value > 1) count.value--; }, icon: const Icon(Icons.remove, size: 20)),
              Obx(() => CommonText('${count.value}', fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => count.value++, icon: const Icon(Icons.add, size: 20)),
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
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEAECF0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEAECF0))),
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
}
