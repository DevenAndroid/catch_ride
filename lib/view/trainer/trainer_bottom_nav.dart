import 'package:catch_ride/controllers/horse_controller.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/view/trainer/bookings/trainer_bookings_view.dart';
import 'package:catch_ride/view/trainer/home/trainer_explore_view.dart';
import 'package:catch_ride/view/trainer/list/hourse_listing_view.dart';
import 'package:catch_ride/view/trainer/chats/chats_view.dart';
import 'package:catch_ride/view/trainer/settings/settings_view.dart';

class TrainerBottomNav extends StatefulWidget {
  final int initialIndex;

  const TrainerBottomNav({
    super.key,
    this.initialIndex = 0, // Default to Bookings (index 0)
  });

  @override
  State<TrainerBottomNav> createState() => _TrainerBottomNavState();
}

class _TrainerBottomNavState extends State<TrainerBottomNav> {
  late int _selectedIndex;

  // Views aligned with the UI order: Bookings, Explore, List, Inbox, Menu
  final List<Widget> _views = [
    const TrainerBookingsView(),
    const TrainerExploreView(),
    const HourseListingView(),
    const TrainerChatsView(),
    const SettingsView(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Get.put(ProfileController());
    Get.put(HorseController());
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true, // Content flows behind the nav bar
      body: Stack(
        children: [
          // Ensure views have enough bottom space
          Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: _views[_selectedIndex],
          ),
          
          // Floating Bottom Nav positioned precisely
          Positioned(
            left: 16,
            right: 16,
            bottom: 15, // Adjusted height
            child: SafeArea(
              top: false,
              bottom: true, // Respects the notch area
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(0, 'Bookings', Icons.calendar_month_rounded),
                      _buildNavItem(1, 'Explore', Icons.search_rounded),
                      _buildNavItem(2, 'List', Icons.add_rounded),
                      _buildNavItem(3, 'Inbox', Icons.chat_bubble_outline_rounded),
                      _buildNavItem(4, 'Profile', Icons.person_rounded),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: 26,
            ),
            const SizedBox(height: 4),
            CommonText(
              label,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
