import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/models/horse_model.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/profile_controller.dart';
import '../../trainer/home/trainer_horse_detail_view.dart';
import '../../trainer/settings/view_all_horses_view.dart';
import 'edit_profile.dart';

class BarnManagerProfileView extends StatefulWidget {
  const BarnManagerProfileView({super.key});

  @override
  State<BarnManagerProfileView> createState() => _BarnManagerProfileViewState();
}

class _BarnManagerProfileViewState extends State<BarnManagerProfileView> {
  final ProfileController _controller = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        final profile = _controller.user.value;

        if (_controller.isLoading.value && profile == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (profile == null) {
          return const Center(child: CommonText('Profile not found'));
        }

        final hasBio = _controller.bio.isNotEmpty;

        return RefreshIndicator(
          onRefresh: () async {
            await _controller.fetchProfile();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                      child: CommonImageView(
                        url: _controller.coverImage.isNotEmpty
                            ? _controller.coverImage
                            : 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                    // Back Button
                    Positioned(
                      top: 50,
                      left: 16,
                      child: GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chevron_left,
                            size: 24,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 50,
                      right: 16,
                      child: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            Get.to(() => const EditBarnManagerProfileView());
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        icon: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.more_vert,
                            size: 24,
                            color: Colors.black,
                          ),
                        ),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit_outlined,
                                  size: 20,
                                  color: AppColors.textPrimary,
                                ),
                                SizedBox(width: 12),
                                CommonText(
                                  'Edit Profile',
                                  fontWeight: FontWeight.bold,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Profile Image Overlap
                    Positioned(
                      bottom: -65,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 15,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: CommonImageView(
                          url: _controller.avatar,
                          height: 110,
                          width: 110,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Profile Identity Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 125),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CommonText(
                                  _controller.fullName.isEmpty
                                      ? 'N/A'
                                      : _controller.fullName,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                                const SizedBox(height: 4),
                                CommonText(
                                  _controller.barnName.isEmpty
                                      ? 'N/A'
                                      : _controller.barnName,
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Colors.redAccent,
                                    ),
                                    const SizedBox(width: 4),
                                    CommonText(
                                      _controller.location.isEmpty
                                          ? 'N/A'
                                          : _controller.location,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                    if (profile.location2?.isNotEmpty ??
                                        false) ...[
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6.0,
                                        ),
                                        child: CommonText(
                                          "|",
                                          color: Colors.grey,
                                        ),
                                      ),
                                      CommonText(
                                        profile.location2!,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    CommonText(
                                      'Barn Manager',
                                      fontSize: 15,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    if (_controller
                                        .yearsInIndustry
                                        .isNotEmpty) ...[
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6.0,
                                        ),
                                        child: CommonText(
                                          "·",
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      CommonText(
                                        '${_controller.yearsInIndustry}+ Years',
                                        fontSize: 15,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      if (hasBio) ...[
                        const SizedBox(height: 24),
                        CommonText(
                          _controller.bio,
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Associate Trainer Section
                      if (profile.linkedTrainer != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF00083B,
                            ), // Dark navy blue from mockup
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CommonText(
                                'Associate Trainer',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    CommonImageView(
                                      url: profile.linkedTrainer!.avatar ?? '',
                                      height: 75,
                                      width: 75,
                                      shape: BoxShape.circle,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CommonText(
                                            profile.linkedTrainer!.fullName,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF101828),
                                          ),
                                          const SizedBox(height: 4),
                                          CommonText(
                                            profile.linkedTrainer!.barnName ??
                                                'No Barn Specified',
                                            fontSize: 15,
                                            color: const Color(0xFF667085),
                                            fontWeight: FontWeight.w500,
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.location_on_outlined,
                                                size: 18,
                                                color: Color(0xFF2E90FA),
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: CommonText(
                                                  profile
                                                          .linkedTrainer!
                                                          .location ??
                                                      "No Location Specified",
                                                  fontSize: 13,
                                                  color: const Color(
                                                    0xFF2E90FA,
                                                  ),
                                                  fontWeight: FontWeight.w500,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      _buildProfessionalInfoCard(),

                      const SizedBox(height: 24),

                      Obx(() {
                        final horses = _controller.trainerHorses;
                        if (horses.isEmpty) return const SizedBox.shrink();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const CommonText(
                                  'Available Horses',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Get.to(() => const ViewAllHorsesView()),
                                  child: const CommonText(
                                    'View all',
                                    color: AppColors.linkBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...horses
                                .map((horse) => _buildHorseCard(horse))
                                .toList(),
                          ],
                        );
                      }),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfessionalInfoCard() {
    final tags = _controller.groupedTrainerTags;
    final horseShows = _controller.selectedHorseShows;

    final Map<String, List<String>> filteredTags = Map.from(tags)
      ..remove('Discipline')
      ..remove('Disciplines');

    if (filteredTags.isEmpty && horseShows.isEmpty)
      return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...filteredTags.entries.map((entry) {
            final isLast =
                filteredTags.keys.last == entry.key && horseShows.isEmpty;
            return _buildInfoRow(entry.key, entry.value.join(" · "), !isLast);
          }).toList(),
          if (horseShows.isNotEmpty)
            _buildInfoRow(
              'Horse Shows & Circuits Frequented',
              horseShows.join(" · "),
              false,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String content, bool showDivider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(
                title,
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: 6),
              CommonText(
                content,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            color: AppColors.borderLight.withValues(alpha: 0.5),
            height: 1,
          ),
      ],
    );
  }

  Widget _buildHorseCard(HorseModel horse) {
    return GestureDetector(
      onTap: () => Get.to(() => TrainerHorseDetailView(horse: horse)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.borderLight.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CommonImageView(
                url: horse.photo ?? horse.images.firstOrNull,
                height: 90,
                width: 90,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    horse.name,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(height: 2),
                  CommonText(
                    "${horse.age}-year-old ${horse.breed}",
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 6),
                  CommonText(
                    horse.description ?? '',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    height: 1.3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
