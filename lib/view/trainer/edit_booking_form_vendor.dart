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

bool _isShippingServiceType(String? serviceType) {
  final s = serviceType?.toLowerCase() ?? '';
  return s.contains('ship') || s.contains('transport');
}

class EditBookingFormVendor extends StatefulWidget {
  final BookingModel booking;

  /// Which list to refresh after a successful update (`sent` = trainer, `received` = service provider).
  final String refreshBookingsType;

  const EditBookingFormVendor({
    super.key,
    required this.booking,
    this.refreshBookingsType = 'sent',
  });

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

  /// Multi-service / bundle (same shape as [SendBookingRequestController.sendRequest] lines).
  List<Map<String, dynamic>> _bundleLines = [];
  int? _editingLineIndex;
  DateTime? _draftStart;
  DateTime? _draftEnd;
  String? _draftHorses;
  String? _draftLocation;
  final TextEditingController _lineNotesCtrl = TextEditingController();
  final TextEditingController _lineOriginCtrl = TextEditingController();
  final TextEditingController _lineDestCtrl = TextEditingController();

  bool get _isMultiBundle => widget.booking.vendorBundleLines.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (_isMultiBundle) {
      _hydrateBundleLinesFromBooking();
    } else {
      _notesController.text = widget.booking.notes ?? '';
      _selectedLocation = widget.booking.location;
      _selectedNumHorses = widget.booking.numberOfHorses?.toString() ?? '1';

      // Pre-fill dates (booking model may use display strings; fall back to today)
      try {
        final sRaw = widget.booking.startDate;
        final eRaw = widget.booking.endDate;
        _startDate = sRaw != null ? DateTime.parse(sRaw) : DateTime.parse(widget.booking.date);
        _endDate = eRaw != null ? DateTime.parse(eRaw) : DateTime.parse(widget.booking.date);
      } catch (_) {
        _startDate = DateTime.now();
        _endDate = DateTime.now();
      }
    }

    _fetchVendorAvailability();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _lineNotesCtrl.dispose();
    _lineOriginCtrl.dispose();
    _lineDestCtrl.dispose();
    super.dispose();
  }

  double _parseMoney(dynamic v) {
    if (v is num) return v.toDouble();
    if (v == null) return 0;
    return double.tryParse(v.toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
  }

  List<String> _idsFromLineList(dynamic v) {
    if (v is! List) return [];
    final out = <String>[];
    for (final e in v) {
      if (e is Map) {
        final id = e['id'] ?? e['_id'] ?? e['name'];
        if (id != null) out.add(id.toString());
      } else {
        final s = e.toString();
        if (s.isNotEmpty) out.add(s);
      }
    }
    return out;
  }

  DateTime _parseLineDate(dynamic v, DateTime fallback) {
    if (v == null) return fallback;
    final parsed = DateTime.tryParse(v.toString());
    if (parsed != null) {
      return DateTime(parsed.year, parsed.month, parsed.day);
    }
    return fallback;
  }

  void _hydrateBundleLinesFromBooking() {
    _bundleLines = [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (final raw in widget.booking.vendorBundleLines) {
      final m = Map<String, dynamic>.from(raw);
      final sd = _parseLineDate(m['startDate'], today);
      final ed = _parseLineDate(m['endDate'], sd);
      final horses = (m['numberOfHorses'] ?? '1').toString();
      final loc = m['location']?.toString() ?? widget.booking.location ?? '';
      _bundleLines.add({
        'serviceType': (m['serviceType'] ?? m['type'] ?? '').toString(),
        'rateType': m['rateType']?.toString(),
        'startDate': sd,
        'endDate': ed,
        'horses': horses,
        'location': loc,
        'origin': m['origin']?.toString(),
        'destination': m['destination']?.toString(),
        'notes': m['notes']?.toString() ?? '',
        'additionalIds': _idsFromLineList(m['additionalServices']),
        'coreIds': _idsFromLineList(m['coreServices']),
        'basePrice': _parseMoney(m['price']),
        'totalPrice': _parseMoney(m['price']),
      });
    }
    _notesController.text = widget.booking.notes ?? '';
  }

  void _mergeBundleLocationsIntoOptions() {
    for (final line in _bundleLines) {
      for (final key in ['location', 'origin', 'destination']) {
        final v = line[key]?.toString();
        if (v != null && v.isNotEmpty && !_availableLocations.contains(v)) {
          _availableLocations.add(v);
        }
      }
    }
  }

  void _beginEditLine(int index) {
    final line = _bundleLines[index];
    setState(() {
      _editingLineIndex = index;
      _draftStart = line['startDate'] as DateTime?;
      _draftEnd = line['endDate'] as DateTime?;
      _draftHorses = line['horses']?.toString();
      _draftLocation = line['location']?.toString();
      _lineNotesCtrl.text = line['notes']?.toString() ?? '';
      _lineOriginCtrl.text = line['origin']?.toString() ?? '';
      _lineDestCtrl.text = line['destination']?.toString() ?? '';
    });
  }

  void _cancelEditLine() {
    setState(() => _editingLineIndex = null);
  }

  void _saveLineDraft() {
    final idx = _editingLineIndex;
    if (idx == null) return;
    final line = Map<String, dynamic>.from(_bundleLines[idx]);
    final st = line['serviceType']?.toString() ?? '';

    if (_draftStart == null || _draftEnd == null) {
      Get.snackbar('Validation Error', 'Please select start and end dates',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          barBlur: 0,
          margin: const EdgeInsets.all(16));
      return;
    }
    if (_draftHorses == null) {
      Get.snackbar('Validation Error', 'Please select number of horses',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          barBlur: 0,
          margin: const EdgeInsets.all(16));
      return;
    }
    if (_isShippingServiceType(st)) {
      if (_lineOriginCtrl.text.trim().isEmpty || _lineDestCtrl.text.trim().isEmpty) {
        Get.snackbar('Validation Error', 'Please enter origin and destination',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            barBlur: 0,
            margin: const EdgeInsets.all(16));
        return;
      }
      line['origin'] = _lineOriginCtrl.text.trim();
      line['destination'] = _lineDestCtrl.text.trim();
      line['location'] = '${line['origin']} to ${line['destination']}';
    } else {
      if (_draftLocation == null || _draftLocation!.isEmpty) {
        Get.snackbar('Validation Error', 'Please select a location',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            barBlur: 0,
            margin: const EdgeInsets.all(16));
        return;
      }
      line['location'] = _draftLocation;
    }

    line['startDate'] = _draftStart;
    line['endDate'] = _draftEnd;
    line['horses'] = _draftHorses;
    line['notes'] = _lineNotesCtrl.text.trim();
    setState(() {
      _bundleLines[idx] = line;
      _editingLineIndex = null;
    });
  }

  bool _validateBundleComplete() {
    for (var i = 0; i < _bundleLines.length; i++) {
      final line = _bundleLines[i];
      if (line['startDate'] == null || line['endDate'] == null) {
        Get.snackbar('Validation Error', 'Please set dates for every service (line ${i + 1})',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            barBlur: 0,
            margin: const EdgeInsets.all(16));
        return false;
      }
      if (line['horses'] == null) {
        Get.snackbar('Validation Error', 'Please set number of horses for every service',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            barBlur: 0,
            margin: const EdgeInsets.all(16));
        return false;
      }
      final st = line['serviceType']?.toString() ?? '';
      if (_isShippingServiceType(st)) {
        final o = line['origin']?.toString().trim() ?? '';
        final d = line['destination']?.toString().trim() ?? '';
        if (o.isEmpty || d.isEmpty) {
          Get.snackbar('Validation Error', 'Please set origin and destination for shipping (line ${i + 1})',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
              barBlur: 0,
              margin: const EdgeInsets.all(16));
          return false;
        }
      } else {
        if ((line['location']?.toString() ?? '').isEmpty) {
          Get.snackbar('Validation Error', 'Please set location for every service (line ${i + 1})',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
              barBlur: 0,
              margin: const EdgeInsets.all(16));
          return false;
        }
      }
    }
    return true;
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
        final body = responses[0].body;
        final rawData = body['data'];
        if (rawData is List) {
          for (var item in rawData) {
            if (item is Map) combined.add(Map<String, dynamic>.from(item));
          }
        } else if (rawData is Map) {
          final inner = rawData['availability'];
          if (inner is List) {
            for (var item in inner) {
              if (item is Map) combined.add(Map<String, dynamic>.from(item));
            }
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
      if (_bundleLines.isNotEmpty) {
        _mergeBundleLocationsIntoOptions();
      }
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

  List<String> _getHorseOptionsForLocation(String? loc) {
    if (loc == null || loc.contains('(Home)') || loc == 'Other') {
      return List.generate(10, (i) => '${i + 1}');
    }
    for (final avail in _availabilityList) {
      if (avail['isTrip'] == true) continue;
      if (_locationMatch(avail, loc)) {
        final max = int.tryParse(avail['maxBookings']?.toString() ?? avail['maxHorses']?.toString() ?? '1') ?? 1;
        final booked = int.tryParse(avail['currentBookings']?.toString() ?? '0') ?? 0;
        final remaining = (max - booked).clamp(0, max);
        if (remaining <= 0) {
          return <String>[];
        }
        final count = remaining > 20 ? 20 : remaining;
        return List.generate(count, (i) => '${i + 1}');
      }
    }
    return List.generate(5, (i) => '${i + 1}');
  }

  List<String> _getHorseOptions() => _getHorseOptionsForLocation(_selectedLocation);

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
  Map<String, DateTime?> _getAllowedDatesForLocation(String? loc) {
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

  Map<String, DateTime?> _getAllowedDates() => _getAllowedDatesForLocation(_selectedLocation);

  String? _draftLocationForDatePicker() {
    final idx = _editingLineIndex;
    if (idx == null) return _draftLocation;
    final st = _bundleLines[idx]['serviceType']?.toString() ?? '';
    if (_isShippingServiceType(st)) {
      final o = _lineOriginCtrl.text.trim();
      return o.isEmpty ? null : o;
    }
    return _draftLocation;
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
    if (_editingLineIndex != null) {
      Get.snackbar('Please finish editing', 'Save or cancel the service line you are editing first.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          barBlur: 0,
          margin: const EdgeInsets.all(16));
      return;
    }

    if (_isMultiBundle) {
      if (!_validateBundleComplete()) return;
    } else {
      if (!_validate()) return;
    }

    setState(() => _isLoading = true);
    try {
      final api = Get.find<ApiService>();
      final Map<String, dynamic> payload;

      if (_isMultiBundle) {
        final serviceLines = <Map<String, dynamic>>[];
        for (final b in _bundleLines) {
          final start = b['startDate'] as DateTime;
          final end = b['endDate'] as DateTime;
          serviceLines.add({
            'serviceType': b['serviceType'],
            'type': b['serviceType'],
            'startDate': DateFormat('yyyy-MM-dd').format(start),
            'endDate': DateFormat('yyyy-MM-dd').format(end),
            'rateType': b['rateType'],
            'numberOfHorses': b['horses'],
            'location': b['location'],
            'origin': b['origin'],
            'destination': b['destination'],
            'notes': b['notes'],
            'additionalServices': b['additionalIds'],
            'coreServices': b['coreIds'],
            'price': b['totalPrice'],
          });
        }
        final first = _bundleLines.first;
        final fs = first['startDate'] as DateTime;
        final fe = first['endDate'] as DateTime;
        payload = {
          'vendorBundleLines': serviceLines,
          'startDate': DateFormat('yyyy-MM-dd').format(fs),
          'endDate': DateFormat('yyyy-MM-dd').format(fe),
          'date': DateFormat('yyyy-MM-dd').format(fs),
          'location': first['location'],
          'numberOfHorses': first['horses'],
          'notes': _notesController.text.trim(),
        };
      } else {
        payload = {
          'startDate': DateFormat('yyyy-MM-dd').format(_startDate!),
          'endDate': DateFormat('yyyy-MM-dd').format(_endDate!),
          'date': DateFormat('yyyy-MM-dd').format(_startDate!),
          'location': _selectedLocation,
          'numberOfHorses': _selectedNumHorses,
          'notes': _notesController.text.trim(),
        };
      }

      final response = await api.putRequest(
        '/bookings/${widget.booking.id}',
        payload,
      );

      if (response.statusCode == 200) {
        final bc = Get.find<BookingController>();
        await bc.fetchBookings(type: widget.refreshBookingsType);
        if (widget.refreshBookingsType == 'received') {
          await bc.refreshPendingBookingCounts();
        }
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
                  datePickerTheme: DatePickerThemeData(
                    rangeSelectionBackgroundColor: AppColors.primary.withOpacity(0.15),
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

  Widget _buildDraftDateRangeField() {
    final allowedDates = _getAllowedDatesForLocation(_draftLocationForDatePicker());
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime first = allowedDates['start'] ?? today;
    DateTime last = allowedDates['end'] ?? today.add(const Duration(days: 365));
    if (first.isBefore(today)) first = today;

    String displayDate = 'Select Date Range';
    if (_draftStart != null && _draftEnd != null) {
      displayDate =
          '${DateFormat('MMMM d, yyyy').format(_draftStart!)} - ${DateFormat('MMMM d, yyyy').format(_draftEnd!)}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText('Select Date Range', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            DateTimeRange? initialRange;
            if (_draftStart != null && _draftEnd != null) {
              if (!_draftStart!.isBefore(first) && !_draftEnd!.isAfter(last)) {
                initialRange = DateTimeRange(start: _draftStart!, end: _draftEnd!);
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
                  datePickerTheme: DatePickerThemeData(
                    rangeSelectionBackgroundColor: AppColors.primary.withOpacity(0.15),
                  ),
                ),
                child: child!,
              ),
            );

            if (picked != null) {
              setState(() {
                _draftStart = picked.start;
                _draftEnd = picked.end;
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
                  color: (_draftStart != null && _draftEnd != null) ? AppColors.textPrimary : const Color(0xFF98A2B3),
                ),
                const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF98A2B3)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.business_center_outlined, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  _isMultiBundle
                      ? 'Multi-service booking'
                      : 'Editing ${widget.booking.type.capitalizeFirst ?? 'Service'} Booking',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                if (_isMultiBundle)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: CommonText(
                      'Update dates, locations, and horses per service — same structure as when you sent the request.',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                if (widget.booking.vendorName != null) ...[
                  const SizedBox(height: 4),
                  CommonText(
                    'Provider: ${widget.booking.vendorName}',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBundleLineSummaryCard(int index, NumberFormat currencyFormat) {
    final booking = _bundleLines[index];
    final startDt = booking['startDate'] as DateTime;
    final endDt = booking['endDate'] as DateTime;
    final duration = endDt.difference(startDt).inDays + 1;
    final sameCalendarDay =
        startDt.year == endDt.year && startDt.month == endDt.month && startDt.day == endDt.day;
    final dateLabel = sameCalendarDay
        ? DateFormat('MMMM d, yyyy').format(startDt)
        : '${DateFormat('MMMM d').format(startDt)} - ${DateFormat('MMMM d, yyyy').format(endDt)}';
    final st = booking['serviceType']?.toString() ?? 'Service';
    final loc = booking['location']?.toString() ?? '';
    final price = _parseMoney(booking['totalPrice']);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CommonText(
                  '$st ($duration ${duration > 1 ? 'Days' : 'Day'})',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CommonText(currencyFormat.format(price), fontSize: 14, fontWeight: FontWeight.bold),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _beginEditLine(index),
                    child: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(child: CommonText(loc.isEmpty ? '—' : loc, fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              CommonText(dateLabel, fontSize: 12, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 4),
          CommonText(
            '${booking['horses'] ?? '1'} horse(s)',
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildLineEditorCard() {
    final idx = _editingLineIndex;
    if (idx == null) return const SizedBox.shrink();
    final line = _bundleLines[idx];
    final st = line['serviceType']?.toString() ?? '';
    final ship = _isShippingServiceType(st);
    final horseOpts = _getHorseOptionsForLocation(
      ship
          ? (_lineOriginCtrl.text.trim().isEmpty ? null : _lineOriginCtrl.text.trim())
          : _draftLocation,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            'Editing: $st',
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          _buildDraftDateRangeField(),
          const SizedBox(height: 16),
          _buildDropdownField(
            'Number Of Horses',
            'Select',
            horseOpts,
            horseOpts.contains(_draftHorses) ? _draftHorses : null,
            (val) => setState(() => _draftHorses = val),
          ),
          const SizedBox(height: 16),
          if (ship) ...[
            const CommonText('Origin', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            const SizedBox(height: 8),
            TextFormField(
              controller: _lineOriginCtrl,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 14),
              decoration: _lineFieldDecoration('Origin address'),
            ),
            const SizedBox(height: 12),
            const CommonText('Destination', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            const SizedBox(height: 8),
            TextFormField(
              controller: _lineDestCtrl,
              style: const TextStyle(fontSize: 14),
              decoration: _lineFieldDecoration('Destination address'),
            ),
          ] else ...[
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
                  value: _availableLocations.contains(_draftLocation) ? _draftLocation : null,
                  hint: const CommonText('Select Location', color: Color(0xFF98A2B3), fontSize: 14),
                  items: _availableLocations.map((o) => DropdownMenuItem(value: o, child: CommonText(o, fontSize: 14))).toList(),
                  onChanged: (val) {
                    setState(() {
                      _draftLocation = val;
                      _draftStart = null;
                      _draftEnd = null;
                      _draftHorses = null;
                    });
                  },
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          const CommonText('Notes (this service line)', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          const SizedBox(height: 8),
          TextFormField(
            controller: _lineNotesCtrl,
            maxLines: 3,
            style: const TextStyle(fontSize: 14),
            decoration: _lineFieldDecoration('Add a note for this service...'),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _cancelEditLine,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: Color(0xFFE4E7EC)),
                  ),
                  child: const CommonText('Cancel', fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveLineDraft,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const CommonText('Save service', fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _lineFieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
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
    );
  }

  Widget _buildMultiBundleColumn() {
    final currencyFormat = NumberFormat.currency(symbol: '\$ ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoBanner(),
        const SizedBox(height: 20),
        const CommonText('Service summary', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        const SizedBox(height: 12),
        ...List.generate(_bundleLines.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _editingLineIndex == i ? _buildLineEditorCard() : _buildBundleLineSummaryCard(i, currencyFormat),
          );
        }),
        const SizedBox(height: 8),
        const CommonText('Overall notes to vendor', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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
    );
  }

  Widget _buildSingleServiceColumn() {
    final horseOptions = _getHorseOptions();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoBanner(),
        const SizedBox(height: 24),
        _buildDateRangeField(),
        const SizedBox(height: 20),
        _buildDropdownField(
          'Number Of Horses',
          'Select',
          horseOptions,
          horseOptions.contains(_selectedNumHorses) ? _selectedNumHorses : null,
          (val) => setState(() => _selectedNumHorses = val),
        ),
        const SizedBox(height: 20),
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
    );
  }

  @override
  Widget build(BuildContext context) {
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
        title: CommonText(
          _isMultiBundle ? 'Update Multi-Service Booking' : 'Update Vendor Booking',
          fontSize: AppTextSizes.size20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: _isLoadingLocations
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: _isMultiBundle ? _buildMultiBundleColumn() : _buildSingleServiceColumn(),
            ),
    );
  }
}
