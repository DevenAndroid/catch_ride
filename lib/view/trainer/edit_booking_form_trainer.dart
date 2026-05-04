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

class _ShowAvailability {
  final String cityState;
  final String startDate;
  final String endDate;
  final String id;

  _ShowAvailability({
    required this.cityState,
    required this.startDate,
    required this.endDate,
    required this.id,
  });
}

class EditBookingFormTrainer extends StatefulWidget {
  final BookingModel booking;

  const EditBookingFormTrainer({super.key, required this.booking});

  @override
  State<EditBookingFormTrainer> createState() => _EditBookingFormTrainerState();
}

class _EditBookingFormTrainerState extends State<EditBookingFormTrainer> {
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  // Location state - mirrors _showBookingRequestBottomSheet
  String? _homeLocation;
  List<_ShowAvailability> _showAvailabilities = [];
  String? _selectedLocationValue; // holds either homeLocation or show.id
  _ShowAvailability? _selectedShow;

  // Date
  DateTime? _selectedDate;

  bool _isLoadingHorse = true;

  @override
  void initState() {
    super.initState();
    _notesController.text = widget.booking.notes ?? '';
    // Pre-fill date
    try {
      _selectedDate = DateTime.parse(widget.booking.date);
    } catch (_) {
      _selectedDate = DateTime.now();
    }
    _fetchHorseData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchHorseData() async {
    final horseId = widget.booking.horseId;
    if (horseId == null) {
      setState(() => _isLoadingHorse = false);
      return;
    }
    try {
      final api = Get.find<ApiService>();
      final response = await api.getRequest('/horses/$horseId');
      if (response.statusCode == 200 && response.body['success'] == true) {
        final data = response.body['data'];
        if (data != null) {
          _homeLocation = data['location']?.toString();

          final List shows = data['showAvailability'] ?? [];
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          _showAvailabilities = shows.whereType<Map>().map((s) {
            return _ShowAvailability(
              cityState: s['cityState']?.toString() ?? '',
              startDate: s['startDate']?.toString() ?? '',
              endDate: s['endDate']?.toString() ?? '',
              id: s['_id']?.toString() ?? '${s['cityState']}_${s['startDate']}',
            );
          }).where((s) {
            // Filter out past shows
            if (s.endDate.isEmpty) return true;
            DateTime? end;
            try {
              end = DateTime.parse(s.endDate);
            } catch (_) {
              try {
                end = DateFormat('dd MMM yyyy').parse(s.endDate);
              } catch (_) {}
            }
            if (end == null) return true;
            return !end.isBefore(today);
          }).toList();

          // Try to match pre-existing location from booking
          final bookingLoc = widget.booking.location;
          if (bookingLoc != null && _homeLocation != null && bookingLoc == _homeLocation) {
            _selectedLocationValue = _homeLocation;
          } else if (bookingLoc != null) {
            // Try match by cityState
            final match = _showAvailabilities.firstWhereOrNull(
              (s) => s.cityState == bookingLoc,
            );
            if (match != null) {
              _selectedLocationValue = match.id;
              _selectedShow = match;
            } else {
              // Default to home
              _selectedLocationValue = _homeLocation;
            }
          } else {
            _selectedLocationValue = _homeLocation;
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching horse: $e');
    } finally {
      if (mounted) setState(() => _isLoadingHorse = false);
    }
  }

  bool _validate() {
    if (_selectedDate == null) {
      Get.snackbar('Error', 'Please select a date',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          barBlur: 0,
          margin: const EdgeInsets.all(16));
      return false;
    }
    if (_selectedLocationValue == null) {
      Get.snackbar('Error', 'Please select a location',
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
      final locationStr = _selectedShow?.cityState ?? _homeLocation ?? 'N/A';
      final payload = {
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
        'location': locationStr,
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

  Future<void> _openDatePicker() async {
    if (_selectedLocationValue == null) {
      Get.snackbar('Select Location', 'Please select a location first to see available dates.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime initial = _selectedDate ?? today;
    DateTime first = today;

    final isHome = _selectedLocationValue == _homeLocation;

    if (!isHome && _selectedShow != null) {
      final sDate = DateTime.tryParse(_selectedShow!.startDate);
      final eDate = DateTime.tryParse(_selectedShow!.endDate);
      if (sDate != null && eDate != null) {
        final startOnly = DateTime(sDate.year, sDate.month, sDate.day);
        final endOnly = DateTime(eDate.year, eDate.month, eDate.day);

        if (endOnly.isBefore(today)) {
          Get.snackbar('Show Ended', 'This show has already ended. Please select a different location.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white);
          return;
        }

        if (initial.isBefore(startOnly)) initial = startOnly;
        else if (initial.isAfter(endOnly)) initial = startOnly;
        if (initial.isBefore(today)) initial = today;
      }
    }

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      selectableDayPredicate: (DateTime day) {
        final dateOnly = DateTime(day.year, day.month, day.day);
        if (dateOnly.isBefore(today)) return false;
        if (isHome) return true;
        if (_selectedShow == null) return false;

        final sDate = DateTime.tryParse(_selectedShow!.startDate);
        final eDate = DateTime.tryParse(_selectedShow!.endDate);
        if (sDate != null && eDate != null) {
          final startOnly = DateTime(sDate.year, sDate.month, sDate.day);
          final endOnly = DateTime(eDate.year, eDate.month, eDate.day);
          return (dateOnly.isAtSameMomentAs(startOnly) || dateOnly.isAfter(startOnly)) &&
              (dateOnly.isAtSameMomentAs(endOnly) || dateOnly.isBefore(endOnly));
        }
        return false;
      },
    );

    if (date != null) setState(() => _selectedDate = date);
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
        title: const CommonText('Update Booking', fontSize: AppTextSizes.size20, fontWeight: FontWeight.bold),
      ),
      body: _isLoadingHorse
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
                        const Icon(Icons.info_outline, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CommonText(
                            'Editing booking for ${widget.booking.horseName ?? 'Horse'}',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Location first (same order as original — select location before date)
                  const CommonText('Location', fontSize: 13, fontWeight: FontWeight.bold),
                  const SizedBox(height: 4),
                  const CommonText(
                    'Note: Trials can be requested at horse shows or the horse\'s home location.',
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedLocationValue,
                        isExpanded: true,
                        itemHeight: null,
                        hint: const CommonText('Select Location', fontSize: 14, color: AppColors.textSecondary),
                        items: [
                          if (_homeLocation != null && _homeLocation!.isNotEmpty)
                            DropdownMenuItem(
                              value: _homeLocation,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CommonText('$_homeLocation (Home)', fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                                    const CommonText('Available at home', fontSize: 11, color: AppColors.textSecondary),
                                  ],
                                ),
                              ),
                            ),
                          ..._showAvailabilities.map((show) {
                            String dateRange = '';
                            try {
                              final s = DateTime.parse(show.startDate);
                              final e = DateTime.parse(show.endDate);
                              dateRange = '${DateFormat('dd MMM').format(s)} - ${DateFormat('dd MMM yyyy').format(e)}';
                            } catch (_) {}
                            return DropdownMenuItem(
                              value: show.id,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CommonText(show.cityState, fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                                    if (dateRange.isNotEmpty)
                                      CommonText(dateRange, fontSize: 11, color: AppColors.textSecondary),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _selectedLocationValue = val;
                            _selectedShow = _showAvailabilities.firstWhereOrNull((s) => s.id == val);

                            // Reset date if it becomes invalid for the new location
                            if (_selectedDate != null && _selectedShow != null) {
                              final sDate = DateTime.tryParse(_selectedShow!.startDate);
                              final eDate = DateTime.tryParse(_selectedShow!.endDate);
                              if (sDate != null && eDate != null) {
                                final d = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
                                final s = DateTime(sDate.year, sDate.month, sDate.day);
                                final e = DateTime(eDate.year, eDate.month, eDate.day);
                                final valid = (d.isAtSameMomentAs(s) || d.isAfter(s)) && (d.isAtSameMomentAs(e) || d.isBefore(e));
                                if (!valid) _selectedDate = null;
                              }
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Date
                  const CommonText('Date', fontSize: 13, fontWeight: FontWeight.bold),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _openDatePicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CommonText(
                            _selectedDate != null
                                ? DateFormat('dd MMM yyyy').format(_selectedDate!)
                                : 'Select Date',
                            fontSize: 14,
                            color: _selectedDate != null ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                          const Icon(Icons.calendar_today_outlined, size: 20, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Message
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontFamily: 'Outfit'),
                      children: [
                        TextSpan(text: 'Message '),
                        TextSpan(
                          text: '(optional)',
                          style: TextStyle(fontWeight: FontWeight.normal, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 120,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Please include your preferred time frame for the trial...',
                        hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5), fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
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
              ),
            ),
    );
  }
}
