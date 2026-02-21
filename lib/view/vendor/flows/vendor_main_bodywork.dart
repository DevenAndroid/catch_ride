import 'package:flutter/material.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/view/vendor/profile/flows/profile_complete_bodywork.dart';
import 'package:catch_ride/view/vendor/bookings/vendor_bookings_screen.dart';
import 'package:catch_ride/view/vendor/availability/flows/availability_bodywork.dart';
import 'package:catch_ride/view/vendor/inbox/vendor_inbox_screen.dart';
import 'package:catch_ride/view/vendor/menu/flows/vendor_menu_bodywork.dart';

class VendorMainBodyworkScreen extends StatefulWidget {
  const VendorMainBodyworkScreen({super.key});

  @override
  State<VendorMainBodyworkScreen> createState() =>
      _VendorMainBodyworkScreenState();
}

class _VendorMainBodyworkScreenState extends State<VendorMainBodyworkScreen> {
  int _currentIndex = 2; // Default to Availability (home)

  final List<Widget> _screens = [
    const ProfilePageBodyworkScreen(), // Profile tab
    const VendorBookingsScreen(), // Vendor bookings (Accept/Decline)
    const AvailabilityBodyworkScreen(), // Availability = Home
    const VendorInboxScreen(), // Vendor inbox
    const VendorMenuBodyworkScreen(), // Vendor-specific menu
  ];

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
