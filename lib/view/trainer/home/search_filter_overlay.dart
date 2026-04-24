import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:intl/intl.dart';

import '../../../controllers/explore_controller.dart';
import '../../../controllers/google_api_controller.dart';

class SearchFilterOverlay extends StatefulWidget {
  const SearchFilterOverlay({super.key});

  @override
  State<SearchFilterOverlay> createState() => _SearchFilterOverlayState();
}

class _SearchFilterOverlayState extends State<SearchFilterOverlay> {
  final ExploreController controller = Get.put(ExploreController());
  final TextEditingController _searchController = TextEditingController();
  final  googleApiController = Get.put(GoogleApiController());

  String _selectedSection = 'location'; // 'location' or 'date'
  late String _selectedCategory;
  String _locationType = 'City or Region'; // 'City or Region' or 'Show Venue'

  // Dynamic Calendar State
  late DateTime _focusedDate;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  bool _showAllLocations = false;
  bool _showAllVenues = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = controller.selectedDiscipline.value;
    _searchController.text = controller.searchQuery.value;
    _focusedDate = DateTime.now();
    _rangeStart = controller.startDate.value;
    _rangeEnd = controller.endDate.value;
  }

  Future<void> _onSearchPressed() async {
    FocusManager.instance.primaryFocus!.unfocus();
    setState(() {
      _isSearching = true;
    });
    controller.selectedDiscipline.value = _selectedCategory;
    controller.searchQuery.value = _searchController.text;
    controller.startDate.value = _rangeStart;
    controller.endDate.value = _rangeEnd;



    // Save all active filters to history
    if (_searchController.text.trim().isNotEmpty) {
      controller.addToHistory(_searchController.text.trim());
    }
    if (controller.location.value.isNotEmpty) {
      controller.addToHistory(controller.location.value);
    }
    if (controller.showVenue.value.isNotEmpty) {
      controller.addToHistory(controller.showVenue.value);
    }
    if (_rangeStart != null) {
      final dateStr = _rangeEnd != null
          ? '${DateFormat('dd MMM yyyy').format(_rangeStart!)} - ${DateFormat('dd MMM yyyy').format(_rangeEnd!)}'
          : DateFormat('dd MMM yyyy').format(_rangeStart!);
      controller.addToHistory(dateStr);
    }

    await controller.fetchHorses(showLoading: false);
    if (mounted) {
      Get.back();
    }
  }

  void _onClearAll() {
    controller.clearAllFilters();
    setState(() {
      _selectedCategory = 'All';
      _searchController.clear();
      _locationType = 'City or Region';
      _rangeStart = null;
      _rangeEnd = null;
    });
    controller.fetchHorses(showLoading: false);
    Get.back();
  }

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.grid_view_rounded, 'isSvg': false},

    {'name': 'Hunter', 'icon': 'assets/icons/hunter.svg', 'isSvg': true},
    {'name': 'Jumper', 'icon': "assets/icons/jumper.svg", 'isSvg': true},
    {
      'name': 'Equitation',
      'icon': 'assets/icons/equitation.svg',
      'isSvg': true,
    },
    {'name': 'Services', 'icon': 'assets/icons/vendor.svg', 'isSvg': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Background Blur
          GestureDetector(
            onTap: () => Get.back(),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withOpacity(0.1)),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Column(
                      children: [
                        if (_selectedSection == 'location')
                          _buildLocationSection(),
                        if (_selectedSection == 'date') _buildDateSection(),
                      ],
                    ),
                  ),
                ),
                _buildFooter(),
                const SizedBox(height: 10),
              ],
            ),
          ),

          // Close Button
          Positioned(
            top: 20,
            right: 20,
            child: SafeArea(
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.black, size: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      // color: Colors.white,
      padding: const EdgeInsets.only(top: 60, bottom: 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: _categories.map((cat) {
            final isSelected = _selectedCategory == cat['name'];
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat['name']),
              child: Container(
                margin: const EdgeInsets.only(right: 20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: cat['isSvg']
                          ? SvgPicture.asset(
                              cat['icon'] as String,
                              width: 28,
                              height: 28,
                              colorFilter: ColorFilter.mode(
                                isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                                BlendMode.srcIn,
                              ),
                            )
                          : Icon(
                              cat['icon'] as IconData,
                              size: 28,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                    ),
                    const SizedBox(height: 8),
                    CommonText(
                      cat['name'],
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                    const SizedBox(height: 8),
                    if (isSelected)
                      Container(
                        height: 2,
                        width: 40,
                        margin: const EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      )
                    else
                      const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    final bool isShowVenue = _locationType == 'Show Venue';

    return Column(
      children: [
        // Main Location Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Input
              TextField(
                controller: _searchController,
                onChanged: (val) {
                  if (isShowVenue) {
                    controller.searchVenues(val);
                  } else {
                    controller.searchLocations(val);
                  }
                  setState(
                    () {},
                  ); // Rebuild to switch between default and suggestions
                },
                decoration: InputDecoration(
                  hintText: 'Search horses, services, and circuits',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.5),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Toggle Switcher
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildToggleItem(
                        'City or Region',
                        _locationType == 'City or Region',
                      ),
                    ),
                    Expanded(
                      child: _buildToggleItem(
                        'Show Venue',
                        _locationType == 'Show Venue',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Suggested Items (Matching Design)
              Obx(() {
                if (controller.isSuggestionsLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                final isSearching = _searchController.text.isNotEmpty;

                if (isShowVenue) {
                  var list = (isSearching
                          ? controller.venuesSuggestions
                          : controller.defaultVenues)
                      .toList();

                  final bool hasMore = list.length > 3;
                  final displayList =
                      _showAllVenues ? list : list.take(3).toList();

                  if (list.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: CommonText(
                        isSearching ? 'No venues found' : 'Loading venues...',
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...displayList.map(
                        (v) => _buildLocationItem(
                          v['name'] ?? '',
                          isVenue: true,
                          subtitle: v['subtitle'],
                        ),
                      ),
                      if (hasMore && !_showAllVenues)
                        GestureDetector(
                          onTap: () => setState(() => _showAllVenues = true),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                CommonText(
                                  'See All',
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.keyboard_arrow_down,
                                    size: 16, color: AppColors.primary),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                } else {
                  var list = (isSearching
                          ? controller.locationsSuggestions
                          : controller.defaultLocations)
                      .toList();

                  final bool hasMore = list.length > 3;
                  final displayList =
                      _showAllLocations ? list : list.take(3).toList();

                  if (list.isEmpty && googleApiController.googleSuggestions.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: CommonText(
                        isSearching
                            ? 'No locations found'
                            : 'Loading locations...',
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isSearching) ...[
                        Obx(() {
                          final regionType = controller.serviceTagTypes.firstWhereOrNull(
                            (t) => t['name'] == 'Regions Covered'
                          );
                          final List<String> regionOptions = regionType != null
                              ? List<String>.from(regionType['values'].map((v) => v['name']))
                              : [
                                  'Florida (Wellington • Ocala • Gulf Coast)',
                                  'Southwest (Thermal • AZ winter circuit)',
                                  'Southeast (Aiken • Tryon • Wills Park • Chatt Hills)'
                                ];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: regionOptions
                                .where((r) => r.toLowerCase().contains(_searchController.text.toLowerCase()))
                                .map((r) => _buildLocationItem(r, isRegion: true))
                                .toList(),
                          );
                        }),
                      ],
                      ...displayList.map(
                          (l) => _buildLocationItem(l['name'] ?? '')),
                      if (hasMore && !_showAllLocations)
                        GestureDetector(
                          onTap: () => setState(() => _showAllLocations = true),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                CommonText(
                                  'See All',
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.keyboard_arrow_down,
                                    size: 16, color: AppColors.primary),
                              ],
                            ),
                          ),
                        ),

                      // Google Suggestions
                      if (isSearching && googleApiController.googleSuggestions.isNotEmpty)
                        ...googleApiController.googleSuggestions.map(
                          (g) => _buildLocationItem(g['name'] ?? ''),
                        ),
                    ],
                  );
                }
              }),

              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: CommonText(
                  'Search History',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Column(
                  children: controller.recentSearches.isEmpty
                      ? [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: CommonText(
                              'No recent searches',
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ]
                      : controller.recentSearches
                            .map((search) => _buildHistoryItem(search))
                            .toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // When Card
        GestureDetector(
          onTap: () => setState(() => _selectedSection = 'date'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CommonText(
                  'When',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                CommonText(
                  _rangeStart != null
                      ? (_rangeEnd != null
                            ? '${DateFormat('dd MMM yyyy').format(_rangeStart!)} - ${DateFormat('dd MMM yyyy').format(_rangeEnd!)}'
                            : DateFormat('dd MMM yyyy').format(_rangeStart!))
                      : 'Add dates',
                  fontSize: 14,
                  color: AppColors.textSecondary.withOpacity(0.8),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40), // Ensuring Add Dates is not obscured
      ],
    );
  }

  Widget _buildDateSection() {
    return Column(
      children: [
        // Collapsed Location Type Header
        GestureDetector(
          onTap: () => setState(() => _selectedSection = 'location'),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CommonText(
                  'City or Region',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                const CommonText(
                  'Nearby',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Detailed Date Picker Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CommonText(
                'When',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildDateInput('Start Date', _rangeStart)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDateInput('End Date', _rangeEnd)),
                ],
              ),
              const SizedBox(height: 20),

              // Calendar View Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Month Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => setState(
                            () => _focusedDate = DateTime(
                              _focusedDate.year,
                              _focusedDate.month - 1,
                            ),
                          ),
                          child: Icon(
                            Icons.chevron_left,
                            color: AppColors.textSecondary.withOpacity(0.6),
                          ),
                        ),
                        CommonText(
                          '${_getMonthName(_focusedDate.month)} ${_focusedDate.year}',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        GestureDetector(
                          onTap: () => setState(
                            () => _focusedDate = DateTime(
                              _focusedDate.year,
                              _focusedDate.month + 1,
                            ),
                          ),
                          child: Icon(
                            Icons.chevron_right,
                            color: AppColors.textSecondary.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Days Headers
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
                          .map(
                            (d) => CommonText(
                              d,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),

                    // The Grid
                    _buildCalendarGrid(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleItem(String title, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _locationType = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: CommonText(
            title,
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive
                ? AppColors.textPrimary
                : AppColors.textSecondary.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationItem(
    String location, {
    bool isVenue = false,
    bool isRegion = false,
    String? subtitle,
  }) {
    return GestureDetector(
      onTap: () {
        if (isRegion) {
          controller.regionsCovered.assignAll([location]);
          controller.location.value = '';
          controller.showVenue.value = '';
          controller.isServiceFilterApplied.value = true;
        } else if (isVenue) {
          controller.showVenue.value = location;
          controller.location.value = '';
          controller.regionsCovered.clear();
        } else {
          controller.location.value = location;
          controller.showVenue.value = '';
          controller.regionsCovered.clear();
        }
        _searchController.clear();
        _onSearchPressed();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.lightGray.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isVenue ? Icons.near_me_rounded : Icons.near_me_rounded,
                size: 16,
                color: AppColors.textSecondary.withOpacity(0.8),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    location,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  if (subtitle != null)
                    CommonText(
                      subtitle,
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String address) {
    return GestureDetector(
      onTap: () {
        // Logic to restore the correct filter type from history string
        bool isDateRange = address.contains(' - ') && address.length > 20;
        bool isSingleDate =
            RegExp(r'^\d{2} [A-Za-z]{3} \d{4}$').hasMatch(address);

        if (isDateRange || isSingleDate) {
          try {
            if (isDateRange) {
              final parts = address.split(' - ');
              _rangeStart = DateFormat('dd MMM yyyy').parse(parts[0]);
              _rangeEnd = DateFormat('dd MMM yyyy').parse(parts[1]);
            } else {
              _rangeStart = DateFormat('dd MMM yyyy').parse(address);
              _rangeEnd = null;
            }
            controller.startDate.value = _rangeStart;
            controller.endDate.value = _rangeEnd;
            _searchController.clear();
            _selectedSection = 'date';
          } catch (e) {
            _searchController.text = address;
          }
        } else {
          // Try to match against known locations or venues first
          bool isKnownLocation = controller.defaultLocations
              .any((l) => l['name'] == address || l['subtitle'] == address);
          bool isKnownVenue = controller.defaultVenues
              .any((v) => v['name'] == address || v['subtitle'] == address);

          if (isKnownVenue) {
            controller.showVenue.value = address;
            controller.location.value = '';
            _searchController.clear();
          } else if (isKnownLocation) {
            controller.location.value = address;
            controller.showVenue.value = '';
            _searchController.clear();
          } else {
            // Default to text search
            _searchController.text = address;
          }
        }
        _onSearchPressed();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            const Icon(
              Icons.restart_alt_rounded,
              size: 24,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 16),
            Expanded(child: CommonText(address, fontSize: 15, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[month - 1];
  }

  Widget _buildDateInput(String title, DateTime? date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CommonText(
            date != null ? DateFormat('dd MMM yyyy').format(date) : title,
            color: date != null
                ? AppColors.textPrimary
                : AppColors.textSecondary.withOpacity(0.6),
            fontSize: 14,
          ),
          const Icon(
            Icons.calendar_month_outlined,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(
      _focusedDate.year,
      _focusedDate.month + 1,
      0,
    ).day;
    final firstDayOfMonth = DateTime(
      _focusedDate.year,
      _focusedDate.month,
      1,
    ).weekday;

    // Adjust for Monday start (Flutter's weekday starts at 1 for Monday)
    // firstDayOfMonth: 1 = Mon, 7 = Sun
    int offset = firstDayOfMonth - 1; // 0 = Mon, 6 = Sun

    final int itemCount = daysInMonth + offset;
    final int roundedItemCount = (itemCount / 7).ceil() * 7;

    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 0,
        childAspectRatio: 1.0,
      ),
      itemCount: 42, // Show a fixed 6-row grid (7 * 6) for consistency
      itemBuilder: (context, index) {
        final daysInPrevMonth = DateTime(
          _focusedDate.year,
          _focusedDate.month,
          0,
        ).day;
        int dayNumber;
        bool isCurrentMonth = true;

        if (index < offset) {
          dayNumber = daysInPrevMonth - offset + index + 1;
          isCurrentMonth = false;
        } else if (index >= offset + daysInMonth) {
          dayNumber = index - (offset + daysInMonth) + 1;
          isCurrentMonth = false;
        } else {
          dayNumber = index - offset + 1;
        }

        if (!isCurrentMonth) {
          return Center(
            child: CommonText(
              dayNumber.toString(),
              color: AppColors.textSecondary.withOpacity(0.3),
              fontSize: 14,
            ),
          );
        }

        final date = DateTime(_focusedDate.year, _focusedDate.month, dayNumber);

        bool isStart = _rangeStart != null && _isSameDay(date, _rangeStart!);
        bool isEnd = _rangeEnd != null && _isSameDay(date, _rangeEnd!);
        bool inRange =
            _rangeStart != null &&
            _rangeEnd != null &&
            date.isAfter(_rangeStart!) &&
            date.isBefore(_rangeEnd!);

        bool isToday = _isSameDay(date, DateTime.now());

        return GestureDetector(
          onTap: () {
            setState(() {
              if (_rangeStart == null ||
                  (_rangeStart != null && _rangeEnd != null)) {
                _rangeStart = date;
                _rangeEnd = null;
              } else if (date.isBefore(_rangeStart!)) {
                _rangeStart = date;
              } else {
                _rangeEnd = date;
              }
            });
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (inRange || isStart || isEnd)
                Container(
                  margin: EdgeInsets.only(
                    left: isStart ? 10 : 0,
                    right: isEnd ? 10 : 0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.horizontal(
                      left: isStart ? const Radius.circular(20) : Radius.zero,
                      right: isEnd ? const Radius.circular(20) : Radius.zero,
                    ),
                  ),
                ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: (isStart || isEnd)
                      ? AppColors.primary
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CommonText(
                    dayNumber.toString(),
                    color: (isStart || isEnd)
                        ? Colors.white
                        : AppColors.textPrimary,
                    fontWeight: (isStart || isEnd)
                        ? FontWeight.bold
                        : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              if (isToday)
                Positioned(
                  bottom: 4,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppColors.textSecondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      // decoration: BoxDecoration(
      //   color: Colors.white.withOpacity(0.9),
      //   borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      // ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _onClearAll,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: CommonText(
                    'Clear all',
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap:() {
                controller.regionsCovered.clear();
              controller.location.value="";
                _onSearchPressed();
              } ,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _isSearching
                    ? const Center(
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_rounded,
                              color: Colors.white, size: 22),
                          const SizedBox(width: 8),
                          const CommonText(
                            'Search',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
