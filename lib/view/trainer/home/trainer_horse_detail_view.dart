import 'package:catch_ride/constant/app_strings.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';

import 'package:flutter/material.dart';
import 'package:catch_ride/utils/date_util.dart';
import 'package:catch_ride/view/trainer/home/search_filter_overlay.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_constants.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:catch_ride/models/horse_model.dart';
import 'package:intl/intl.dart';
import '../../../controllers/profile_controller.dart';
import '../../../controllers/booking_controller.dart';
import '../../../models/availability_model.dart';
import '../../../services/api_service.dart';
import '../settings/trainer_profile_view.dart';
import '../list/edit_horse_listing_view.dart';
import '../../barn_manager/barn_manager_availability_view.dart';
import '../../../controllers/horse_controller.dart';
import '../../../controllers/chat_controller.dart';

class TrainerHorseDetailView extends StatefulWidget {
  final HorseModel? horse;
  final String? horseId;
  final bool fromBooking;
  final bool isOwnHorse;
  final String? bookingId;
  final String? bookingStatus;
  final String? otherId;
  final String? otherName;
  final String? otherImage;
  final String? myTeamId;

  const TrainerHorseDetailView({
    super.key,
    this.horse,
    this.horseId,
    this.fromBooking = false,
    this.isOwnHorse = false,
    this.bookingId,
    this.bookingStatus,
    this.otherId,
    this.otherName,
    this.otherImage,
    this.myTeamId,
  });

  @override
  State<TrainerHorseDetailView> createState() => _TrainerHorseDetailViewState();
}

class _TrainerHorseDetailViewState extends State<TrainerHorseDetailView> {
  bool _isRequested = false;
  bool _canMessage = false;
  HorseModel? horse;
  String? _currentBookingStatus;

  // Image carousel state
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Video state
  YoutubePlayerController? _youtubeController;
  VideoPlayerController? _videoPlayerController;
  bool _isYoutube = false;
  bool _hasVideo = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.horse != null) {
      horse = widget.horse;
      _currentBookingStatus = widget.bookingStatus;
      _initVideo();
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkIfRequested());
    } else if (widget.horseId != null) {
      _currentBookingStatus = widget.bookingStatus;
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchHorseDetails());
    }
  }

  Future<void> _fetchHorseDetails() async {
    final id = horse?.id ?? widget.horseId;
    if (id == null) return;
    try {
      setState(() => _isLoading = true);
      final ApiService api = Get.put(ApiService());
      final response = await api.getRequest('/horses/$id');
      if (response.statusCode == 200) {
        final data = response.body['data'];
        if (data != null) {
          setState(() {
            horse = HorseModel.fromJson(data);
            _initVideo();
            _checkIfRequested();
          });
        }
      } else {
        Get.snackbar('Error', 'Failed to load horse details');
      }
    } catch (e) {
      debugPrint('Error fetching horse: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkIfRequested() async {
    final bookingController = Get.put(BookingController());
    final chatController = Get.put(ChatController());

    // Fetch latest sent bookings from server to sync with DB
    await bookingController.fetchBookings(type: 'sent');
    
    if (chatController.conversations.isEmpty) {
      await chatController.fetchConversations();
    }

    final existingBooking = bookingController.sentBookings.firstWhereOrNull(
      (b) => b.horseId == horse?.id && b.status.toLowerCase() == 'pending',
    );

    final hasAcceptedBooking = bookingController.sentBookings.any(
      (b) => b.trainerId == horse?.trainerId && 
             (b.status.toLowerCase() == 'accepted' || 
              b.status.toLowerCase() == 'confirmed' || 
              b.status.toLowerCase() == 'completed'),
    );

    final hasExistingChat = chatController.conversations.any(
      (c) => c.otherUser?.id == horse?.trainerId || 
             c.otherUser?.trainerId == horse?.trainerId,
    );

    setState(() {
      _isRequested = existingBooking != null;
      _canMessage = hasAcceptedBooking || hasExistingChat;
    });
  }

  void _initVideo() {
    final String? videoLink = horse!.videoLink;
    if (videoLink == null || videoLink.isEmpty || videoLink == 'N/A') {
      _hasVideo = false;
      return;
    }

    _hasVideo = true;
    final String? youtubeId = YoutubePlayer.convertUrlToId(videoLink);

    if (youtubeId != null) {
      _isYoutube = true;
      _youtubeController = YoutubePlayerController(
        initialVideoId: youtubeId,
        flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
      );
    } else {
      _isYoutube = false;
      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(videoLink))
            ..initialize().then((_) {
              setState(() {});
            });
    }
  }

  bool get isHorseOwner {
    final profileController = Get.find<ProfileController>();
    final horseTrainerId = horse?.trainerId;
    final profileTrainerId = profileController.trainerId;

    debugPrint('DEBUG: Horse Trainer ID: $horseTrainerId');
    debugPrint('DEBUG: Profile Trainer ID: $profileTrainerId');

    return horseTrainerId != null && horseTrainerId == profileTrainerId;
  }

  bool _isTrainerOwnHorse() => isHorseOwner;

  @override
  void dispose() {
    _pageController.dispose();
    _youtubeController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  void _confirmDelete() {
    Get.dialog(
      AlertDialog(
        title: const CommonText(
          'Delete Listing',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        content: CommonText(
          'Are you sure you want to delete ${horse?.name}? This action cannot be undone.',
          fontSize: 14,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const CommonText('Cancel', color: AppColors.textSecondary),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              final horseController = Get.put(HorseController());
              final success = await horseController.deleteHorse(horse!.id!);
              if (success) {
                Get.back(); // Go back from detail view
                Get.snackbar(
                  'Deleted',
                  'Horse listing has been removed',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              } else {
                Get.snackbar(
                  'Error',
                  'Failed to delete horse listing',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
              }
            },
            child: const CommonText(
              'Delete',
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions() {
    // This method is now replaced by _buildActionMenu
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (horse == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Details')),
        body: const Center(child: Text('Horse details not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0), // Hide default app bar
        child: AppBar(elevation: 0, backgroundColor: Colors.white),
      ),
      body: SafeArea(
        child: horse == null
            ? const Center(child: CircularProgressIndicator())
            : Builder(
                builder: (context) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildPremiumHeader(),
                              _buildTrainerSection(),
                              _buildDescriptionAndTags(),
                              _buildDetailsSection(),
                              _buildPricingSection(),
                              _buildAvailabilitySection(),
                              if (isHorseOwner && horse!.bookedByName != null)
                                _buildBookedByHeader(),
                            //  if (!isHorseOwner) _buildCancelationPolicy(),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                      if (!isHorseOwner || widget.fromBooking) _buildBottomAction(),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Stack(
      children: [
        _buildImageSection(),
        // Dark gradient overlay for text readability
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 110,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        // Header Controls
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCircleButton(Icons.arrow_back_ios_new, () => Get.back()),
              _buildActionMenu(),
            ],
          ),
        ),
        // Title & Badges Overlay
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: IgnorePointer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: CommonText(
                        '${horse!.name} - ${horse!.displayDiscipline}',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: horse!.isActive
                            ? const Color(0xFFECFDF3)
                            : const Color(0xFFFEF3F2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: CommonText(
                        horse!.isActive ? 'Active' : 'Inactive',
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: horse!.isActive
                            ? const Color(0xFF027A48)
                            : const Color(0xFFB42318),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: horse!.listingTypes
                        .asMap()
                        .entries
                        .map(
                          (entry) => Padding(
                            padding: EdgeInsets.only(
                              right: entry.key == horse!.listingTypes.length - 1
                                  ? 0
                                  : 6,
                            ),
                            child: _buildOverlayBadge(
                              entry.value,
                              const Color(0xFFFDE4E1),
                              const Color(0xFFE11D48),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: CommonText(
                        (horse!.location == null || horse!.location!.isEmpty)
                            ? 'N/A'
                            : horse!.location!,
                        fontSize: 11,
                        color: Colors.white,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: Colors.black),
      ),
    );
  }

  Widget _buildActionMenu() {
    final profile = Get.find<ProfileController>();
    final userRole = profile.user.value?.role;
    final bool isTrainerOwner = isHorseOwner && userRole == 'trainer';
    final bool isBarnManagerTeam = isHorseOwner && userRole == 'barn_manager';

    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.more_vert, size: 20, color: Colors.black),
      ),
      onSelected: (value) async {
        if (value == 'edit') {
          Get.to(() => EditHorseListingView(horse: horse!));
        } else if (value == 'availability') {
          await Get.to(
            () => BarnManagerAvailabilityView(horse: horse!),
          );
          _fetchHorseDetails();
        } else if (value == 'active') {
          final horseController = Get.put(HorseController());
          final success = await horseController.toggleHorseActive(
            horse!.id!,
            !horse!.isActive,
          );
          if (success) {
            setState(() {
              horse = horse!.copyWith(isActive: !horse!.isActive);
            });
            Get.snackbar(
              'Success',
              'Horse status updated successfully',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          }
        } else if (value == 'delete') {
          _confirmDelete();
        } else if (value == 'trainer') {
          if (horse?.trainerId == null) {
            Get.snackbar(
              'Error',
              'This trainer has been deleted.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return;
          }
          Get.to(() => TrainerProfileView(trainerId: horse?.trainerId));
        }
      },
      itemBuilder: (context) => [
        if (isTrainerOwner) ...[
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                const Icon(Icons.edit, size: 20),
                const SizedBox(width: 8),
                const CommonText('Edit listing', fontSize: 14),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'active',
            child: Row(
              children: [
                Icon(
                  horse!.isActive ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                  color: horse!.isActive ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                CommonText(
                  horse!.isActive ? 'Deactivate' : 'Activate',
                  fontSize: 14,
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                const Icon(Icons.delete, size: 20, color: Colors.red),
                const SizedBox(width: 8),
                const CommonText(
                  'Delete listing',
                  fontSize: 14,
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ],
        if (isBarnManagerTeam)
          PopupMenuItem(
            value: 'availability',
            child: Row(
              children: [
                const Icon(Icons.calendar_month_outlined, size: 20),
                const SizedBox(width: 8),
                const CommonText('Edit Availability', fontSize: 14),
              ],
            ),
          ),
        if (!isHorseOwner)
          PopupMenuItem(
            value: 'trainer',
            child: Row(
              children: [
                const Icon(Icons.person_outline, size: 20),
                const SizedBox(width: 8),
                const CommonText('Trainer Details', fontSize: 14),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildOverlayBadge(String text, Color bg, Color textC) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(
          0xFF8B4444,
        ), // Matched to mockup dark trans-red
        borderRadius: BorderRadius.circular(8),
      ),
      child: CommonText(
        text,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTrainerSection() {
    final profileController = Get.find<ProfileController>();
    final isOwnHorse = _isTrainerOwnHorse();

    // If it's the trainer's own horse, use their profile data as fallback
    final String? trainerAvatar =
        (isOwnHorse &&
            (horse!.trainerAvatar == null || horse!.trainerAvatar!.isEmpty))
        ? profileController.user.value?.displayAvatar
        : horse!.trainerAvatar;

    final String trainerName =
        (isOwnHorse &&
            (horse!.trainerName == null || horse!.trainerName == 'N/A'))
        ? profileController.fullName
        : (horse!.trainerName ?? 'N/A');

    final String? trainerLocation =
        (isOwnHorse && (horse!.location == null || horse!.location!.isEmpty))
        ? profileController.location
        : horse!.location;

    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Row(
        children: [
          CommonImageView(
            url: trainerAvatar,
            height: 48,
            width: 48,
            shape: BoxShape.circle,
            isUserImage: true,
          ),

          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if(horse?.trainerId == null){
          Get.snackbar(
          'Error', 'This trainer has been deleted.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          );
          return;}
                  Get.to(() => TrainerProfileView(trainerId: horse?.trainerId));},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    trainerName,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  CommonText(
                    trainerLocation != null && trainerLocation!.isNotEmpty
                        ? trainerLocation
                        : 'N/A',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (!isHorseOwner)
            ElevatedButton(
              onPressed: () {
                if (_canMessage) {
                  final chatController = Get.find<ChatController>();
                  chatController.openBookingChat(
                    bookingId: widget.bookingId ?? '',
                    otherId: widget.otherId ?? horse?.trainerId ?? '',
                    otherName: widget.otherName ?? horse?.trainerName ?? 'Trainer',
                    otherImage: widget.otherImage ?? horse?.trainerAvatar ?? '',
                    myTeamId: widget.myTeamId,
                  );
                } else {
                  Get.snackbar(
                    'Notice',
                    'Messaging is enabled once your booking request is accepted.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.errorPrimary,
                    colorText: Colors.white,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(width: 10),
                  Icon(Icons.chat_bubble_outline, size: 18),
                  SizedBox(width: 8),
                  CommonText(
                    'Message',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10),
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _buildDescriptionAndTags() {
    final description =
        (horse!.description == null || horse!.description!.isEmpty)
        ? ''
        : horse!.description!;

    final allTags = [
      if (horse!.height != null && horse!.height!.isNotEmpty) horse!.height!,
      ...horse!.disciplines,
      if (horse!.experienceLevel != null) horse!.experienceLevel!.name,
      ...horse!.programTags.map((t) => t.name),
      ...horse!.opportunityTags.map((t) => t.name),
      ...horse!.personalityTags.map((t) => t.name),
      ...horse!.tags.map((t) => t.name),
    ];

    if (description.isEmpty && allTags.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (description.isNotEmpty)
            CommonText(
              description,
              fontSize: 14,
              color: const Color(0xFF4B5563),
              height: 1.5,
            ),
          if (allTags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allTags.map((tag) => _buildBubbleTag(tag)).toList(),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBubbleTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF), // Light blue background
        borderRadius: BorderRadius.circular(20),
      ),
      child: CommonText(
        label,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1E40AF), // Dark blue text
      ),
    );
  }

  Widget _buildBookedByHeader() {
    final profileController = Get.find<ProfileController>();
    final currentUserId = profileController.id;
    final isBookedByMe = horse!.bookedById == currentUserId;

    final String? bAvatar =
        (isBookedByMe &&
            (horse!.bookedByAvatar == null || horse!.bookedByAvatar!.isEmpty))
        ? profileController.user.value?.displayAvatar
        : horse!.bookedByAvatar;

    final String bName =
        (isBookedByMe &&
            (horse!.bookedByName == null || horse!.bookedByName == 'N/A'))
        ? profileController.fullName
        : (horse!.bookedByName ?? '');

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(
                0xFFFFF7F5,
              ), // Light reddish background from design
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE4E1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CommonText(
                  'Booked by',
                  fontSize: AppTextSizes.size12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonImageView(
                      url: bAvatar,
                      height: 50,
                      width: 50,
                      shape: BoxShape.circle,
                      isUserImage: true,
                    ),

                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonText(
                            bName,
                            fontSize: AppTextSizes.size16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          const SizedBox(height: 4),
                          if (horse!.bookedByLocation != null ||
                              (isBookedByMe &&
                                  profileController.location.isNotEmpty))
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  color: AppColors.textSecondary,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: CommonText(
                                    isBookedByMe
                                        ? profileController.location
                                        : (horse!.bookedByLocation ?? 'N/A'),
                                    fontSize: AppTextSizes.size12,
                                    color: AppColors.textSecondary,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 4),
                          if (horse!.bookingDates != null)
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  color: AppColors.textSecondary,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                CommonText(
                                  DateUtil.formatRangeString(horse!.bookingDates),
                                  fontSize: AppTextSizes.size12,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const CommonText(
                        'For Sale',
                        fontSize: AppTextSizes.size12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CommonImageView(
                url: horse!.trainerAvatar,
                height: 44,
                width: 44,
                shape: BoxShape.circle,
                isUserImage: true,
              ),

              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: (){

                    if(horse?.trainerId == null){
                      Get.snackbar(
                        'Error', 'This trainer has been deleted.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;}
    Get.to(() => TrainerProfileView(trainerId: horse?.trainerId));
    }
            ,      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        horse!.trainerName ?? 'N/A',
                        fontSize: AppTextSizes.size16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      const CommonText(
                        AppStrings.professionalHorseTrainer,
                        fontSize: AppTextSizes.size14,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              const Icon(Icons.more_vert, color: AppColors.textPrimary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CommonImageView(
            url: horse!.trainerAvatar,
            height: 44,
            width: 44,
            shape: BoxShape.circle,
            isUserImage: true,
          ),

          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  horse!.trainerName ?? 'N/A',
                  fontSize: AppTextSizes.size14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                const CommonText(
                  AppStrings.professionalHorseTrainer,
                  fontSize: AppTextSizes.size12,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: AppColors.textPrimary),
        ],
      ),
    );
  }

  bool _isUrlVideo(String url) {
    if (url.isEmpty) return false;
    final lower = url.toLowerCase();
    final isYoutube =
        lower.contains('youtube.com') || lower.contains('youtu.be');
    return isYoutube ||
        lower.contains('horsevideos') ||
        lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.avi');
  }

  Widget _buildImageSection() {
    final List<String> allMedia = [
      if (horse!.images.isEmpty && horse!.photo != null) horse!.photo!,
      ...horse!.images,
      if (horse!.videoLink != null &&
          horse!.videoLink!.isNotEmpty &&
          horse!.videoLink != 'N/A' &&
          !horse!.images.contains(horse!.videoLink))
        horse!.videoLink!,
    ];

    final int totalItems = allMedia.length;

    if (totalItems == 0) {
      return const CommonImageView(
        url: null,
        height: 260,
        width: double.infinity,
      );
    }

    return Stack(
      children: [
        SizedBox(
          height: 260,
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: totalItems,
            itemBuilder: (context, index) {
              final String url = allMedia[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => _FullScreenMediaViewer(
                        mediaUrls: allMedia,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: _isUrlVideo(url)
                    ? _InlineVideoPlayer(
                        url: url,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => _FullScreenMediaViewer(
                                mediaUrls: allMedia,
                                initialIndex: index,
                              ),
                            ),
                          );
                        },
                      )
                    : CommonImageView(
                        url: url,
                        height: 260,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              );
            },
          ),
        ),
        if (totalItems > 1)
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: CommonText(
                '${_currentPage + 1} / $totalItems',
                color: Colors.white,
                fontSize: AppTextSizes.size12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  // Methods removed in favor of premium builder

  Widget _buildUsefNumberBanner() {
    final usef = horse!.usefNumber;
    if (usef == null || usef.toString().isEmpty || usef == 'N/A') {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      color: const Color(0xFFF3F4F6), // Light gray background
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CommonText(
            AppStrings.horseUsefNumber,
            fontSize: AppTextSizes.size14,
            color: AppColors.textSecondary,
          ),
          CommonText(
            usef.toString(),
            fontSize: AppTextSizes.size14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText(
            'Details',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                _buildDetailRow(
                  'Horse name',
                  horse!.name.isEmpty ? 'N/A' : horse!.name,
                  'USEF',
                  (horse!.usefNumber == null ||
                          horse!.usefNumber.toString().isEmpty)
                      ? 'N/A'
                      : horse!.usefNumber.toString(),
                  onLabelTap2: () async {
                    final Uri url =
                        Uri.parse('https://www.usef.org/search/horses');
                    if (!await launchUrl(url)) {
                      Get.snackbar('Error', 'Could not launch $url');
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  'Age',
                  horse!.age.toString().isEmpty ? 'N/A' : '${horse!.age} Years',
                  'Height',
                  (horse!.height == null || horse!.height!.isEmpty)
                      ? 'N/A'
                      : horse!.height!,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  'Breed',
                  horse!.breed.isEmpty ? 'N/A' : horse!.breed,
                  'Color',
                  (horse!.color == null || horse!.color!.isEmpty)
                      ? 'N/A'
                      : horse!.color!,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  'Discipline',
                  horse!.displayDiscipline.isEmpty
                      ? 'N/A'
                      : horse!.displayDiscipline,
                  '',
                  '',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumDetailItem(
    String label,
    String value, {
    VoidCallback? onLabelTap,
    bool showDivider = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(child: CommonText(label, fontSize: 13, color: AppColors.textSecondary)),
            if (onLabelTap != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onLabelTap,
                child: const Icon(
                  Icons.open_in_new_rounded,
                  size: 14,
                  color: Colors.blue,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        CommonText(value, fontSize: 15, fontWeight: FontWeight.bold),
        if (showDivider) ...[
          const SizedBox(height: 4),
          Container(height: 1, color: AppColors.border.withValues(alpha: 0.3)),
        ],
      ],
    );
  }

  Widget _buildPricingSection() {
    if (horse!.prices == null || horse!.prices!.isEmpty) {
      return const SizedBox.shrink();
    }

    final prices = horse!.prices!;
    // Filter to only include types where there's either inquire=true or min/max price
    final Map<String, dynamic> validPrices = {};
    for (var entry in prices.entries) {
      final data = entry.value;
      if (data is Map) {
        final bool inquire = data['inquire'] ?? false;
        final minPrice = data['min']?.toString() ?? '';
        final maxPrice = data['max']?.toString() ?? '';

        if (inquire || minPrice.isNotEmpty || maxPrice.isNotEmpty) {
          validPrices[entry.key] = data;
        }
      }
    }

    if (validPrices.isEmpty) return const SizedBox.shrink();

    // Mapping keys to friendly labels, keeping standard order if possible
    final displayOrder = [
      'Sale',
      'Weekly Lease',
      'Annual Lease',
      'Short Term or\nCircuit Lease',
    ];

    final List<MapEntry<String, dynamic>> sortedEntries = [];
    for (var type in displayOrder) {
      if (validPrices.containsKey(type)) {
        sortedEntries.add(MapEntry(type, validPrices[type]!));
      }
    }
    // Add any others not in expected order
    for (var entry in validPrices.entries) {
      if (!displayOrder.contains(entry.key)) {
        sortedEntries.add(entry);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const CommonText(
            'Pricing',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: sortedEntries.map((entry) {
                final type = entry.key;
                final data = entry.value;
                final bool inquire = data['inquire'] ?? false;
                final minPrice = data['min']?.toString() ?? '';
                final maxPrice = data['max']?.toString() ?? '';

                String labelStr = type;
                if (type == 'Sale') labelStr = 'For Sale';

                String formatPrice(String? p) {
                  if (p == null || p.isEmpty || p == 'null') return '';
                  try {
                    final double val =
                        double.parse(p.toString().replaceAll(',', ''));
                    return NumberFormat.decimalPattern().format(val);
                  } catch (e) {
                    return p;
                  }
                }

                final formattedMin = formatPrice(minPrice);
                final formattedMax = formatPrice(maxPrice);

                String valStr = '';
                if (inquire) {
                  valStr = 'Inquire';
                } else if (formattedMin.isNotEmpty &&
                    formattedMax.isNotEmpty) {
                  if (formattedMin == formattedMax) {
                    valStr = '\$ $formattedMin';
                  } else {
                    valStr = '\$ $formattedMin - \$ $formattedMax';
                  }
                } else if (formattedMin.isNotEmpty) {
                  valStr = '\$ $formattedMin';
                } else if (formattedMax.isNotEmpty) {
                  valStr = '\$ $formattedMax';
                } else {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildPremiumDetailItem(labelStr, valStr),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySection() {
    if (horse!.showAvailability.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText(
            'Availability',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: horse!.showAvailability.asMap().entries.map((entry) {
                final index = entry.key;
                final show = entry.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (index > 0) const SizedBox(height: 20),
                    _buildPremiumAvailabilityItem(
                      show.showVenue,
                      show.cityState,
                      DateUtil.formatRange(show.startDate, show.endDate),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumAvailabilityItem(
    String showVenue,
    String cityState,
    String dates,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          showVenue,
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CommonText(
                dates.trim() == '-' || dates.isEmpty ? 'N/A' : dates,
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CommonText(
                cityState.isEmpty ? 'N/A' : cityState,
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCancelationPolicy() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFDE4E1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFF04438),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 12, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const CommonText(
                'Cancelation Policy',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB42318),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const CommonText(
            'Cancellations must be made at least 24 hours in advance. Late cancellations may incur a fee or may not be eligible for a refund.',
            fontSize: 13,
            color: Color(0xFFB42318),
            height: 1.5,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: widget.fromBooking
          ? _buildBookingSpecificActions()
          : CommonButton(
              text:
                  _isRequested ? 'Your request is submitted' : 'Request a Trial',
              backgroundColor: _isRequested
                  ? Colors.grey
                  : const Color(0xFF00083B), // Navy blue
              textColor: Colors.white,
              onPressed: _isRequested ? null : () => _showBookingRequestBottomSheet(),
            ),
    );
  }

  Widget _buildBookingSpecificActions() {
    final status = (_currentBookingStatus ?? '').toLowerCase();
    final bool canCancel =
        status == 'pending' || status == 'confirmed' || status == 'accepted';

    return Row(
      children: [
        if (canCancel)
          Expanded(
            child: ElevatedButton(
              onPressed: () => _showCancelConfirmation(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const CommonText(
                'Cancel Booking',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        if (canCancel) const SizedBox(width: 12),
        if (canCancel && isHorseOwner)
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                final status = (_currentBookingStatus ?? '').toLowerCase();
                if (status == 'accepted' || status == 'confirmed') {
                  _showCompleteConfirmation();
                } else {
                  Get.snackbar(
                    'Attention',
                    'You can only complete bookings that have been accepted.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.errorPrimary,
                    colorText: Colors.white,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const CommonText(
                'Complete Booking',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
      ],
    );
  }

  void _showCompleteConfirmation() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.successPrimary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              const CommonText(
                'Complete Booking',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 12),
              const CommonText(
                'Are you sure you want to mark this booking as completed? This will move it to your past bookings.',
                fontSize: 14,
                textAlign: TextAlign.center,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const CommonText(
                        'No, Keep It',
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _handleCompleteBooking();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const CommonText(
                        'Yes, Complete',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCompleteBooking() async {
    if (widget.bookingId == null) return;

    final bookingController = Get.find<BookingController>();
    final success = await bookingController.updateBookingStatus(
      widget.bookingId!,
      'completed',
    );

    if (success != null) {
      Get.snackbar(
        'Booking Completed',
        'Your booking has been successfully marked as completed.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF17B26A),
        colorText: Colors.white,
      );
      setState(() {
        _currentBookingStatus = 'completed';
      });
      // Optionally refresh horse details or navigate back
    } else {
      Get.snackbar(
        'Action Failed',
        'Failed to complete booking. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void _showCancelConfirmation() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              const CommonText(
                'Cancel Booking',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 12),
              const CommonText(
                'Are you sure you want to cancel this booking? This action cannot be undone.',
                fontSize: 14,
                textAlign: TextAlign.center,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const CommonText(
                        'No, Keep It',
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _handleCancelBooking();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const CommonText(
                        'Yes, Cancel',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCancelBooking() async {
    if (widget.bookingId == null) return;

    final bookingController = Get.find<BookingController>();
    final success = await bookingController.updateBookingStatus(
      widget.bookingId!,
      'cancelled',
    );

    if (success) {
      Get.snackbar(
        'Booking Cancelled',
        'Your booking has been successfully cancelled.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
      setState(() {
        _currentBookingStatus = 'cancelled';
      });
    } else {
      Get.snackbar(
        'Action Failed',
        'Failed to cancel booking. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildTagsGridSection() {
    final programs = horse!.programTags;
    final opportunities = horse!.opportunityTags;
    final experience = horse!.experienceLevel;
    final personalities = horse!.personalityTags;

    final bool hasPrograms = programs.isNotEmpty;
    final bool hasOpportunities = opportunities.isNotEmpty;
    final bool hasExperience = experience != null;
    final bool hasPersonalities = personalities.isNotEmpty;

    if (!hasPrograms &&
        !hasOpportunities &&
        !hasExperience &&
        !hasPersonalities) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (hasPrograms || hasOpportunities)
          Row(
            children: [
              if (hasPrograms)
                Expanded(
                  child: _buildTagCard('Program Tag', programs.first.name),
                )
              else if (hasOpportunities)
                const Spacer(),

              if (hasPrograms && hasOpportunities) const SizedBox(width: 12),

              if (hasOpportunities)
                Expanded(
                  child: _buildTagCard(
                    'Opportunity Tag',
                    opportunities.first.name,
                  ),
                )
              else if (hasPrograms)
                const Spacer(),
            ],
          ),
        if ((hasPrograms || hasOpportunities) &&
            (hasExperience || hasPersonalities))
          const SizedBox(height: 12),
        if (hasExperience || hasPersonalities)
          Row(
            children: [
              if (hasExperience)
                Expanded(child: _buildTagCard('Experience', experience.name))
              else if (hasPersonalities)
                const Spacer(),

              if (hasExperience && hasPersonalities) const SizedBox(width: 12),

              if (hasPersonalities)
                Expanded(
                  child: _buildTagCard(
                    'Personality Tag',
                    personalities.first.name,
                  ),
                )
              else if (hasExperience)
                const Spacer(),
            ],
          ),
      ],
    );
  }

  Widget _buildTagCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            label,
            fontSize: AppTextSizes.size12,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 4),
          CommonText(
            value,
            fontSize: AppTextSizes.size14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }

  void _showBookingRequestBottomSheet() {
    DateTime? startDate;
    DateTime? endDate;
    String selectedType = 'Trial';
    String? selectedLocation = horse!.location;
    AvailabilityModel? selectedShow;
    final TextEditingController messageController = TextEditingController();
    final BookingController bookingController = Get.put(BookingController());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 12,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CommonText(
                    'Request a Trial',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: AppColors.textPrimary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Horse Card
              _buildBookingHorseCard(),
              const SizedBox(height: 20),

              // Single Date
              const CommonText(
                'Date',
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 8),
              _buildDateSelector(
                startDate != null
                    ? DateFormat('dd MMM yyyy').format(startDate!)
                    : 'Select Date',
                () async {
                  if (selectedLocation == null) {
                    Get.snackbar(
                      'Select Location',
                      'Please select a location first to see available dates.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                    );
                    return;
                  }

                  // Find a valid initial date that satisfies the predicate
                  DateTime now = DateTime.now();
                  DateTime today = DateTime(now.year, now.month, now.day);
                  DateTime initial = startDate ?? today;
                  DateTime first = today;

                  if (selectedLocation != horse!.location &&
                      selectedShow != null) {
                    final sDate = DateTime.tryParse(selectedShow!.startDate);
                    final eDate = DateTime.tryParse(selectedShow!.endDate);

                    if (sDate != null && eDate != null) {
                      final startOnly =
                          DateTime(sDate.year, sDate.month, sDate.day);
                      final endOnly =
                          DateTime(eDate.year, eDate.month, eDate.day);

                      // Safety check: If the show is entirely in the past, don't open picker
                      if (endOnly.isBefore(today)) {
                        Get.snackbar(
                          'Show Ended',
                          'This show has already ended. Please select a different location.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.orange,
                          colorText: Colors.white,
                        );
                        return;
                      }

                      if (initial.isBefore(startOnly)) {
                        initial = startOnly;
                      } else if (initial.isAfter(endOnly)) {
                        initial = startOnly;
                      }

                      // Ensure initial date is not before today
                      if (initial.isBefore(today)) {
                        initial = today;
                      }
                    }
                  }

                  final date = await showDatePicker(
                    context: context,
                    initialDate: initial,
                    firstDate: first,
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    selectableDayPredicate: (DateTime day) {
                      final dateOnly = DateTime(day.year, day.month, day.day);
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);

                      // Never allow past dates
                      if (dateOnly.isBefore(today)) return false;

                      if (selectedLocation == horse!.location) return true;
                      if (selectedShow == null) return false;

                      final sDate = DateTime.tryParse(selectedShow!.startDate);
                      final eDate = DateTime.tryParse(selectedShow!.endDate);
                      if (sDate != null && eDate != null) {
                        final startOnly =
                            DateTime(sDate.year, sDate.month, sDate.day);
                        final endOnly =
                            DateTime(eDate.year, eDate.month, eDate.day);

                        return (dateOnly.isAtSameMomentAs(startOnly) ||
                                dateOnly.isAfter(startOnly)) &&
                            (dateOnly.isAtSameMomentAs(endOnly) ||
                                dateOnly.isBefore(endOnly));
                      }

                      return false;
                    },
                  );
                  if (date != null) {
                    setSheetState(() {
                      startDate = date;
                      endDate = date; // For single date submission
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              // Location
              const CommonText(
                'Location',
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 4),
              const CommonText(
                'Note: Trials can be requested at horse shows or the horse\'s home location.',
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedLocation,
                    isExpanded: true,
                    itemHeight: null, // Allow custom height for Column
                    items: [
                      if (horse!.location != null &&
                          horse!.location!.isNotEmpty)
                        DropdownMenuItem(
                          value: horse!.location!,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CommonText(
                                  "${horse!.location!} (Home)",
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                                const CommonText(
                                  "Available at home",
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ...horse!.showAvailability.map((show) {
                        final dateRange = DateUtil.formatRange(
                            show.startDate, show.endDate);
                        final uniqueValue = show.id ?? "${show.cityState}_${show.startDate}";
                        return DropdownMenuItem(
                          value: uniqueValue,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CommonText(
                                  show.cityState,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                                CommonText(
                                  dateRange,
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                    hint: const CommonText(
                      'Select Location',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    onChanged: (val) {
                      setSheetState(() {
                        selectedLocation = val;
                        selectedShow = horse!.showAvailability.firstWhereOrNull(
                          (s) => (s.id ?? "${s.cityState}_${s.startDate}") == val,
                        );

                        // Reset date if it's invalid for the new location
                        if (startDate != null) {
                          if (val == horse!.location) {
                            // All dates valid for home, no reset needed
                          } else if (selectedShow != null) {
                            final sDate = DateTime.tryParse(selectedShow!.startDate);
                            final eDate = DateTime.tryParse(selectedShow!.endDate);
                            bool isValid = false;
                            if (sDate != null && eDate != null) {
                              final dateOnly = DateTime(startDate!.year, startDate!.month, startDate!.day);
                              final startOnly = DateTime(sDate.year, sDate.month, sDate.day);
                              final endOnly = DateTime(eDate.year, eDate.month, eDate.day);
                              
                              if ((dateOnly.isAtSameMomentAs(startOnly) || dateOnly.isAfter(startOnly)) &&
                                  (dateOnly.isAtSameMomentAs(endOnly) || dateOnly.isBefore(endOnly))) {
                                isValid = true;
                              }
                            }
                            if (!isValid) {
                              startDate = null;
                            }
                          }
                        }
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Message
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontFamily: 'Outfit',
                  ),
                  children: [
                    TextSpan(text: 'Message '),
                    TextSpan(
                      text: '(optional)',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 120,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: messageController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText:
                        'Please include your preferred time frame for the trial...',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Center(
                          child: CommonText(
                            'Cancel',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(
                      () => GestureDetector(
                        onTap: bookingController.isLoading.value
                            ? null
                            : () async {


                                if (startDate == null) {
                                  Get.snackbar(
                                    'Error',
                                    'Please select a date',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.redAccent,
                                    colorText: Colors.white,
                                    barBlur: 0,
                                    margin: const EdgeInsets.all(16),
                                  );
                                  return;
                                }

                                if (selectedLocation == null) {
                                  Get.snackbar(
                                    'Error',
                                    'Please select a location',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.redAccent,
                                    colorText: Colors.white,
                                    barBlur: 0,
                                    margin: const EdgeInsets.all(16),
                                  );
                                  return;
                                }

                                final success = await bookingController
                                    .createBooking({
                                      'horseId': horse!.id,
                                      'horseName': horse!.name,
                                      'trainerId': horse!.trainerId,
                                      'type': selectedType,
                                      'date': DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(startDate!),
                                      'location': selectedShow?.cityState ??
                                          horse!.location ??
                                          'N/A',
                                      'notes': messageController.text,
                                      'service': selectedType,
                                      'price': horse!.price ?? 0,
                                      'clientId': Get.find<ProfileController>()
                                          .user
                                          .value
                                          ?.id,
                                    });

                                if (success) {
                                  Get.back(); // Close bottom sheet
                                  Get.snackbar(
                                    'Success',
                                    'Booking request sent successfully',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: const Color(0xFF17B26A),
                                    colorText: Colors.white,
                                    barBlur: 0,
                                    margin: const EdgeInsets.all(16),
                                  );
                                  setState(() => _isRequested = true);
                                  _fetchHorseDetails(); // re-fetch to auto update based on requested state
                                }
                              },
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: bookingController.isLoading.value
                                ? AppColors.inputBackground
                                : AppColors.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: bookingController.isLoading.value
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const CommonText(
                                    'Submit',
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  ));
}

  Widget _buildBookingHorseCard() {
    final hasImages = horse != null && horse!.images.isNotEmpty;
    final photoUrl = horse?.photo ?? (hasImages ? horse!.images.first : '');

    // Extract dynamic venue and dates
    String venueText = 'Venue - N/A';
    String dateRangeText = 'N/A';
    if (horse != null && horse!.showAvailability.isNotEmpty) {
      final firstShow = horse!.showAvailability.first;
      if (firstShow.showVenue.isNotEmpty) {
        venueText = firstShow.showVenue;
      }
      final formattedDates = DateUtil.formatRange(firstShow.startDate, firstShow.endDate);
      if (formattedDates.isNotEmpty) {
        dateRangeText = formattedDates;
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CommonImageView(
                url: photoUrl,
                width: 75,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontFamily: 'Outfit',
                    ),
                    children: [
                      TextSpan(text: horse?.name.toString().capitalizeFirst ?? 'Unknown'),
                      TextSpan(
                        text:
                            ' - ${horse != null && horse!.displayDiscipline.isNotEmpty ? horse!.displayDiscipline : horse?.breed}',
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                CommonText(
                  venueText,
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: CommonText(
                        horse?.location ?? 'N/A',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: CommonText(
                        dateRangeText,
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: horse!.listingTypes
                        .asMap()
                        .entries
                        .map(
                          (entry) => Padding(
                            padding: EdgeInsets.only(
                              right: entry.key == horse!.listingTypes.length - 1
                                  ? 0
                                  : 8,
                            ),
                            child: _buildOverlayBadge(
                              entry.value,
                              const Color(0xFFFDE4E1),
                              const Color(0xFFE11D48),
                            ),
                          ),
                        ).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildDateSelector(String hint, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CommonText(hint, fontSize: 14, color: AppColors.textPrimary),
            const Icon(
              Icons.calendar_month_outlined,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label1, String val1, String label2, String val2,
      {VoidCallback? onLabelTap2}) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: _buildPremiumDetailItem(label1, val1, showDivider: false)),
            const SizedBox(width: 16),
            Expanded(
              child: label2.isEmpty
                  ? const SizedBox.shrink()
                  : _buildPremiumDetailItem(label2, val2,
                      onLabelTap: onLabelTap2, showDivider: false),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(height: 1, color: AppColors.border.withValues(alpha: 0.3)),
      ],
    );
  }
}

class _InlineVideoPlayer extends StatefulWidget {
  final String url;
  final VoidCallback? onTap;
  const _InlineVideoPlayer({required this.url, this.onTap});

  @override
  State<_InlineVideoPlayer> createState() => _InlineVideoPlayerState();
}

class _InlineVideoPlayerState extends State<_InlineVideoPlayer> with AutomaticKeepAliveClientMixin {
  VideoPlayerController? _controller;
  YoutubePlayerController? _youtubeController;
  bool _isYoutube = false;
  bool _initialized = false;
  bool _error = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final youtubeId = YoutubePlayer.convertUrlToId(widget.url);
    if (youtubeId != null) {
      _isYoutube = true;
      _youtubeController = YoutubePlayerController(
        initialVideoId: youtubeId,
        flags: const YoutubePlayerFlags(
          autoPlay: false, // Changed to false
          mute: false,
          hideControls: true,
          disableDragSeek: true,
        ),
      );
      _initialized = true;
    } else {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _initialized = true;
            });
          }
        }).catchError((e) {
          debugPrint('Error loading video: $e');
          if (mounted) {
            setState(() {
              _error = true;
            });
          }
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_error) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Icon(Icons.error_outline, color: Colors.white, size: 40),
        ),
      );
    }

    if (!_initialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        ),
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_isYoutube && _youtubeController != null)
              AbsorbPointer(
                child: YoutubePlayer(
                  controller: _youtubeController!,
                  showVideoProgressIndicator: false,
                ),
              )
            else if (_controller != null)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
              ),
            // Play Button Overlay
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullScreenMediaViewer extends StatefulWidget {
  final List<String> mediaUrls;
  final int initialIndex;

  const _FullScreenMediaViewer({
    required this.mediaUrls,
    required this.initialIndex,
  });

  @override
  State<_FullScreenMediaViewer> createState() => _FullScreenMediaViewerState();
}

class _FullScreenMediaViewerState extends State<_FullScreenMediaViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _isUrlVideo(String url) {
    if (url.isEmpty) return false;
    final lower = url.toLowerCase();
    final isYoutube =
        lower.contains('youtube.com') || lower.contains('youtu.be');
    return isYoutube ||
        lower.contains('horsevideos') ||
        lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.avi');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.mediaUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final url = widget.mediaUrls[index];
              if (_isUrlVideo(url)) {
                return _VideoPlayerWidget(url: url);
              } else {
                return Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: CommonImageView(
                      url: url,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                );
              }
            },
          ),
          // Close Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  final String url;
  const _VideoPlayerWidget({required this.url});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> with AutomaticKeepAliveClientMixin {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  YoutubePlayerController? _youtubeController;
  bool _isYoutube = false;
  bool _initialized = false;
  bool _error = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  void _initPlayer() {
    final youtubeId = YoutubePlayer.convertUrlToId(widget.url);
    if (youtubeId != null) {
      _isYoutube = true;
      _youtubeController = YoutubePlayerController(
        initialVideoId: youtubeId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
        ),
      );
      _initialized = true;
    } else {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      _videoPlayerController!.initialize().then((_) {
        if (mounted) {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController!,
            autoPlay: true,
            looping: false,
            aspectRatio: _videoPlayerController!.value.aspectRatio,
            showControls: true,
            materialProgressColors: ChewieProgressColors(
              playedColor: AppColors.primary,
              handleColor: AppColors.primary,
              backgroundColor: Colors.grey,
              bufferedColor: Colors.white.withOpacity(0.5),
            ),
            placeholder: Container(color: Colors.black),
            autoInitialize: true,
          );
          setState(() {
            _initialized = true;
          });
        }
      }).catchError((e) {
        debugPrint('Error initializing video: $e');
        if (mounted) {
          setState(() {
            _error = true;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_error) {
      return const Center(
        child: Icon(Icons.error_outline, color: Colors.white, size: 40),
      );
    }

    if (!_initialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_isYoutube && _youtubeController != null) {
      return Center(
        child: YoutubePlayer(
          controller: _youtubeController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: AppColors.primary,
        ),
      );
    }

    if (_chewieController != null) {
      return Center(
        child: Chewie(controller: _chewieController!),
      );
    }

    return const Center(
      child: CircularProgressIndicator(color: Colors.white),
    );
  }
}
