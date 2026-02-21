import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/utils/date_picker_helper.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';

// --- Data Model ---

enum ShippingAvailabilityType { show, home }

class ShippingAvailability {
  final String id;
  final String shipperId;
  ShippingAvailabilityType type;
  DateTime startDate;
  DateTime endDate;
  String? venueName;
  String? homeBaseLocation;
  bool isActive;
  String? title;
  List<String> destinationRegions;
  String? notes;

  ShippingAvailability({
    required this.id,
    required this.shipperId,
    required this.type,
    required this.startDate,
    required this.endDate,
    this.venueName,
    this.homeBaseLocation,
    this.isActive = true,
    this.title,
    this.destinationRegions = const [],
    this.notes,
  });

  String get displayTitle {
    if (title != null && title!.isNotEmpty) return title!;
    final dateStr = DateFormat('MMM d').format(startDate);
    if (type == ShippingAvailabilityType.show) {
      return '${venueName ?? 'Show'} · $dateStr';
    } else {
      return 'Based in ${homeBaseLocation ?? 'Area'} · $dateStr';
    }
  }

  bool get isExpired {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final strippedEnd = DateTime(endDate.year, endDate.month, endDate.day);
    return strippedEnd.isBefore(today);
  }
}

// --- List View Screen ---

class AvailabilityShippingScreen extends StatefulWidget {
  const AvailabilityShippingScreen({super.key});

  @override
  State<AvailabilityShippingScreen> createState() =>
      _AvailabilityShippingScreenState();
}

class _AvailabilityShippingScreenState
    extends State<AvailabilityShippingScreen> {
  final List<ShippingAvailability> _availabilityList = [];

  // Mock initial data
  @override
  void initState() {
    super.initState();
    _availabilityList.add(
      ShippingAvailability(
        id: '1',
        shipperId: 'v123',
        type: ShippingAvailabilityType.show,
        startDate: DateTime.now().add(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 12)),
        venueName: 'Wellington WEF',
        destinationRegions: ['Southeast', 'Mid-Atlantic'],
        notes: 'Weekly runs to Wellington and back.',
      ),
    );
    _availabilityList.add(
      ShippingAvailability(
        id: '2',
        shipperId: 'v123',
        type: ShippingAvailabilityType.home,
        startDate: DateTime.now().add(const Duration(days: 15)),
        endDate: DateTime.now().add(const Duration(days: 30)),
        homeBaseLocation: 'Kentucky',
        destinationRegions: ['Nationwide'],
        isActive: false,
      ),
    );
  }

  void _addAvailability() {
    Get.to(
      () => CreateAvailabilityShippingScreen(
        onSave: (val) => setState(() => _availabilityList.add(val)),
      ),
    );
  }

  void _editAvailability(ShippingAvailability entry) {
    Get.to(
      () => CreateAvailabilityShippingScreen(
        existing: entry,
        onSave: (val) {
          setState(() {
            final index = _availabilityList.indexWhere((e) => e.id == entry.id);
            if (index != -1) _availabilityList[index] = val;
          });
        },
        onDelete: () {
          setState(
            () => _availabilityList.removeWhere((e) => e.id == entry.id),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeUpcoming = _availabilityList
        .where((e) => !e.isExpired && e.isActive)
        .toList();
    final inactive = _availabilityList
        .where((e) => !e.isExpired && !e.isActive)
        .toList();
    final expired = _availabilityList.where((e) => e.isExpired).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Shipping Availability'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addAvailability,
        backgroundColor: AppColors.deepNavy,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Availability',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 32),

            if (activeUpcoming.isNotEmpty) ...[
              _sectionTitle('Active & Upcoming'),
              ...activeUpcoming.map((e) => _availabilityCard(e)),
            ],

            if (inactive.isNotEmpty) ...[
              const SizedBox(height: 24),
              _sectionTitle('Inactive'),
              ...inactive.map((e) => _availabilityCard(e)),
            ],

            if (expired.isNotEmpty) ...[
              const SizedBox(height: 24),
              _sectionTitle('Expired'),
              ...expired.map((e) => _availabilityCard(e, isExpired: true)),
            ],

            if (_availabilityList.isEmpty) _emptyState(),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manage Your Routes',
          style: AppTextStyles.headlineLarge.copyWith(
            color: AppColors.deepNavy,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add show-based or home-based availability to help trainers find your routes.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey600),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelLarge.copyWith(
          color: AppColors.grey500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _availabilityCard(
    ShippingAvailability entry, {
    bool isExpired = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpired ? AppColors.grey200 : AppColors.grey300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _editAvailability(entry),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.displayTitle,
                        style: AppTextStyles.titleLarge.copyWith(
                          color: isExpired
                              ? AppColors.grey500
                              : AppColors.deepNavy,
                        ),
                      ),
                    ),
                    _typeBadge(entry.type, isExpired),
                  ],
                ),
                const SizedBox(height: 12),
                _infoRow(
                  Icons.calendar_today_outlined,
                  '${DateFormat('MMM d').format(entry.startDate)} – ${DateFormat('MMM d, yyyy').format(entry.endDate)}',
                  isExpired,
                ),
                const SizedBox(height: 8),
                _infoRow(
                  entry.type == ShippingAvailabilityType.show
                      ? Icons.location_on_outlined
                      : Icons.home_outlined,
                  entry.type == ShippingAvailabilityType.show
                      ? entry.venueName!
                      : entry.homeBaseLocation!,
                  isExpired,
                ),

                if (entry.destinationRegions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: entry.destinationRegions
                        .map((r) => _regionChip(r, isExpired))
                        .toList(),
                  ),
                ],

                const SizedBox(height: 16),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          entry.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: entry.isActive
                                ? AppColors.successGreen
                                : AppColors.grey500,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 24,
                          child: Switch.adaptive(
                            value: entry.isActive,
                            activeColor: AppColors.successGreen,
                            onChanged: isExpired
                                ? null
                                : (v) => setState(() => entry.isActive = v),
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => _editAvailability(entry),
                      child: const Text('Edit Details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _typeBadge(ShippingAvailabilityType type, bool isExpired) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isExpired
            ? AppColors.grey100
            : AppColors.mutedGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isExpired
              ? AppColors.grey300
              : AppColors.mutedGold.withOpacity(0.3),
        ),
      ),
      child: Text(
        type == ShippingAvailabilityType.show ? 'SHOW-BASED' : 'HOME-BASED',
        style: AppTextStyles.bodySmall.copyWith(
          color: isExpired ? AppColors.grey500 : AppColors.mutedGold,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, bool isExpired) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isExpired ? AppColors.grey400 : AppColors.mutedGold,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isExpired ? AppColors.grey500 : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _regionChip(String label, bool isExpired) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: isExpired ? AppColors.grey400 : AppColors.grey700,
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(Icons.map_outlined, size: 64, color: AppColors.grey200),
            const SizedBox(height: 16),
            Text(
              'No availability blocks yet.',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.grey400,
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Add Your First entry',
              onPressed: _addAvailability,
            ),
          ],
        ),
      ),
    );
  }
}

// --- Create/Edit Screen ---

class CreateAvailabilityShippingScreen extends StatefulWidget {
  final ShippingAvailability? existing;
  final Function(ShippingAvailability) onSave;
  final VoidCallback? onDelete;

  const CreateAvailabilityShippingScreen({
    super.key,
    this.existing,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<CreateAvailabilityShippingScreen> createState() =>
      _CreateAvailabilityShippingScreenState();
}

class _CreateAvailabilityShippingScreenState
    extends State<CreateAvailabilityShippingScreen> {
  late ShippingAvailabilityType _type;
  late DateTime _startDate;
  late DateTime _endDate;
  late bool _isActive;

  final _titleController = TextEditingController();
  final _anchorController =
      TextEditingController(); // For Venue or home location
  final _notesController = TextEditingController();
  final Set<String> _selectedRegions = {};

  final List<String> _venues = [
    'Wellington WEF',
    'WEC Ocala',
    'HITS Ocala',
    'Kentucky Horse Park',
    'Tryon International',
    'Gulf Coast Classic',
    'Other (Specify)',
  ];

  final List<String> _regionOptions = [
    'Local',
    'Statewide',
    'Regional',
    'Southeast',
    'Mid-Atlantic',
    'Northeast',
    'Midwest',
    'Southwest',
    'West Coast',
    'Canada',
    'International',
    'Nationwide',
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _type = e?.type ?? ShippingAvailabilityType.show;
    _startDate = e?.startDate ?? DateTime.now();
    _endDate = e?.endDate ?? DateTime.now().add(const Duration(days: 7));
    _isActive = e?.isActive ?? true;
    _titleController.text = e?.title ?? '';
    _anchorController.text =
        (e?.type == ShippingAvailabilityType.show
            ? e?.venueName
            : e?.homeBaseLocation) ??
        '';
    _notesController.text = e?.notes ?? '';
    if (e != null) _selectedRegions.addAll(e.destinationRegions);
  }

  void _submit() {
    if (_anchorController.text.trim().isEmpty) {
      Get.snackbar(
        'Field Required',
        '${_type == ShippingAvailabilityType.show ? 'Show Venue' : 'Home Base Location'} is required.',
        backgroundColor: AppColors.softRed,
        colorText: Colors.white,
      );
      return;
    }
    if (_endDate.isBefore(_startDate)) {
      Get.snackbar(
        'Invalid Dates',
        'End date cannot be before start date.',
        backgroundColor: AppColors.softRed,
        colorText: Colors.white,
      );
      return;
    }

    final availability = ShippingAvailability(
      id:
          widget.existing?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      shipperId: 'v123',
      type: _type,
      startDate: _startDate,
      endDate: _endDate,
      venueName: _type == ShippingAvailabilityType.show
          ? _anchorController.text.trim()
          : null,
      homeBaseLocation: _type == ShippingAvailabilityType.home
          ? _anchorController.text.trim()
          : null,
      isActive: _isActive,
      title: _titleController.text.trim(),
      destinationRegions: _selectedRegions.toList(),
      notes: _notesController.text.trim(),
    );

    widget.onSave(availability);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existing == null ? 'Add Availability' : 'Edit Availability',
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Type
            _sectionLabel('Availability Type *'),
            Row(
              children: [
                _typeOption(
                  ShippingAvailabilityType.show,
                  'Show-based',
                  Icons.location_on_outlined,
                ),
                const SizedBox(width: 16),
                _typeOption(
                  ShippingAvailabilityType.home,
                  'Home-based',
                  Icons.home_outlined,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 2. Anchor
            _sectionLabel(
              _type == ShippingAvailabilityType.show
                  ? 'Show Venue *'
                  : 'Home Base Location *',
            ),
            if (_type == ShippingAvailabilityType.show)
              _venueDropdown()
            else
              CustomTextField(
                label: 'City, State or State',
                controller: _anchorController,
              ),
            const SizedBox(height: 24),

            // 3. Dates
            _sectionLabel('Date Window *'),
            _datePickerRow(),
            const SizedBox(height: 24),

            // 4. Status
            SwitchListTile(
              title: const Text('Mark as Active'),
              subtitle: const Text(
                'Inactive entries won’t show up in trainer searches.',
              ),
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
              activeColor: AppColors.successGreen,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 24),

            // 5. Optional Title
            CustomTextField(
              label: 'Custom Title (Optional)',
              hint: 'e.g. Early Spring circuit...',
              controller: _titleController,
            ),
            const SizedBox(height: 24),

            // 6. Destination Regions
            _sectionLabel('Destination Regions (Multi-select)'),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _regionOptions.map((r) {
                final isSelected = _selectedRegions.contains(r);
                return FilterChip(
                  label: Text(r),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      if (val)
                        _selectedRegions.add(r);
                      else
                        _selectedRegions.remove(r);
                    });
                  },
                  selectedColor: AppColors.deepNavy.withOpacity(0.1),
                  checkmarkColor: AppColors.deepNavy,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.deepNavy : AppColors.grey700,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 7. Notes
            CustomTextField(
              label: 'Notes (Short)',
              hint: 'Any specific route info, layover capacity...',
              controller: _notesController,
              maxLines: 3,
            ),

            const SizedBox(height: 48),
            CustomButton(
              text: widget.existing == null
                  ? 'Create Availability'
                  : 'Save Changes',
              onPressed: _submit,
            ),

            if (widget.existing != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => _confirmDelete(),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.softRed,
                  ),
                  label: const Text(
                    'Delete Entry',
                    style: TextStyle(color: AppColors.softRed),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  void _confirmDelete() {
    Get.defaultDialog(
      title: 'Delete Entry?',
      middleText: 'This action cannot be undone.',
      confirm: TextButton(
        onPressed: () {
          widget.onDelete?.call();
          Get.back(); // close dialog
          Get.back(); // close edit screen
        },
        child: const Text('Delete', style: TextStyle(color: AppColors.softRed)),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel'),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(label, style: AppTextStyles.labelLarge),
    );
  }

  Widget _typeOption(
    ShippingAvailabilityType type,
    String label,
    IconData icon,
  ) {
    final isSelected = _type == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _type = type),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.deepNavy : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.deepNavy : AppColors.grey300,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : AppColors.grey500),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.grey700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _venueDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _venues.contains(_anchorController.text)
              ? _anchorController.text
              : null,
          isExpanded: true,
          hint: const Text('Select show venue'),
          items: _venues
              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
              .toList(),
          onChanged: (v) {
            setState(() {
              if (v == 'Other (Specify)') {
                _anchorController.clear();
                _showOtherVenuePopup();
              } else {
                _anchorController.text = v ?? '';
              }
            });
          },
        ),
      ),
    );
  }

  void _showOtherVenuePopup() {
    final ctrl = TextEditingController();
    Get.defaultDialog(
      title: 'Specify Venue',
      content: CustomTextField(label: 'Venue Name', controller: ctrl),
      confirm: TextButton(
        onPressed: () {
          setState(() => _anchorController.text = ctrl.text);
          Get.back();
        },
        child: const Text('Add'),
      ),
    );
  }

  Widget _datePickerRow() {
    return Row(
      children: [
        Expanded(
          child: _dateItem(
            'Starts',
            _startDate,
            (d) => setState(() => _startDate = d),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _dateItem(
            'Ends',
            _endDate,
            (d) => setState(() => _endDate = d),
          ),
        ),
      ],
    );
  }

  Widget _dateItem(String label, DateTime date, Function(DateTime) onPick) {
    return InkWell(
      onTap: () async {
        final d = await AppDatePicker.pickDate(context, initialDate: date);
        if (d != null) onPick(d);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM d, yyyy').format(date),
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
