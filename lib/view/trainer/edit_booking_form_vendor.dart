import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/booking_controller.dart';
import 'package:catch_ride/models/booking_model.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:intl/intl.dart';

class EditBookingFormVendor extends StatefulWidget {
  final BookingModel booking;

  const EditBookingFormVendor({super.key, required this.booking});

  @override
  State<EditBookingFormVendor> createState() => _EditBookingFormVendorState();
}

class _EditBookingFormVendorState extends State<EditBookingFormVendor> {
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;
  bool _isLoadingLocations = true;

  // Availability data
  List<Map<String, dynamic>> _availabilityList = [];

  // Form fields
  String? _selectedLocation;
  String? _selectedNumHorses;
  DateTime? _startDate;
  DateTime? _endDate;

  // Derived lists
  List<String> _availableLocations = [];

  @override
  void initState() {
    super.initState();
    _notesController.text = widget.booking.notes ?? '';
    _selectedLocation = widget.booking.location;
    _selectedNumHorses = widget.booking.numberOfHorses?.toString() ?? '1';

    // Pre-fill dates
    try {
      final sRaw = widget.booking.startDate;
      final eRaw = widget.booking.endDate;
      _startDate = sRaw != null ? DateTime.parse(sRaw) : DateTime.parse(widget.booking.date);
      _endDate = eRaw != null ? DateTime.parse(eRaw) : DateTime.parse(widget.booking.date);
    } catch (_) {
      _startDate = DateTime.now();
      _endDate = DateTime.now();
    }

    _fetchVendorAvailability();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchVendorAvailability() async {
    final vendorId = widget.booking.vendorId;
    if (vendorId == null) {
      setState(() => _isLoadingLocations = false);
      return;
    }

    try {
      final api = Get.find<ApiService>();
      final responses = await Future.wait([
        api.getRequest('/availability/vendors/$vendorId'),
        api.getRequest('/trips/vendor/$vendorId'),
      ]);

      final List<Map<String, dynamic>> combined = [];
      if (responses[0].statusCode == 200 && responses[0].body['success'] == true) {
        final List raw = responses[0].body['data'] ?? [];
        for (var item in raw) {
          if (item is Map) combined.add(Map<String, dynamic>.from(item));
        }
      }
      if (responses[1].statusCode == 200 && responses[1].body['success'] == true) {
        final List raw = responses[1].body['data'] ?? [];
        for (var item in raw) {
          if (item is Map) {
            final m = Map<String, dynamic>.from(item);
            m['isTrip'] = true;
            combined.add(m);
          }
        }
      }

      _availabilityList = combined;
      _availableLocations = _buildLocationList();

      // Validate pre-selected location
      if (_selectedLocation != null && !_availableLocations.contains(_selectedLocation)) {
        _availableLocations.add(_selectedLocation!);
      }
    } catch (e) {
      debugPrint('Error fetching vendor availability: $e');
    } finally {
      if (mounted) setState(() => _isLoadingLocations = false);
    }
  }

  List<String> _buildLocationList() {
    final List<String> locs = [];
    for (final avail in _availabilityList) {
      void addIfNotEmpty(dynamic v) {
        if (v != null && v.toString().isNotEmpty) locs.add(v.toString());
      }

      addIfNotEmpty(avail['origin']);
      addIfNotEmpty(avail['destination']);

      if (avail['intermediateStops'] is List) {
        for (final stop in avail['intermediateStops']) {
          if (stop is Map && stop['address'] != null) addIfNotEmpty(stop['address']);
          else if (stop != null && stop is! Map) addIfNotEmpty(stop);
        }
      }
      if (avail['showVenues'] is List) {
        for (final venue in avail['showVenues']) {
          if (venue is Map) addIfNotEmpty(venue['name'] ?? venue['address']);
          else if (venue != null && venue is! Map) addIfNotEmpty(venue);
        }
      } else if (avail['showVenues'] != null) {
        addIfNotEmpty(avail['showVenues']);
      }
      if (avail['location'] is Map) {
        final city = avail['location']['city']?.toString() ?? '';
        final state = avail['location']['state']?.toString() ?? '';
        if (city.isNotEmpty && state.isNotEmpty) locs.add('$city, $state');
      }
    }
    final unique = locs.where((l) => l.isNotEmpty).toSet().toList();
    return unique.isEmpty ? ['Other'] : unique;
  }

  List<String> _getHorseOptions() {
    final loc = _selectedLocation;
    if (loc == null || loc.contains('(Home)') || loc == 'Other') {
      return List.generate(10, (i) => '${i + 1}');
    }
    for (final avail in _availabilityList) {
      if (_locationMatch(avail, loc)) {
        final max = int.tryParse(avail['maxBookings']?.toString() ?? avail['maxHorses']?.toString() ?? '1') ?? 1;
        final count = max < 1 ? 1 : (max > 20 ? 20 : max);
        return List.generate(count, (i) => '${i + 1}');
      }
    }
    return List.generate(5, (i) => '${i + 1}');
  }

  bool _locationMatch(Map avail, String loc) {
    if (avail['origin'] == loc || avail['destination'] == loc) return true;
    if (avail['intermediateStops'] is List) {
      for (final stop in avail['intermediateStops']) {
        if (stop is Map && stop['address'] == loc) return true;
        if (stop.toString() == loc) return true;
      }
    }
    if (avail['showVenues'] is List) {
      for (final venue in avail['showVenues']) {
        if (venue is Map && (venue['name'] == loc || venue['address'] == loc)) return true;
        if (venue.toString() == loc) return true;
      }
    }
    if (avail['showVenues'].toString() == loc) return true;
    if (avail['location'] is Map) {
      final city = avail['location']['city']?.toString() ?? '';
      final state = avail['location']['state']?.toString() ?? '';
      if ('$city, $state' == loc) return true;
    }
    return false;
  }

  // Get allowed date range for current location (mirrors SendBookingRequestController.getAllowedDatesForLocation)
  Map<String, DateTime?> _getAllowedDates() {
    final loc = _selectedLocation;
    if (loc == null || loc.contains('(Home)') || loc == 'Other') {
      return {'start': null, 'end': null};
    }
    for (final avail in _availabilityList) {
      if (_locationMatch(avail, loc)) {
        final sStr = avail['startDate'] ?? avail['specificDate'];
        final eStr = avail['endDate'] ?? avail['specificDate'];
        if (sStr != null && eStr != null) {
          return {'start': DateTime.tryParse(sStr), 'end': DateTime.tryParse(eStr)};
        }
      }
    }
    return {'start': null, 'end': null};
  }

  bool _validate() {
    if (_startDate == null || _endDate == null) {
      Get.snackbar('Validation Error', 'Please select start and end dates',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          barBlur: 0,
          margin: const EdgeInsets.all(16));
      return false;
    }
    if (_selectedNumHorses == null) {
      Get.snackbar('Validation Error', 'Please select number of horses',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          barBlur: 0,
          margin: const EdgeInsets.all(16));
      return false;
    }
    if (_selectedLocation == null) {
      Get.snackbar('Validation Error', 'Please select a location',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          barBlur: 0,
          margin: const EdgeInsets.all(16));
      return false;
    }
    return true;
  }

  Future<void> _updateBooking() async {
    if (!_validate()) return;

    setState(() => _isLoading = true);
    try {
      final api = Get.find<ApiService>();
      final payload = {
        'startDate': DateFormat('yyyy-MM-dd').format(_startDate!),
        'endDate': DateFormat('yyyy-MM-dd').format(_endDate!),
        'date': DateFormat('yyyy-MM-dd').format(_startDate!),
        'location': _selectedLocation,
        'numberOfHorses': _selectedNumHorses,
        'notes': _notesController.text.trim(),
      };

      final response = await api.putRequest(
        '/bookings/${widget.booking.id}',
        payload,
      );

      if (response.statusCode == 200) {
        Get.find<BookingController>().fetchBookings(type: 'sent');
        Get.back();
        Get.snackbar('Success', 'Booking updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF17B26A),
            colorText: Colors.white,
            barBlur: 0,
            margin: const EdgeInsets.all(16));
      } else {
        final msg = response.body?['message'] ?? 'Failed to update booking';
        Get.snackbar('Error', msg,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            barBlur: 0,
            margin: const EdgeInsets.all(16));
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          barBlur: 0,
          margin: const EdgeInsets.all(16));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Reusable dropdown widget
  Widget _buildDropdownField(String label, String hint, List<String> options, String? selected, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE4E7EC)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: options.contains(selected) ? selected : null,
              hint: CommonText(hint, color: const Color(0xFF98A2B3), fontSize: 14),
              items: options.map((o) => DropdownMenuItem(value: o, child: CommonText(o, fontSize: 14))).toList(),
              onChanged: onChanged,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeField() {
    final allowedDates = _getAllowedDates();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime first = allowedDates['start'] ?? today;
    DateTime last = allowedDates['end'] ?? today.add(const Duration(days: 365));
    if (first.isBefore(today)) first = today;

    String displayDate = 'Select Date Range';
    if (_startDate != null && _endDate != null) {
      displayDate =
          '${DateFormat('MMMM d, yyyy').format(_startDate!)} - ${DateFormat('MMMM d, yyyy').format(_endDate!)}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText('Select Date Range', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            DateTimeRange? initialRange;
            if (_startDate != null && _endDate != null) {
              if (!_startDate!.isBefore(first) && !_endDate!.isAfter(last)) {
                initialRange = DateTimeRange(start: _startDate!, end: _endDate!);
              }
            }

            final picked = await showDateRangePicker(
              context: context,
              firstDate: first,
              lastDate: last.isBefore(first) ? first.add(const Duration(days: 1)) : last,
              initialDateRange: initialRange,
              builder: (context, child) => Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: AppColors.textPrimary,
                  ),
                ),
                child: child!,
              ),
            );

            if (picked != null) {
              setState(() {
                _startDate = picked.start;
                _endDate = picked.end;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE4E7EC)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonText(
                  displayDate,
                  fontSize: 14,
                  color: (_startDate != null && _endDate != null) ? AppColors.textPrimary : const Color(0xFF98A2B3),
                ),
                const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF98A2B3)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final horseOptions = _getHorseOptions();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const CommonText('Update Vendor Booking', fontSize: AppTextSizes.size20, fontWeight: FontWeight.bold),
      ),
      body: _isLoadingLocations
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE4E7EC)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.business_center_outlined, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonText(
                                'Editing ${widget.booking.type.capitalizeFirst ?? 'Service'} Booking',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              if (widget.booking.vendorName != null)
                                CommonText(
                                  'Provider: ${widget.booking.vendorName}',
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Date Range
                  _buildDateRangeField(),
                  const SizedBox(height: 20),

                  // Number of Horses
                  _buildDropdownField(
                    'Number Of Horses',
                    'Select',
                    horseOptions,
                    horseOptions.contains(_selectedNumHorses) ? _selectedNumHorses : null,
                    (val) => setState(() => _selectedNumHorses = val),
                  ),
                  const SizedBox(height: 20),

                  // Location
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CommonText('Location', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE4E7EC)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _availableLocations.contains(_selectedLocation) ? _selectedLocation : null,
                            hint: const CommonText('Select Location', color: Color(0xFF98A2B3), fontSize: 14),
                            items: _availableLocations.map((o) => DropdownMenuItem(value: o, child: CommonText(o, fontSize: 14))).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedLocation = val;
                                // Reset dates and horses when location changes
                                _startDate = null;
                                _endDate = null;
                                _selectedNumHorses = null;
                              });
                            },
                            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Notes
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CommonText('Notes to Vendor', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Add a note for the service provider...',
                          hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 14),
                          contentPadding: const EdgeInsets.all(16),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  CommonButton(
                    text: 'Save Changes',
                    isLoading: _isLoading,
                    onPressed: _updateBooking,
                    backgroundColor: AppColors.primary,
                    height: 56,
                    borderRadius: 16,
                  ),
                ],
              ),
            ),
    );
  }
}
