import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/view/vendor/groom/profile/payment_methods.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GroomViewProfile extends StatefulWidget {
  const GroomViewProfile({super.key});

  @override
  State<GroomViewProfile> createState() => _GroomViewProfileState();
}

class _GroomViewProfileState extends State<GroomViewProfile> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _showMoreDetails = false.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildBio(),
                  const SizedBox(height: 16),
                  _buildSocials(),
                  const SizedBox(height: 16),
                  _buildPaymentMethods(),
                  const SizedBox(height: 24),
                  _buildTabs(),
                  const SizedBox(height: 20),
                  _buildDetailsCard(),
                  const SizedBox(height: 24),
                  _buildPhotosSection(),
                  const SizedBox(height: 24),
                  _buildAvailabilitySection(),
                  const SizedBox(height: 24),
                  _buildCancellationPolicy(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              height: 220,
              width: double.infinity,
              child: const CommonImageView(
                url: 'https://images.unsplash.com/photo-1553284965-83fd3e82fa5a?q=80&w=2071&auto=format&fit=crop',
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 40,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                onPressed: () => Get.back(),
              ),
            ),
            Positioned(
              top: 50,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle),
                child: const Icon(Icons.more_vert, color: Colors.black, size: 20),
              ),
            ),
            Positioned(
              bottom: -45,
              left: 20,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=thomas'),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 135, top: 4, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CommonText('Thomas Martin', fontSize: AppTextSizes.size24, fontWeight: FontWeight.bold),
              const SizedBox(height: 1),
              const CommonText('Westbridge Equestrian', fontSize: AppTextSizes.size14, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              const SizedBox(height: 4),
              Row(
                children: const [
                  Icon(Icons.location_on, color: Color(0xFFE11D48), size: 14),
                  SizedBox(width: 4),
                  CommonText('Denver, Colorado, USA', fontSize: AppTextSizes.size14, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ],
              ),
              const SizedBox(height: 4),
              const CommonText('Grooming  •  10+ Years', fontSize: AppTextSizes.size14, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBio() {
    return const Padding(
      padding: EdgeInsets.only(top: 10),
      child: CommonText(
        'Experienced A/AA circuit groom with a strong background in the hunter/jumper industry. I\'ve worked with high-volume show barns across major circuits including Wellington, Ocala, Tryon, and the Northeast, managing daily care for multiple horses in a fast-paced, high-standard environment.',
        fontSize: AppTextSizes.size14,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
    );
  }

  Widget _buildSocials() {
    return Row(
      children: [
        _buildSocialButton('Instagram', Icons.camera_alt_outlined, AppColors.accentRedLight),
        const SizedBox(width: 12),
        _buildSocialButton('Facebook', Icons.facebook, AppColors.linkBlue),
      ],
    );
  }

  Widget _buildSocialButton(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          CommonText(label, fontSize: AppTextSizes.size14, color: color, fontWeight: FontWeight.w600),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return GestureDetector(
      onTap: () => Get.to(() => const PaymentMethods()),
      child: Row(
        children: [
          Image.network('https://cdn-icons-png.flaticon.com/512/174/174883.png', width: 24, height: 24),
          const SizedBox(width: 8),
          Image.network('https://cdn-icons-png.flaticon.com/512/5968/5968397.png', width: 24, height: 24),
          const SizedBox(width: 8),
          const CommonText('View all payment methods', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
          const Icon(Icons.chevron_right, size: 16, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.textPrimary,
          indicatorWeight: 3,
          tabs: const [
            Tab(child: CommonText('Grooming', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold)),
          ],
        ),
        const Divider(height: 1, thickness: 1),
      ],
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Services & Rates', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRateItem('\$ 4k', 'Day Rate'),
              _buildRateItem('\$ 12k', 'Week Rate (6d)'),
              _buildRateItem('\$ 30k', 'Month Rate'),
            ],
          ),
          const SizedBox(height: 20),
          _buildCheckItem('Tacking & Untacking'),
          _buildCheckItem('Wrapping & Bandaging'),
          _buildCheckItem('Stall Upkeep & Daily Care'),
          const SizedBox(height: 20),
          const CommonText('Additional Services', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
          const SizedBox(height: 16),
          _buildAdditionalService('Hunter Braiding Mane', '\$ 12k / horse'),
          _buildAdditionalService('Jumper Braiding', '\$ 12k / horse'),
          const SizedBox(height: 16),
          const SizedBox(height: 16),
          Obx(() {
            if (_showMoreDetails.value) {
              return Column(
                children: [
                  const Divider(height: 32),
                  _buildTwoColumnDetails(
                    'Location', 'Denver, Colorado, USA.',
                    'Years of Experience', '10+ Years',
                  ),
                  const SizedBox(height: 20),
                  _buildTwoColumnDetails(
                    'Disciplines', 'Dressage, Eventing',
                    'Typical Level of Horses', 'Local Only, Regional',
                  ),
                  const SizedBox(height: 20),
                  _buildSingleColumnDetail('Show & Barn Support', 'Fill-In Daily Grooming Support'),
                  const SizedBox(height: 20),
                  _buildTwoColumnDetails(
                    'Horse Handling', 'Lunging, Flat Riding',
                    'Additional Skills', 'Braiding',
                  ),
                  const SizedBox(height: 20),
                  _buildSingleColumnDetail('Travel Preferences', 'Local Only, Regional'),
                  const SizedBox(height: 20),
                  _buildSingleColumnDetail('Operating Regions', 'Ocala, Tryon, Lexington, Mid- Atlantic (VA/MD/PA)'),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => _showMoreDetails.value = false,
                    child: const CommonText('View Less', color: AppColors.linkBlue, fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
                  ),
                ],
              );
            }
            return GestureDetector(
              onTap: () => _showMoreDetails.value = true,
              child: const CommonText('View More', color: AppColors.linkBlue, fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTwoColumnDetails(String label1, String value1, String label2, String value2) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildDetailItem(label1, value1)),
        const SizedBox(width: 20),
        Expanded(child: _buildDetailItem(label2, value2)),
      ],
    );
  }

  Widget _buildSingleColumnDetail(String label, String value) {
    return _buildDetailItem(label, value);
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
        const SizedBox(height: 6),
        CommonText(value, fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        const Divider(height: 24),
      ],
    );
  }

  Widget _buildRateItem(String price, String label) {
    return Column(
      children: [
        CommonText(price, fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold, color: AppColors.secondary),
        CommonText(label, fontSize: AppTextSizes.size10, color: AppColors.textSecondary),
      ],
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          CommonText(text, fontSize: AppTextSizes.size14, color: AppColors.textPrimary),
        ],
      ),
    );
  }

  Widget _buildAdditionalService(String name, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(child: CommonText(name, fontSize: AppTextSizes.size14, color: AppColors.textPrimary)),
          CommonText(price, fontSize: AppTextSizes.size14, color: AppColors.secondary, fontWeight: FontWeight.bold),
        ],
      ),
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText('Photos', fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildPhotoItem('https://images.unsplash.com/photo-1553284965-83fd3e82fa5a?q=80&w=200'),
            _buildPhotoItem('https://images.unsplash.com/photo-1598974357801-cbca100e65d3?q=80&w=200'),
            _buildPhotoItem('https://images.unsplash.com/photo-1534073737927-85f1ebff1f5d?q=80&w=200'),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoItem(String url) {
    return Container(
      width: Get.width * 0.28,
      height: 100,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: CommonImageView(url: url, fit: BoxFit.cover),
    );
  }

  Widget _buildAvailabilitySection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            CommonText('Upcoming Availability', fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
            Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
        const SizedBox(height: 16),
        _buildAvailabilityCard(
          dates: 'Mar 10 - Mar 18, 2026',
          location: 'Wellington, WEC Ocala',
          tags: ['Show Week Support', 'Fill In/ Daily Show Support'],
          maxHorses: 'Max 5 Horses',
          maxDays: 'Max 8 Days',
          note: 'Prefer mornings. Experience with warmbloods.',
        ),
        const SizedBox(height: 12),
        _buildAvailabilityCard(
          dates: 'Mar 10 - Mar 18, 2026',
          location: 'Wellington, WEC Ocala',
          tags: ['Show Week Support', 'Fill In/ Daily Show Support', 'Hunter Braiding Mane'],
          maxHorses: 'Max 5 Horses',
          maxDays: 'Max 8 Days',
          note: 'Prefer mornings. Experience with warmbloods.',
          showMore: true,
        ),
      ],
    );
  }

  Widget _buildAvailabilityCard({
    required String dates,
    required String location,
    required List<String> tags,
    required String maxHorses,
    required String maxDays,
    required String note,
    bool showMore = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.secondary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(dates, color: Colors.white, fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        CommonText(location, color: Colors.white70, fontSize: AppTextSizes.size12),
                      ],
                    ),
                  ],
                ),
                if (showMore) const Icon(Icons.more_vert, color: Colors.white),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags.map((t) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
                    child: CommonText(t, fontSize: AppTextSizes.size12, color: AppColors.textPrimary),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.catching_pokemon, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    CommonText(maxHorses, fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
                    const SizedBox(width: 20),
                    const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    CommonText(maxDays, fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.description_outlined, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(child: CommonText(note, fontSize: AppTextSizes.size12, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancellationPolicy() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: Column(
        children: [
          Row(
            children: const [
              Icon(Icons.cancel_outlined, color: Colors.red, size: 20),
              SizedBox(width: 8),
              CommonText('Cancelation Policy', color: Colors.red, fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
            ],
          ),
          const SizedBox(height: 12),
          const CommonText(
            'Cancellations must be made at least 24 hours in advance. Late cancellations may incur a fee or may not be eligible for a refund.',
            fontSize: AppTextSizes.size12,
            color: Color(0xFF8B4444),
            height: 1.4,
          ),
        ],
      ),
    );
  }
}
