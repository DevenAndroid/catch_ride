import 'package:flutter/material.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/features/trainer/bookings/bookings_screen.dart';
import 'package:catch_ride/view/trainer/inbox/inbox_screen.dart';
import 'package:catch_ride/features/trainer/menu/menu_screen.dart';
import 'package:catch_ride/view/vendor/availability/vendor_availability_screen.dart';
import 'package:catch_ride/view/vendor/profile/vendor_profile_screen.dart';

class VendorMainScreen extends StatefulWidget {
  const VendorMainScreen({super.key});

  @override
  State<VendorMainScreen> createState() => _VendorMainScreenState();
}

class _VendorMainScreenState extends State<VendorMainScreen> {
  int _currentIndex = 2; // Default to Availability

  final List<Widget> _screens = [
    const VendorProfileScreen(),
    const BookingsScreen(), // Reuse Trainer Bookings Screen
    const VendorAvailabilityScreen(),
    const InboxScreen(), // Reuse Inbox
    const MenuScreen(), // Reuse Menu
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        type: BottomNavigationBarType.fixed, // Ensure >3 items works
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.deepNavy,
        unselectedItemColor: AppColors.grey400,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            activeIcon: Icon(Icons.access_time_filled),
            label: 'Availability',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        ],
      ),
    );
  }
}
