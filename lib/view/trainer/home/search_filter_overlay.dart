import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_text.dart';

import '../../../controllers/explore_controller.dart';

class SearchFilterOverlay extends StatefulWidget {
  const SearchFilterOverlay({super.key});

  @override
  State<SearchFilterOverlay> createState() => _SearchFilterOverlayState();
}

class _SearchFilterOverlayState extends State<SearchFilterOverlay> {
  final ExploreController controller = Get.find<ExploreController>();
  final TextEditingController _searchController = TextEditingController();

  String _selectedSection = 'location'; // 'location' or 'date'
  late String _selectedCategory;
  String _locationType = 'City / Home'; // 'City / Home' or 'Show Venue'

  @override
  void initState() {
    super.initState();
    _selectedCategory = controller.selectedDiscipline.value;
    _searchController.text = controller.searchQuery.value;
  }

  void _onSearchPressed() {
    controller.selectedDiscipline.value = _selectedCategory;
    controller.searchQuery.value = _searchController.text;
    controller.fetchHorses();
    Get.back();
  }

  void _onClearAll() {
    setState(() {
      _selectedCategory = 'All';
      _searchController.clear();
      _locationType = 'City / Home';
    });
  }
  
  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.grid_view_rounded, 'isSvg': false},
    {'name': 'Hunter', 'icon': 'assets/icons/hunter.svg', 'isSvg': true},
    {'name': 'Jumper', 'icon': 'assets/icons/jumper.svg', 'isSvg': true},
    {'name': 'Equitation', 'icon': 'assets/icons/equitation.svg', 'isSvg': true},
    {'name': 'Vendors', 'icon': 'assets/icons/vendor.svg', 'isSvg': true},
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
              child: Container(
                color: Colors.black.withOpacity(0.1),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        if (_selectedSection == 'location') _buildLocationSection(),
                        if (_selectedSection == 'date') _buildDateSection(),
                      ],
                    ),
                  ),
                ),
                _buildFooter(),
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
      padding: const EdgeInsets.only(top: 60, bottom: 20),
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
                        color: isSelected ? const Color(0xFFE8EAF6) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: cat['isSvg']
                          ? SvgPicture.asset(
                              cat['icon'],
                              width: 28,
                              height: 28,
                              colorFilter: ColorFilter.mode(
                                isSelected ? AppColors.primary : AppColors.textPrimary,
                                BlendMode.srcIn,
                              ),
                            )
                          : Icon(
                              cat['icon'] as IconData,
                              size: 28,
                              color: isSelected ? AppColors.primary : AppColors.textPrimary,
                            ),
                    ),
                    const SizedBox(height: 8),
                    CommonText(
                      cat['name'],
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                    const SizedBox(height: 8),
                    if (isSelected)
                      Container(
                        height: 3,
                        width: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      )
                    else 
                      const SizedBox(height: 3),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search horses, vendors and circuits',
                    hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search_rounded, color: Colors.black87),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Toggle Switcher
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildToggleItem('City / Home', _locationType == 'City / Home'),
                    ),
                    Expanded(
                      child: _buildToggleItem('Show Venue', _locationType == 'Show Venue'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Suggested Items (Matching Image: Bruce's Field)
              _buildLocationItem('Bruce\'s Field', isVenue: isShowVenue),
              _buildLocationItem('Bruce\'s Field', isVenue: isShowVenue),
              _buildLocationItem('Bruce\'s Field', isVenue: isShowVenue),
              
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: CommonText('Search History', fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              _buildHistoryItem('Maple Street'),
              _buildHistoryItem('Oak Lane'),
              _buildHistoryItem('Pine Road'),
              _buildHistoryItem('Elm Drive'),
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
                const CommonText('When', fontSize: 16, fontWeight: FontWeight.bold),
                CommonText('Add dates', fontSize: 14, color: AppColors.textSecondary.withOpacity(0.8)),
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
                const CommonText('City / Home', fontSize: 16, fontWeight: FontWeight.bold),
                const CommonText('Nearby', fontSize: 14, color: AppColors.textSecondary),
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
              const CommonText('When', fontSize: 16, fontWeight: FontWeight.bold),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildDateInput('Start Date')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDateInput('End Date')),
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
                        Icon(Icons.chevron_left, color: AppColors.textSecondary.withOpacity(0.6)),
                        const CommonText('January 2026', fontSize: 15, fontWeight: FontWeight.bold),
                        Icon(Icons.chevron_right, color: AppColors.textSecondary.withOpacity(0.6)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Days Headers
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
                          .map((d) => CommonText(d, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary))
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
          boxShadow: isActive ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
            )
          ] : null,
        ),
        child: Center(
          child: CommonText(
            title,
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildLocationItem(String location, {bool isVenue = false, String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isVenue ? const Color(0xFFE8EAF6) : const Color(0xFFFFE4E6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isVenue ? Icons.location_city_rounded : Icons.near_me_rounded, 
              size: 18, 
              color: isVenue ? const Color(0xFF3F51B5) : const Color(0xFFE11D48)
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(location, fontSize: 15, fontWeight: FontWeight.w600),
                if (subtitle != null)
                  CommonText(subtitle, fontSize: 12, color: AppColors.textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String address) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.history_rounded, size: 22, color: AppColors.textSecondary),
          const SizedBox(width: 16),
          CommonText(address, fontSize: 15, color: AppColors.textPrimary),
        ],
      ),
    );
  }

  Widget _buildDateInput(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CommonText(hint, color: AppColors.textSecondary.withOpacity(0.6), fontSize: 14),
          const Icon(Icons.calendar_month_outlined, size: 18, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
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
      itemCount: 35, // Show some padding days
      itemBuilder: (context, index) {
        // Simple mock calendar logic for demonstration
        // Assuming January 2026 starts on a Thursday (index 3 for day 1)
        final day = index - 3; // Adjust index to start day 1 correctly

        if (day < 1 || day > 31) {
          // Days outside of January
          return Center(
            child: CommonText(
              day < 1 ? (31 + day).toString() : (day - 31).toString(), // Mock previous/next month days
              color: AppColors.textSecondary.withOpacity(0.3),
              fontSize: 14,
            ),
          );
        }

        final isStart = day == 10;
        final isEnd = day == 18;
        final inRange = day > 10 && day < 18;
        
        return Stack(
          alignment: Alignment.center,
          children: [
            if (inRange || isStart || isEnd)
              Container(
                margin: EdgeInsets.only(
                  left: isStart ? 20 : 0,
                  right: isEnd ? 20 : 0,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
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
                color: (isStart || isEnd) ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CommonText(
                  day.toString(),
                  color: (isStart || isEnd) ? Colors.white : AppColors.textPrimary,
                  fontWeight: (isStart || isEnd) ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            if (day == 1) // Special indicator for Jan 1st as seen in UI
              Positioned(
               bottom: 4,
               child: Container(
                 width: 4,
                 height: 4,
                 decoration: const BoxDecoration(color: AppColors.textSecondary, shape: BoxShape.circle),
               ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _onClearAll,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: CommonText('Clear all', color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _onSearchPressed,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_rounded, color: Colors.white, size: 22),
                    SizedBox(width: 8),
                    CommonText('Search', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
