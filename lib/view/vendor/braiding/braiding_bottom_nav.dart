import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/view/vendor/braiding/booking/booking_view.dart';
import 'package:catch_ride/view/vendor/braiding/availability/availability_view.dart';
import 'package:catch_ride/view/vendor/braiding/chat/braiding_chat_view.dart';
import 'package:catch_ride/view/vendor/braiding/menu/menu_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';

import 'profile/braiding_view_profile.dart';

class BraidingBottomNav extends StatefulWidget {
  final int initialIndex;
  const BraidingBottomNav({super.key, this.initialIndex = 0});

  @override
  State<BraidingBottomNav> createState() => _BraidingBottomNavState();
}

class _BraidingBottomNavState extends State<BraidingBottomNav> {
  late int _selectedIndex;

  final List<Widget> _views = [
    const BraidingViewProfile(),
    const BookingView(),
    const AvailabilityView(),
    const BraidingChatView(),
    const MenuView(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _views[_selectedIndex],
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
              _buildNavItem(0, 'Profile', Icons.person, isAvatar: true),
              _buildNavItem(1, 'Booking', Icons.calendar_today_outlined),
              _buildNavItem(2, 'Availability', Icons.access_time),
              _buildNavItem(3, 'Inbox', Icons.chat_bubble_outline),
              _buildNavItem(4, 'Menu', Icons.menu),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon, {bool isAvatar = false}) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isAvatar)
               Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage('https://i.pravatar.cc/150?u=braiding'),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Icon(
                icon,
                size: 24,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            const SizedBox(height: 4),
            CommonText(
              label,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
