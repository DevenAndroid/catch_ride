import 'package:flutter/material.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/view/vendor/profile/flows/profile_complete_braiding.dart';
import 'package:catch_ride/view/vendor/bookings/flows/braiding_booking_screens.dart';
import 'package:catch_ride/view/vendor/availability/flows/availability_braiding.dart';
import 'package:catch_ride/view/vendor/inbox/vendor_inbox_screen.dart';
import 'package:catch_ride/view/vendor/menu/flows/menu_braiding.dart';

class VendorMainBraidingScreen extends StatefulWidget {
  const VendorMainBraidingScreen({super.key});

  @override
  State<VendorMainBraidingScreen> createState() =>
      _VendorMainBraidingScreenState();
}

class _VendorMainBraidingScreenState extends State<VendorMainBraidingScreen> {
  // Braider lands on Availability on first login
  int _currentIndex = 2; // Default to Availability (Index 2)

  final List<Widget> _screens = [
    const ProfilePageBraiderScreen(), // 0. Profile tab
    const BookingListBraiderScreen(), // 1. Braider bookings
    const AvailabilityBraidingScreen(), // 2. Availability = Home
    const VendorInboxScreen(), // 3. Vendor inbox
    const MenuBraidingScreen(), // 4. Vendor-specific menu
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.deepNavy,
        unselectedItemColor: AppColors.grey400,
        showUnselectedLabels: true,
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
