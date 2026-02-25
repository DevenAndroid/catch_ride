import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';

import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/view/trainer/bookings/trainer_bookings_view.dart';
import 'package:catch_ride/view/trainer/home/trainer_explore_view.dart';
import 'package:catch_ride/view/trainer/list/hourse_listing_view.dart';
import 'package:catch_ride/view/trainer/chats/chats_view.dart';

import 'vendors/vendors_view.dart';

class TrainerBottomNav extends StatefulWidget {
  final int initialIndex;

  const TrainerBottomNav({
    super.key,
    this.initialIndex = 0,
  }); // Defaults to Explore (index 0)

  @override
  State<TrainerBottomNav> createState() => _TrainerBottomNavState();
}

class _TrainerBottomNavState extends State<TrainerBottomNav> {
  late int _selectedIndex;

  // Placeholder views for other tabs
  final List<Widget> _views = [
    const TrainerExploreView(),
    const TrainerBookingsView(),
    const HourseListingView(),
    const TrainerChatsView(),
    const VendorsView(),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _views[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(0, 'Explore', Icons.home_outlined),
                _buildNavItem(1, 'Bookings', Icons.calendar_today_outlined),
                _buildNavItem(2, 'List', Icons.add_circle_outline),
                _buildNavItem(3, 'Inbox', Icons.chat_bubble_outline),
                _buildNavItem(4, 'Vendors', Icons.people_outline),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              size: 24,
            ),
            const SizedBox(height: 4),
            CommonText(
              label,
              fontSize: AppTextSizes.size12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
