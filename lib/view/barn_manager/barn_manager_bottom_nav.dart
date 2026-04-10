import 'package:catch_ride/controllers/barn_manager/barn_manager_booking_controller.dart';
import 'package:catch_ride/controllers/horse_controller.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/view/barn_manager/bookings/barn_manager_bookings_view.dart';
import 'package:catch_ride/view/barn_manager/settings/barn_manager_settings_view.dart';
import 'package:catch_ride/view/barn_manager/home/barn_manager_explore_view.dart';
import 'package:catch_ride/view/barn_manager/list/barn_manager_horse_listing_view.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'chats/barn_manager_chat_list_view.dart';

class BarnManagerBottomNav extends StatefulWidget {
  final int initialIndex;

  const BarnManagerBottomNav({
    super.key,
    this.initialIndex = 0, // Default to Bookings (index 0)
  });

  @override
  State<BarnManagerBottomNav> createState() => _BarnManagerBottomNavState();
}

class _BarnManagerBottomNavState extends State<BarnManagerBottomNav> {
  late int _selectedIndex;

  // Tabs: Bookings, Explore, List, Inbox, Profile
  final List<Widget> _views = [
    const BarnManagerBookingsView(),
    const BarnManagerExploreView(),
    const BarnManagerHorseListingView(),
    const BarnManagerInboxView(),
    const BarnManagerSettingsView(),
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
    Get.put(BarnManagerBookingController());

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: false, // Content flows behind the nav bar
      body: Stack(
        children: [
          // Ensure views have enough bottom space
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: _views[_selectedIndex],
          ),

          // Floating Bottom Nav
          // Positioned(
          //   left: 16,
          //   right: 16,
          //   bottom: 15,
          //   child: SafeArea(
          //     top: false,
          //     bottom: true,
          //     child: Container(
          //       decoration: BoxDecoration(
          //         color: Colors.white,
          //         borderRadius: BorderRadius.circular(32),
          //         boxShadow: [
          //           BoxShadow(
          //             color: Colors.black.withOpacity(0.12),
          //             blurRadius: 20,
          //             offset: const Offset(0, 8),
          //           ),
          //         ],
          //       ),
          //       child: Padding(
          //         padding: const EdgeInsets.symmetric(
          //           horizontal: 4,
          //           vertical: 4,
          //         ),
          //         child: Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceAround,
          //           children: [
          //             _buildNavItem(
          //               0,
          //               'Bookings',
          //               Icons.calendar_month_rounded,
          //             ),
          //             _buildNavItem(1, 'Explore', Icons.search_rounded),
          //             _buildNavItem(2, 'List', Icons.add_rounded),
          //             _buildNavItem(
          //               3,
          //               'Inbox',
          //               Icons.chat_bubble_outline_rounded,
          //             ),
          //             _buildNavItem(4, 'Profile', Icons.person_rounded),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, 'Bookings', LucideIcons.calendarDays),
              _buildNavItem(1, 'Explore', Icons.search_rounded),
              _buildNavItem(2, 'List', Icons.add_rounded),
              _buildNavItem(3, 'Inbox', LucideIcons.messageCircleMore),
              _buildNavItem(4, 'Profile', Icons.person_outline_sharp),
            ],
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
