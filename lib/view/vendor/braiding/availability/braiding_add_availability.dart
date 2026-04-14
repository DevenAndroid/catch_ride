import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/vendor_availability_controller.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:catch_ride/models/vendor_availability_model.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BraidingAddAvailabilityView extends StatefulWidget {
  const BraidingAddAvailabilityView({super.key});

  @override
  State<BraidingAddAvailabilityView> createState() => _BraidingAddAvailabilityViewState();
}

class _BraidingAddAvailabilityViewState extends State<BraidingAddAvailabilityView> {
  final controller = Get.put(VendorAvailabilityController());
  final profileController = Get.put(ProfileController());

  final RxBool _isSubmitting = false.obs;
  VendorAvailabilityModel? _editingBlock;

  // Form State
  DateTime? _startDate;
  DateTime? _endDate;
  final _notesController = TextEditingController();
  final _venueSearchController = TextEditingController();
  final RxList<String> _selectedVenues = <String>[].obs;
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
    _selectedVenues.assignAll(List<String>.from(_editingBlock!.showVenues));

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

    if (_selectedVenues.isEmpty) {
      Get.snackbar('Error', 'Please add at least one venue or city', backgroundColor: Colors.red, colorText: Colors.white);
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
        'showVenues': _selectedVenues.toList(),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const CommonText('Add Availability Block', fontSize: 18, fontWeight: FontWeight.bold),
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
                  CommonText(_editingBlock != null ? 'Edit Block' : 'Block 1', fontSize: 16, fontWeight: FontWeight.bold),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.close, color: Color(0xFF344054), size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDateRow(),
              const SizedBox(height: 24),
              _buildVenueSection(),
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
    return CommonText(title, fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary);
  }

  List<String> get _availableWorkTypes => ['Show week support', 'Daily barn help', 'Fill In/ daily show support', 'Seasonal / Temporary'];
  List<String> get _availableServiceTypes => ['Hunter Braiding Mane', 'Jumper Braiding'];

  final RxList<String> _selectedWorkTypes = <String>[].obs;
  final RxList<String> _selectedServiceTypes = <String>[].obs;

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
              color: isSelected ? AppColors.primaryDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primaryDark : const Color(0xFFD0D5DD), 
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

  Widget _buildDateRow() {
    return Row(
      children: [
        Expanded(
          child: _buildDatePickerField('Start Date', _startDate, () => _selectDate(context, true)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDatePickerField('End Date', _endDate, () => _selectDate(context, false)),
        ),
      ],
    );
  }

  Widget _buildDatePickerField(String label, DateTime? date, VoidCallback onTap) {
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
                  date != null ? DateFormat('MM/dd/yyyy').format(date) : 'Select date',
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

  Widget _buildVenueSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText('Show Venue or City', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF344054)),
        const SizedBox(height: 8),
        TextField(
          controller: _venueSearchController,
          readOnly: true,
          onTap: _showVenueSelectionSheet,
          decoration: InputDecoration(
            hintText: 'Enter Show Venue or City',
            hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _selectedVenues.map((v) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: CommonText(v, fontSize: 13, color: const Color(0xFF344054))),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _selectedVenues.remove(v),
                  child: const Icon(Icons.close, size: 14, color: Color(0xFF667085)),
                ),
              ],
            ),
          )).toList(),
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
        height: Get.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
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
                    final isSelected = _selectedVenues.contains(venueName);
                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (selected) {
                        if (selected == true) {
                          if (!_selectedVenues.contains(venueName)) _selectedVenues.add(venueName);
                        } else {
                          _selectedVenues.remove(venueName);
                        }
                      },
                      title: CommonText(venueName),
                      subtitle: city.isNotEmpty ? CommonText(city, fontSize: 12, color: Colors.grey) : null,
                      activeColor: AppColors.primaryDark,
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
                  backgroundColor: AppColors.primaryDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _buildCapacitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText('Capacity (optional)', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF344054)),
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
        CommonText(label, fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF344054)),
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
                onTap: () { if (count.value > 0) count.value--; },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.remove, size: 16, color: Color(0xFF667085)),
                ),
              ),
              Obx(() => CommonText('${count.value}', fontSize: 18, color: const Color(0xFF344054))),
              GestureDetector(
                onTap: () => count.value++,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, size: 16, color: Color(0xFF667085)),
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
        const CommonText('Notes For Trainers (optional)', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF344054)),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Any specific preference, requirements, or information trainers should know...',
            hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 14),
            fillColor: const Color(0xFFF9FAFB),
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
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
