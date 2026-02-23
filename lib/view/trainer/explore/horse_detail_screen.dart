import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';

class HorseDetailScreen extends StatelessWidget {
  final String? name;
  final String? breed;
  final String? height;
  final String? age;
  final String? price;
  final String? description;
  final String? location;
  final String? discipline;
  final String? listingType;
  final String? imageUrl;

  const HorseDetailScreen({
    super.key,
    this.name,
    this.breed,
    this.height,
    this.age,
    this.price,
    this.description,
    this.location,
    this.discipline,
    this.listingType,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(title: const Text('Horse Detail'), centerTitle: false),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trainer info
            ListTile(
              leading: const CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=150',
                ),
              ),
              title: Text('Arya Stark', style: AppTextStyles.titleMedium),
              subtitle: Text(
                'Professional Horse Trainer',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              trailing: const Icon(Icons.more_vert, color: AppColors.deepNavy),
            ),

            // Image
            Stack(
              children: [
                Image.network(
                  imageUrl ??
                      'https://images.unsplash.com/photo-1534008897995-27a23e859048?auto=format&fit=crop&q=80&w=1000',
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 250,
                      width: double.infinity,
                      color: AppColors.grey200,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 64,
                          color: AppColors.grey500,
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.deepNavy.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '1 / 12',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Action Row
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.share_outlined,
                    size: 24,
                    color: AppColors.deepNavy,
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.bookmark_border,
                    size: 24,
                    color: AppColors.deepNavy,
                  ),
                ],
              ),
            ),

            // Tags Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8,
                children: [
                  if (listingType != null && listingType!.isNotEmpty)
                    _buildFilterTag(listingType!),
                  if (listingType == null) _buildFilterTag('For sale'),
                  if (listingType == null) _buildFilterTag('Weekly Lease'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                name ?? 'Demo horse - Young Developing Hunter',
                style: AppTextStyles.headlineMedium,
              ),
            ),
            const SizedBox(height: 8),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                description ??
                    'An ideal small pony and great for a Child An ideal small pony and great for a ChildAn ideal small pony and great for a Child An ideal small pony and great for a Child.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Rating & Location
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Icon(Icons.star, color: AppColors.mutedGold, size: 16),
                  const SizedBox(width: 4),
                  Text('4.5', style: AppTextStyles.titleMedium),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.grey500,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    location ?? 'Ocklawaha, USA, United States',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // USEF Number block
            Container(
              width: double.infinity,
              color: AppColors.grey100,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Horse USEF number',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text('5w3bnd67', style: AppTextStyles.titleMedium),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Talk to Barn Manager Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildBarnManagerCard(),
            ),
            const SizedBox(height: 32),

            // Details section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Details', style: AppTextStyles.titleLarge),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.grey200),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Horse name', name ?? 'Thunderbolt'),
                    const SizedBox(height: 16),
                    _buildDetailRow('Age', age ?? '14 Years'),
                    const SizedBox(height: 16),
                    _buildDetailRow('Height', height ?? '16.2hh'),
                    const SizedBox(height: 16),
                    _buildDetailRow('Breed', breed ?? 'Thoroughbred'),
                    const SizedBox(height: 16),
                    _buildDetailRow('Color', 'Brown'),
                    const SizedBox(height: 16),
                    _buildDetailRow('Discipline', discipline ?? 'Hunter'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Availability Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Availability', style: AppTextStyles.titleLarge),
            ),
            const SizedBox(height: 16),

            // Availability locations
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildAvailabilityCard(
                    '1',
                    location ?? 'Ocklawaha, USA, United States',
                    '05 Feb - 10 Feb 2026',
                  ),
                  const SizedBox(height: 12),
                  _buildAvailabilityCard(
                    '2',
                    location ?? 'Ocklawaha, USA, United States',
                    '05 Feb - 10 Feb 2026',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Tags Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildInfoBox('Program Tag', 'Big Equitation'),
                  _buildInfoBox('Opportunity Tag', 'Firesale'),
                  _buildInfoBox('Experience', 'Division Pony'),
                  _buildInfoBox('Personality Tags', 'Brave / Bold'),
                ],
              ),
            ),

            // Extra padding at the bottom
            SizedBox(height: 100 + bottomPadding),
          ],
        ),
      ),
      bottomSheet: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.grey200)),
        ),
        child: CustomButton(
          text: 'Send booking request',
          onPressed: () {
            Get.snackbar('Booking', 'Booking request initiated');
          },
        ),
      ),
    );
  }

  Widget _buildFilterTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildBarnManagerCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.deepNavy.withOpacity(
          0.04,
        ), // Soft blue-grey background
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Talk to Barn Manager', style: AppTextStyles.labelLarge),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?auto=format&fit=crop&q=80&w=150',
                      ),
                    ),
                    Positioned(
                      bottom: -4,
                      left: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successGreen,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.surface,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '4.8',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Lisa James', style: AppTextStyles.titleMedium),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Ocklawaha, USA',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(text: 'Request Booking', onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(' :  ', style: AppTextStyles.titleMedium),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityCard(
    String locNum,
    String locText,
    String dateText,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.grey200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location $locNum',
            style: AppTextStyles.labelLarge.copyWith(color: AppColors.textHint),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(locText, style: AppTextStyles.bodyMedium),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(dateText, style: AppTextStyles.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String subtitle, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.grey200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            subtitle,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textHint,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: AppTextStyles.titleMedium.copyWith(fontSize: 13)),
        ],
      ),
    );
  }
}
