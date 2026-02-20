// profile_page_farrier.dart — ProfilePageFarrier

import 'package:flutter/material.dart';
import 'package:catch_ride/view/vendor/profile/flows/vendor_profile_base.dart';

class ProfilePageFarrierScreen extends StatelessWidget {
  final bool isOwnProfile;
  const ProfilePageFarrierScreen({super.key, this.isOwnProfile = true});

  @override
  Widget build(BuildContext context) {
    return VendorProfileBase(
      isOwnProfile: isOwnProfile,
      data: const VendorProfileData(
        name: 'Tom Rivera',
        businessName: 'Rivera Farrier Services',
        initials: 'TR',
        tagline: 'AFA Certified Farrier • Corrective & Performance Shoeing',
        bio:
            'AFA Certified Journeyman Farrier with 15 years of experience in sport horse shoeing. '
            'Specializing in corrective shoeing, performance resets, and working alongside veterinarians '
            'on complex cases. Serving jumpers, dressage, and eventing horses across the Florida circuit. '
            'Fully insured with tools on truck — same-day emergency availability.',
        serviceBadges: ['Show Shoeing', 'Corrective', 'Performance Reset'],
        rates: [
          VendorServiceRate('Full Reset (4 shoes)', '\$175'),
          VendorServiceRate('Trim Only', '\$65'),
          VendorServiceRate('Front Shoes Only', '\$110'),
          VendorServiceRate('Corrective / Specialty', 'From \$225'),
        ],
        operatingRegion:
            'Wellington, FL • Ocala, FL • Emergency coverage available',
        isAcceptingBookings: true,
        rating: 4.9,
        reviewCount: 156,
        yearsExp: 15,
        jobsDone: 800,
        serviceIcon: Icons.handyman_rounded,
      ),
    );
  }
}
