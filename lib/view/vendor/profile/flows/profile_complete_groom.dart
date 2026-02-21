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
        operatingRegion: 'East Coast Circuits · Florida State · South Carolina',
        homeBase: 'Wellington, FL, USA',
        isAcceptingBookings: true,
        rating: 4.8,
        reviewCount: 124,
        yearsExp: 8,
        jobsDone: 350,
        availabilityBlocks: [
          'Feb 10 – Feb 24: Wellington + WEC Ocala',
          'Mar 1 – Mar 15: HITS Ocala + Aiken',
          'Apr 1 – Apr 30: Lexington (Show Week Support)',
        ],
        serviceIcon: Icons.cleaning_services_rounded,
        coverPhotoUrl:
            'https://images.unsplash.com/photo-1553284965-83fd3e82fa5a?auto=format&fit=crop&q=80&w=1200',
        cancellationPolicy:
            'Full refund if cancelled at least 48 hours before scheduled service. 50% charge for cancellations within 24 hours.',
        paymentMethods: ['In-App Payment', 'Zelle', 'Cash', 'Venmo'],
        travelPreferences:
            'Will travel up to 500 miles for show blocks. Air travel required for international circuits.',
        disciplines: ['Hunter', 'Jumper', 'Equitation', 'Dressage'],
        horseLevels: ['Grand Prix', 'FEI', 'A-Circuit', 'Junior/Amateur'],
      ),
    );
  }
}
