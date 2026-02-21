import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/view/vendor/profile/flows/profile_setup_shipping.dart';
import 'package:catch_ride/view/vendor/shipping/flows/list_load_shipping.dart';
import 'package:catch_ride/view/vendor/availability/flows/availability_shipping.dart';

class ProfilePageShippingScreen extends StatefulWidget {
  final bool isOwnProfile;
  const ProfilePageShippingScreen({super.key, this.isOwnProfile = true});

  @override
  State<ProfilePageShippingScreen> createState() =>
      _ProfilePageShippingScreenState();
}

class _ProfilePageShippingScreenState extends State<ProfilePageShippingScreen> {
  bool _showDotNumber = false;
  bool _showPhoneOnProfile = true;
  bool _showLoads = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.isOwnProfile
              ? 'My Professional Profile'
              : 'Shipping Professional',
        ),
        centerTitle: true,
        actions: [
          if (widget.isOwnProfile)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Get.to(() => const ProfileSetupShippingScreen()),
              tooltip: 'Edit Profile',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderA(),
            _buildAboutB(),
            _buildCapabilitiesC(),
            _buildVerificationD(),
            _buildOperationsSummaryE(),
            _buildLoadListingsF(),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  // --- Section A: Header ---
  Widget _buildHeaderA() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        border: Border(bottom: BorderSide(color: AppColors.grey200)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.deepNavy,
                child: const Text(
                  'BC',
                  style: TextStyle(
                    color: AppColors.mutedGold,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cole Equine Transport LLC',
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.grey500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Ocala, FL',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                    if (_showPhoneOnProfile)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.phone_outlined,
                              size: 14,
                              color: AppColors.deepNavy,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '(352) 555-0123',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.deepNavy,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (!widget.isOwnProfile)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        Get.snackbar('Messages', 'Opening secure chat...'),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Message'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.deepNavy,
                      side: const BorderSide(color: AppColors.deepNavy),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        Get.snackbar('Booking', 'Processing request...'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.deepNavy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Request Booking'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // --- Section B: About ---
  Widget _buildAboutB() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ABOUT',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.grey500,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'DOT-licensed horse transporter with 11 years of experience shipping sport horses across the East Coast. '
            'Safety is our top priority. We use climate-controlled 6-horse air-ride trailers and provide hay, water, and 24/7 monitoring. '
            'Regular routes include Wellington, Ocala, Tryon, and Lexington.',
            style: AppTextStyles.bodyMedium.copyWith(
              height: 1.6,
              color: AppColors.grey800,
            ),
          ),
        ],
      ),
    );
  }

  // --- Section C: Capabilities ---
  Widget _buildCapabilitiesC() {
    final capabilities = [
      'Long-distance transport',
      'Climate-controlled equipment',
      'GPS tracking',
      'Team drivers',
    ];
    if (capabilities.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CAPABILITIES',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.grey500,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: capabilities
                .map(
                  (cap) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      cap,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey700,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // --- Section D: Verification ---
  Widget _buildVerificationD() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.successGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.successGreen.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _verificationBadge('USDOT Registered', true),
          TextButton(
            onPressed: () => setState(() => _showDotNumber = !_showDotNumber),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              _showDotNumber ? 'Hide DOT #' : 'View DOT #',
              style: const TextStyle(
                fontSize: 12,
                decoration: TextDecoration.underline,
                color: AppColors.grey600,
              ),
            ),
          ),
          if (_showDotNumber)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Text(
                'DOT-3942051',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 12),
          _verificationBadge('Commercial Insurance on File', true),
        ],
      ),
    );
  }

  Widget _verificationBadge(String label, bool isVerified) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: AppColors.successGreen, size: 16),
        const SizedBox(width: 10),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.deepNavy,
          ),
        ),
      ],
    );
  }

  // --- Section E: Operations Summary ---
  Widget _buildOperationsSummaryE() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OPERATIONS SUMMARY',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.grey500,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _readOnlyRow('Service Regions', 'Regional (Southeast) · Nationwide'),
          _readOnlyRow('Rig Types', '6-Horse Air Ride Gooseneck · Box Truck'),
          _readOnlyRow('Operation Type', 'Established shipping company'),
          _readOnlyRow('Years Experience', '11+ years'),
          _readOnlyRow('Capacity Range', 'Typical load: 4–12 horses'),
          const Divider(height: 32),
          _editableRow(
            'Equipment Details',
            'Climate-controlled available as needed',
          ),
          _editableRow('Pricing', 'Starts at \$3.50/mile (full load)'),
          _editableRow('Cancellation', 'Flexible (Full refund 72hr+ notice)'),
          _editableRow('Payment Methods', 'Zelle, Credit Card, ACH Transfer'),
        ],
      ),
    );
  }

  Widget _readOnlyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.grey600,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(child: Text(value, style: AppTextStyles.bodySmall)),
        ],
      ),
    );
  }

  Widget _editableRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(
              fontSize: 12,
              color: AppColors.deepNavy,
            ),
          ),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  // --- Section F: Load Listings ---
  Widget _buildLoadListingsF() {
    if (!_showLoads) {
      if (!widget.isOwnProfile) return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ACTIVE / UPCOMING LOADS',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.grey500,
                  letterSpacing: 1.2,
                ),
              ),
              if (widget.isOwnProfile)
                Switch(
                  value: _showLoads,
                  onChanged: (v) => setState(() => _showLoads = v),
                  activeColor: AppColors.deepNavy,
                ),
              if (!widget.isOwnProfile && _showLoads)
                TextButton(
                  onPressed: () => Get.to(() => const ListLoadShippingScreen()),
                  child: const Text('View All'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_showLoads) ...[
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 2,
              itemBuilder: (context, index) => _mockLoadCard(index),
            ),
          ),
        ],
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'AVAILABILITY CALENDAR',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.grey500,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grey200),
          ),
          child: Stack(
            children: [
              const Center(
                child: Text(
                  'Availability Map / Calendar View',
                  style: TextStyle(color: AppColors.grey400),
                ),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      Get.to(() => const AvailabilityShippingScreen()),
                  icon: const Icon(Icons.calendar_month, size: 16),
                  label: const Text('Full View'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepNavy,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mockLoadCard(int index) {
    return Container(
      width: 250,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'OPEN',
                  style: TextStyle(
                    color: AppColors.successGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                'Mar 12',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            index == 0 ? 'Wellington → Tryon' : 'Ocala → Lexington',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '4 slots available',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Inquire',
              onPressed: () =>
                  Get.snackbar('Load Inquiry', 'Messaging shipper...'),
            ),
          ),
        ],
      ),
    );
  }
}
