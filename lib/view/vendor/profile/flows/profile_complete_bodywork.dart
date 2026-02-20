// profile_page_bodywork.dart — ProfilePageBodywork

import 'package:flutter/material.dart';
import 'package:catch_ride/view/vendor/profile/flows/vendor_profile_base.dart';

class ProfilePageBodyworkScreen extends StatelessWidget {
  final bool isOwnProfile;
  const ProfilePageBodyworkScreen({super.key, this.isOwnProfile = true});

  @override
  Widget build(BuildContext context) {
    return VendorProfileBase(
      isOwnProfile: isOwnProfile,
      data: const VendorProfileData(
        name: 'Dr. Lisa Holt',
        businessName: 'Holt Equine Bodywork',
        initials: 'LH',
        tagline: 'Certified Equine Bodyworker • Massage & Chiropractic',
        bio:
            'Certified equine massage therapist and chiropractic practitioner with 9 years of experience. '
            'Providing therapeutic massage, chiropractic adjustments, and acupuncture for performance horses. '
            'Works closely with veterinarians and trainers to support recovery, maintenance, and peak performance. '
            'Currently serving the Wellington and Ocala circuits.',
        serviceBadges: ['Massage', 'Chiropractic', 'Acupuncture'],
        rates: [
          VendorServiceRate('Full Body Massage (60 min)', '\$175'),
          VendorServiceRate('Chiropractic Session', '\$200'),
          VendorServiceRate('Acupuncture', '\$185'),
          VendorServiceRate('Combo Session (90 min)', '\$280'),
        ],
        operatingRegion: 'Wellington, FL • Ocala, FL • By appointment',
        isAcceptingBookings: true,
        rating: 5.0,
        reviewCount: 63,
        yearsExp: 9,
        jobsDone: 280,
        serviceIcon: Icons.spa_rounded,
      ),
    );
  }
}
