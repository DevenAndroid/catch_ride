// profile_page_clipping.dart — ProfilePageClipping

import 'package:flutter/material.dart';
import 'package:catch_ride/view/vendor/profile/flows/vendor_profile_base.dart';

class ProfilePageClippingScreen extends StatelessWidget {
  final bool isOwnProfile;
  const ProfilePageClippingScreen({super.key, this.isOwnProfile = true});

  @override
  Widget build(BuildContext context) {
    return VendorProfileBase(
      isOwnProfile: isOwnProfile,
      data: const VendorProfileData(
        name: 'Jake Torres',
        businessName: 'Precision Clip Co.',
        initials: 'JT',
        tagline: 'Professional Clipper • All Disciplines',
        bio:
            '10 years of experience clipping hunters, jumpers, and dressage horses. '
            'Specializing in full body clips, trace clips, and hunter clips for pre-show prep. '
            'Patient with nervous horses and committed to a clean, smooth finish every time. '
            'Based in Wellington with regular trips to Ocala and Devon.',
        serviceBadges: ['Full Body', 'Trace Clip', 'Hunter Clip'],
        rates: [
          VendorServiceRate('Full Body Clip', '\$150'),
          VendorServiceRate('Trace or Hunter Clip', '\$100'),
          VendorServiceRate('Face & Bridle Path Only', '\$40'),
          VendorServiceRate('Legs & Coronet Band', '\$35'),
        ],
        operatingRegion: 'Wellington, FL • Ocala, FL • Devon, PA',
        isAcceptingBookings: true,
        rating: 4.7,
        reviewCount: 89,
        yearsExp: 10,
        jobsDone: 420,
        serviceIcon: Icons.content_cut_rounded,
      ),
    );
  }
}
