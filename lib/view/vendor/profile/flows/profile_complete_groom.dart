// profile_page_groom.dart — ProfilePageGroom

import 'package:flutter/material.dart';
import 'package:catch_ride/view/vendor/profile/flows/vendor_profile_base.dart';

class ProfilePageGroomScreen extends StatelessWidget {
  final bool isOwnProfile;
  const ProfilePageGroomScreen({super.key, this.isOwnProfile = true});

  @override
  Widget build(BuildContext context) {
    return VendorProfileBase(
      isOwnProfile: isOwnProfile,
      data: const VendorProfileData(
        name: 'John Smith',
        businessName: 'Smith Elite Grooming',
        initials: 'JS',
        tagline: 'Professional Groom • Full Service Show Grooming',
        bio:
            'Over 8 years of experience grooming for top Grand Prix jumpers and hunters. '
            'Available for full show days, specialized braiding, and personalized show prep. '
            'Based in Wellington, FL with service across South Florida and East Coast circuits. '
            'Trustworthy, punctual, and dedicated to your horse\'s best performance.',
        serviceBadges: ['Grooming', 'Show Prep', 'Braiding'],
        rates: [
          VendorServiceRate('Full Day Grooming', '\$200 / day'),
          VendorServiceRate('Half Day / Show Prep', '\$120'),
          VendorServiceRate('Travel Day (no show)', '\$80'),
        ],
        operatingRegion: 'Wellington, FL • Ocala, FL • East Coast Circuits',
        isAcceptingBookings: true,
        rating: 4.8,
        reviewCount: 124,
        yearsExp: 8,
        jobsDone: 350,
        serviceIcon: Icons.cleaning_services_rounded,
      ),
    );
  }
}
