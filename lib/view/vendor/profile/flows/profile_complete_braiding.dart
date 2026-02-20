// profile_page_braiding.dart — ProfilePageBraider

import 'package:flutter/material.dart';
import 'package:catch_ride/view/vendor/profile/flows/vendor_profile_base.dart';

class ProfilePageBraiderScreen extends StatelessWidget {
  final bool isOwnProfile;
  const ProfilePageBraiderScreen({super.key, this.isOwnProfile = true});

  @override
  Widget build(BuildContext context) {
    return VendorProfileBase(
      isOwnProfile: isOwnProfile,
      data: const VendorProfileData(
        name: 'Maria Santos',
        businessName: 'Santos Braiding Co.',
        initials: 'MS',
        tagline: 'Expert Braider • Hunter / Jumper Specialist',
        bio:
            '12 years braiding for top hunter/jumper barns along the A-circuit. '
            'Offering running braids, button braids, and French braids for any discipline. '
            'Known for clean, consistent braids that hold all show day. '
            'Available pre-dawn to ensure your horse is ring-ready.',
        serviceBadges: ['Running Braids', 'Button Braids', 'French Braids'],
        rates: [
          VendorServiceRate('Running Braids (Mane)', '\$45'),
          VendorServiceRate('Button Braids (Mane)', '\$65'),
          VendorServiceRate('Mane + Tail Package', '\$75'),
          VendorServiceRate('French Braid', '\$55'),
        ],
        operatingRegion: 'Wellington, FL • Ocala, FL • Devon, PA',
        isAcceptingBookings: true,
        rating: 4.9,
        reviewCount: 210,
        yearsExp: 12,
        jobsDone: 600,
        serviceIcon: Icons.auto_awesome_rounded,
      ),
    );
  }
}
