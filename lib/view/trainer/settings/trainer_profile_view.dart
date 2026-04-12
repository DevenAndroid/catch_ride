import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/models/horse_model.dart';
import 'package:catch_ride/view/trainer/home/trainer_horse_detail_view.dart';
import 'package:catch_ride/view/trainer/settings/view_all_horses_view.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/profile_controller.dart';
import '../../../models/user_model.dart';
import '../../../utils/url_helper.dart';
import '../trainer_complete_profile_view.dart';
import 'edit_profile.dart';

class TrainerProfileView extends StatefulWidget {
  final String? trainerId;
  const TrainerProfileView({super.key, this.trainerId});

  @override
  State<TrainerProfileView> createState() => _TrainerProfileViewState();
}

class _TrainerProfileViewState extends State<TrainerProfileView> {
  final ProfileController _controller = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bool isTrainer = _controller.user.value?.role == 'trainer';
      final bool isSameId =
          widget.trainerId == _controller.user.value?.trainerProfileId;

      if (widget.trainerId != null && (!isTrainer || !isSameId)) {
        _controller.fetchPublicTrainerProfile(widget.trainerId!);
      } else {
        // Viewing own profile or no ID provided (which defaults to own profile)
        _controller.viewedUser.value = null;
        _controller.viewedUserHorses.clear();
        _controller.fetchProfile();
      }
    });
  }

  @override
  void dispose() {
    // Clear viewed user when leaving this screen to prevent state leakage
    // only if we were actually viewing someone else
    if (widget.trainerId != null &&
        widget.trainerId != _controller.user.value?.trainerProfileId) {
      _controller.viewedUser.value = null;
      _controller.viewedUserHorses.clear();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        final bool isViewingOther =
            widget.trainerId != null &&
            widget.trainerId != _controller.user.value?.trainerProfileId;
        final profile = isViewingOther
            ? _controller.viewedUser.value
            : _controller.user.value;

        if (_controller.isLoading.value ||
            (isViewingOther && profile == null)) {
          return const Center(child: CircularProgressIndicator());
        }

        if (profile == null) {
          return const Center(child: CommonText('Profile not found'));
        }

        final hasInstagram = profile.instagram?.isNotEmpty ?? false;
        final hasFacebook = profile.facebook?.isNotEmpty ?? false;
        final hasWebsite = profile.website?.isNotEmpty ?? false;
        final hasSocials = hasInstagram || hasFacebook || hasWebsite;
        final hasBio = _controller.bio.isNotEmpty;
        final isOwnProfile =
            widget.trainerId == null ||
            (widget.trainerId == _controller.user.value?.trainerProfileId &&
                _controller.user.value?.role == 'trainer');

        return RefreshIndicator(
          onRefresh: () async {
            if (widget.trainerId != null) {
              await _controller.fetchPublicTrainerProfile(widget.trainerId!);
            } else {
              await _controller.fetchProfile();
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                          child: CommonImageView(
                            url: profile.coverImage,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),

                        // Header Buttons (Back and More/Edit)
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 10,
                          left: 16,
                          right: 16,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Back Button
                              GestureDetector(
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

                              // More Menu Button
                              if (isOwnProfile)
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                     Get.to(() => const EditProfileView());
                                    }
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Container(
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
                            ],
                          ),
                        ),

                        // Profile Image Overlap
                        Positioned(
                          bottom: -75,
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
                              url: profile.displayAvatar,
                              height: 90,
                              width: 90,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 130),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonText(
                                _controller.fullName.isEmpty
                                    ? 'N/A'
                                    : profile.fullName,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF101828),
                              ),
                              const SizedBox(height: 2),
                              CommonText(
                                profile.barnName ?? 'N/A',
                                fontSize: 16,
                                color: const Color(0xFF475467),
                                fontWeight: FontWeight.w600,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Color(0xFFF04438),
                                  ),
                                  const SizedBox(width: 4),
                                  CommonText(
                                    profile.location?.isEmpty ?? true
                                        ? 'N/A'
                                        : profile.location!,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF475467),
                                  ),
                                  if (profile.location2?.isNotEmpty ??
                                      false) ...[
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6.0,
                                      ),
                                      child: CommonText(
                                        "|",
                                        color: Color(0xFFD0D5DD),
                                      ),
                                    ),
                                    CommonText(
                                      profile.location2!,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF475467),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  if (_controller.disciplines.isNotEmpty) ...[
                                    CommonText(
                                      _controller.disciplines.join(" / ") +
                                          (" Trainer"),
                                      fontSize: 14,
                                      color: const Color(0xFF667085),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ],

                                  if (_controller
                                      .yearsExperience
                                      .isNotEmpty &&
                                      _controller.yearsExperience != '0')
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6.0,
                                      ),
                                      child: CommonText(
                                        "·",
                                        color: Color(0xFFD0D5DD),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  if (_controller
                                      .yearsExperience
                                      .isNotEmpty &&
                                      _controller.yearsExperience != '0')
                                    CommonText(
                                      _controller.yearsExperience.contains(
                                        '+',
                                      )
                                          ? '${_controller.yearsExperience} Experience'
                                          : '${_controller.yearsExperience} Years',
                                      fontSize: 14,
                                      color: const Color(0xFF667085),
                                      fontWeight: FontWeight.w500,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 14),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                       if (hasBio) ...[
                         const SizedBox(height: 24),
                         CommonText(
                           profile.bio ?? '',
                           fontSize: 14,
                           color: const Color(0xFF344054),
                           height: 1.6,
                         ),
                       ],

                       if (hasSocials) ...[
                         const SizedBox(height: 24),
                         SingleChildScrollView(
                           scrollDirection: Axis.horizontal,
                           child: Row(
                             children: [
                               if (hasInstagram)
                                 _buildSocialButton(
                                   'Instagram',
                                   Icons.camera_alt_outlined,
                                   const Color(0xFFD62976),
                                       () {
                                     UrlHelper.launchInstagram(
                                       profile.instagram!,
                                     );
                                   },
                                 ),
                               if (hasFacebook) ...[
                                 if (hasInstagram) const SizedBox(width: 10),
                                 _buildSocialButton(
                                   'Facebook',
                                   Icons.facebook,
                                   const Color(0xFF1877F2),
                                       () {
                                     UrlHelper.launchFacebook(profile.facebook!);
                                   },
                                 ),
                               ],
                               if (hasWebsite) ...[
                                 if (hasInstagram || hasFacebook)
                                   const SizedBox(width: 10),
                                 _buildSocialButton(
                                   'Website',
                                   Icons.link,
                                   Colors.black87,
                                       () {
                                     UrlHelper.launchWebsite(profile.website!);
                                   },
                                 ),
                               ],
                             ],
                           ),
                         ),
                         const SizedBox(height: 22),
                       ],
                     ],),
                   )

                  ],
                ),
              ),



                const SizedBox(height: 16),

                // Profile Identity Section (Name & Info)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [



                      _buildProfessionalInfoCard(profile),

                      const SizedBox(height: 24),

                      Obx(() {
                        final horses = widget.trainerId != null
                            ? _controller.viewedUserHorses
                            : _controller.trainerHorses;
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
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF101828),
                                ),
                                if (isOwnProfile)
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

  String _normalizeHorseShow(String text) {
    if (text.isEmpty) return text;
    if (text.contains(' • ')) {
      final parts = text.split(' • ');
      final circuit = parts.last.trim();
      final venue = parts.first.trim();
      
      // Prioritize Circuit (last part) if it's not a placeholder
      if (circuit.isNotEmpty && circuit != "-") return circuit;
      return venue;
    }
    return text;
  }

  Widget _buildProfessionalInfoCard(UserModel profile) {
    final tags = _controller.getGroupedTags(profile);
    final horseShows = profile.showCircuits.map((e) => _normalizeHorseShow(e)).toList();

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
                color: const Color(0xFF667085),
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: 6),
              CommonText(
                content,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF101828),
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

  Widget _buildSocialButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            CommonText(
              label,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color == Colors.black87 ? AppColors.textPrimary : color,
            ),
          ],
        ),
      ),
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
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF101828),
                  ),
                  const SizedBox(height: 2),
                  CommonText(
                    "${horse.age}-year-old ${horse.breed}",
                    fontSize: 13,
                    color: const Color(0xFF475467),
                    fontWeight: FontWeight.w400,
                  ),
                  const SizedBox(height: 6),
                  CommonText(
                    horse.description ?? '',
                    fontSize: 13,
                    color: const Color(0xFF667085),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    height: 1.4,
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
