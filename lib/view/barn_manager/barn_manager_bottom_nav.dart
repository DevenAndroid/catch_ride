import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/view/trainer/bookings/trainer_bookings_view.dart';
import 'package:catch_ride/view/trainer/home/trainer_explore_view.dart';
import 'package:catch_ride/view/trainer/list/hourse_listing_view.dart';
import 'package:catch_ride/view/trainer/chats/chats_view.dart';

import 'home/barn_manager_home_view.dart';

class BarnManagerBottomNav extends StatefulWidget {
  final int initialIndex;

  const BarnManagerBottomNav({super.key, this.initialIndex = 0});

  @override
  State<BarnManagerBottomNav> createState() => _BarnManagerBottomNavState();
}

class _BarnManagerBottomNavState extends State<BarnManagerBottomNav> {
  late int _selectedIndex;

  final List<Widget> _views = [
    const BarnManagerHomeView(),
    const TrainerExploreView(), // Placeholder for explore
    const HourseListingView(), // Placeholder for listing
    const TrainerBookingsView(), // Placeholder for bookings
    const TrainerChatsView(), // Placeholder for inbox
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
                _buildNavItem(0, 'Home', Icons.home_outlined),
                _buildNavItem(1, 'Explore', Icons.search),
                _buildNavItem(2, 'Listing', Icons.article_outlined),
                _buildNavItem(3, 'Bookings', Icons.calendar_today_outlined),
                _buildNavItem(4, 'Inbox', Icons.chat_bubble_outline),
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
