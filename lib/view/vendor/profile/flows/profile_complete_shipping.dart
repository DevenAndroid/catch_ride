// profile_page_shipping.dart — ProfilePageShipping

import 'package:flutter/material.dart';
import 'package:catch_ride/view/vendor/profile/flows/vendor_profile_base.dart';

class ProfilePageShippingScreen extends StatelessWidget {
  final bool isOwnProfile;
  const ProfilePageShippingScreen({super.key, this.isOwnProfile = true});

  @override
  Widget build(BuildContext context) {
    return VendorProfileBase(
      isOwnProfile: isOwnProfile,
      data: const VendorProfileData(
        name: 'Brett Cole',
        businessName: 'Cole Equine Transport',
        initials: 'BC',
        tagline: 'Licensed Horse Shipper • A-Circuit Specialist',
        bio:
            'DOT-licensed horse transporter with 11 years of experience shipping sport horses '
            'across the East Coast A-circuit. Climate-controlled 6-horse trailer with padding, '
            'hay nets, and full insurance coverage on every trip. '
            'Specializing in Wellington ↔ Ocala, Devon, and Traverse City routes. '
            'Experienced with nervous shippers and layovers.',
        serviceBadges: ['One Way', 'Round Trip', 'Show Circuit'],
        rates: [
          VendorServiceRate('Wellington → Ocala (one way)', '\$650'),
          VendorServiceRate('Wellington → Devon (one way)', '\$2,200'),
          VendorServiceRate('Round Trip (FL)', '\$1,100'),
          VendorServiceRate('Show Circuit Package', 'Quote'),
        ],
        operatingRegion: 'FL • PA • OH • VA • East Coast A-Circuit',
        isAcceptingBookings: true,
        rating: 4.8,
        reviewCount: 98,
        yearsExp: 11,
        jobsDone: 450,
        serviceIcon: Icons.local_shipping_rounded,
      ),
    );
  }
}
