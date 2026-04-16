import 'dart:io';

import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/add_new_listing_controller.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../utils/date_util.dart';

class ListingPreviewView extends StatefulWidget {
  final String? controllerTag;
  const ListingPreviewView({super.key, this.controllerTag});

  @override
  State<ListingPreviewView> createState() => _ListingPreviewViewState();
}

class _ListingPreviewViewState extends State<ListingPreviewView> {
  late final AddNewListingController controller;
  final profileController = Get.find<ProfileController>();

  final PageController _pageController = PageController();
  int _currentPage = 0;

  void initState() {
    super.initState();
    controller = Get.put(AddNewListingController(), tag: widget.controllerTag);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = profileController.user.value;
    final String userName = user?.fullName ?? 'N/A';
    final String userAvatar = user?.displayAvatar ?? '';
    final String userStables = user?.barnName ?? 'N/A';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(),
            const SizedBox(height: 16),
            _buildTrainerInfo(userName, userAvatar, userStables),
            const Divider(height: 32, thickness: 1, color: Color(0xFFF3F4F6)),
            _buildDescriptionAndTags(),
            _buildDetailsCard(),
            _buildPricingCard(),
            _buildAvailabilitySection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Obx(() {
      final List<dynamic> allImages = [
        ...controller.uploadedImages,
        ...controller.localImages,
      ];
      final List<dynamic> allVideos = [
        ...controller.uploadedVideos,
        ...controller.localVideos,
        if (controller.videoLinkController.text.isNotEmpty) controller.videoLinkController.text,
      ];
      final int totalItems = allImages.length + allVideos.length;

      final String title = controller.listingTitleController.text.isEmpty
          ? 'N/A'
          : controller.listingTitleController.text;
      final String location = controller.locationController.text.isEmpty
          ? 'N/A'
          : controller.locationController.text;

      return Stack(
        children: [
          // Hero Image Carousel
          _buildImageSection(allImages, allVideos, totalItems),

          // Header Controls
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircleButton(Icons.arrow_back_ios_new, () => Get.back()),
                // _buildCircleButton(Icons.more_vert, () => {}), // Not needed in preview
              ],
            ),
          ),

          // Title & Badges Overlay
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  title,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      color: Colors.black45,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: controller.selectedListingTypes
                        .toList()
                        .asMap()
                        .entries
                        .map(
                          (entry) => Padding(
                            padding: EdgeInsets.only(
                              right:
                                  entry.key ==
                                      controller.selectedListingTypes.length - 1
                                  ? 0
                                  : 8,
                            ),
                            child: _buildOverlayBadge(entry.value),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: CommonText(
                        location,
                        fontSize: 12,
                        color: Colors.white,
                        overflow: TextOverflow.ellipsis,
                        shadows: const [
                          Shadow(
                            color: Colors.black45,
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    });
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

  Widget _buildOverlayBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF8B4242).withValues(alpha: 0.6),
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

  Widget _buildHeroTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFEF4444).withValues(alpha: 0.2),
        ),
      ),
      child: CommonText(
        tag,
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTrainerInfo(String name, String avatar, String stables) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CommonImageView(
            url: avatar,
            height: 48,
            width: 48,
            shape: BoxShape.circle,
            isUserImage: true,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  name,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                CommonText(
                  stables,
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionAndTags() {
    final String description = controller.descriptionController.text.isEmpty
        ? 'N/A'
        : controller.descriptionController.text;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            description,
            fontSize: 14,
            height: 1.5,
            color: const Color(0xFF374151),
            fontWeight: FontWeight.w500,
          ),
          const SizedBox(height: 20),
          Obx(() {
            final List<String> selectedTagNames = [];
            for (var type in controller.tagTypes) {
              final List values = type['values'] ?? [];
              for (var v in values) {
                if (controller.selectedTags.contains(v['_id'].toString())) {
                  selectedTagNames.add(v['name'].toString());
                }
              }
            }
            // Fallback for preview if empty
            // No fallback tags if empty

            if (selectedTagNames.isEmpty) return const SizedBox.shrink();
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: selectedTagNames
                  .map((tag) => _buildDetailChip(tag))
                  .toList(),
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDetailChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: CommonText(
        label,
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1D2939),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: CommonText(
            'Details',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildGridRow(
                'Horse name',
                controller.horseNameController.text.isEmpty
                    ? 'N/A'
                    : controller.horseNameController.text,
                'USEF',
                controller.usefNumberController.text.isEmpty
                    ? 'N/A'
                    : controller.usefNumberController.text,
                isExternal: true,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1, color: AppColors.borderLight),
              ),
              _buildGridRow(
                'Year Foaled',
                controller.ageController.text.isEmpty
                    ? 'N/A'
                    : '${controller.ageController.text}',
                'Height',
                controller.heightController.text.isEmpty
                    ? 'N/A'
                    : controller.heightController.text,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1, color: AppColors.borderLight),
              ),
              _buildGridRow(
                'Breed',
                controller.breedController.text.isEmpty
                    ? 'N/A'
                    : controller.breedController.text,
                'Color',
                controller.colorController.text.isEmpty
                    ? 'N/A'
                    : controller.colorController.text,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1, color: AppColors.borderLight),
              ),
              _buildGridRow(
                'Discipline',
                controller.selectedDisciplines.isEmpty
                    ? 'N/A'
                    : controller.selectedDisciplines.join(', '),
                '',
                '',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGridRow(
    String label1,
    String val1,
    String label2,
    String val2, {
    bool isExternal = false,
  }) {
    return Row(
      children: [
        Expanded(child: _buildGridItem(label1, val1)),
        Expanded(child: _buildGridItem(label2, val2, isExternal: isExternal)),
      ],
    );
  }

  Widget _buildGridItem(String label, String value, {bool isExternal = false}) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: CommonText(
                label,
                fontSize: 13,
                color: AppColors.textSecondary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isExternal && value.isNotEmpty) ...[
              const SizedBox(width: 6),
              const Icon(Icons.open_in_new, size: 16, color: Color(0xFF3B82F6)),
            ],
          ],
        ),
        const SizedBox(height: 6),
        CommonText(
          value,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildPricingCard() {
    List<String> types = controller.selectedListingTypes.toList();
    if (types.isEmpty) {
      // Fallback for preview
      types = [
        'For Sale',
        'Weekly Lease',
        'Annual Lease',
        'Short Term or Circuit Lease',
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: CommonText(
            'Pricing',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: List.generate((types.length / 2).ceil(), (index) {
              final start = index * 2;
              final end = (start + 2 < types.length) ? start + 2 : types.length;
              final pair = types.sublist(start, end);

              return Column(
                children: [
                  Row(
                    children: pair.map((type) {
                      final isInquire =
                          controller.inquireForPrice[type] ?? false;
                      final minPrice =
                          controller.minPriceControllers[type]?.text ?? '';
                      final maxPrice =
                          controller.maxPriceControllers[type]?.text ?? '';

                      // Show 'N/A' for empty fields in preview
                      String priceText = 'N/A';
                      if (isInquire) {
                        priceText = 'Inquire';
                      } else if (minPrice.isNotEmpty && maxPrice.isNotEmpty) {
                        priceText = '\$ $minPrice - \$ $maxPrice';
                      }

                      return Expanded(child: _buildGridItem(type, priceText));
                    }).toList(),
                  ),
                  if (index < (types.length / 2).ceil() - 1)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1, color: AppColors.borderLight),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilitySection() {
    return Obx(() {
      final entries = controller.availabilityEntries;

      final List<dynamic> displayEntries = entries.where((e) {
        return e.showVenueController.text.isNotEmpty ||
            e.cityStateController.text.isNotEmpty ||
            e.startDateController.text.isNotEmpty;
      }).toList();

      if (displayEntries.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: CommonText(
              'Availability',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayEntries.length,
              separatorBuilder: (_, __) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1, color: AppColors.borderLight),
              ),
              itemBuilder: (context, index) {
                final entry = displayEntries[index];
                String venue, dates, location;

                if (entry is Map) {
                  venue = entry['venue'];
                  dates = entry['dates'];
                  location = entry['location'];
                } else {
                  venue = entry.showVenueController.text;
                  dates =   DateUtil.formatRange(entry.startDateController.text, entry.endDateController.text);
                  location = entry.cityStateController.text;
                }

                if (venue.isEmpty) venue = 'N/A';
                if (dates.trim() == '-') dates = 'N/A';
                if (location.isEmpty) location = 'N/A';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      venue,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 10),
                        CommonText(
                          dates,
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 10),
                        CommonText(
                          location,
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildImageSection(List<dynamic> allImages, List<dynamic> allVideos, int totalItems) {
    if (totalItems == 0) {
      return Container(
        height: 420,
        width: double.infinity,
        color: Colors.grey[200],
        child: const Icon(Icons.image, size: 100, color: Colors.grey),
      );
    }

    return Stack(
      children: [
        SizedBox(
          height: 420,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: totalItems,
            itemBuilder: (context, index) {
              if (index < allImages.length) {
                final image = allImages[index];
                if (image is String) {
                  return CommonImageView(
                    url: image,
                    height: 420,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                }
                return CommonImageView(
                  file: image as File,
                  height: 420,
                  width: double.infinity,
                  fit: BoxFit.cover,
                );
              } else {
                final video = allVideos[index - allImages.length];
                return _InlineVideoPlayer(source: video);
              }
            },
          ),
        ),
        // Gradient Overlay matched with Detail View style
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.4, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
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
}

class _InlineVideoPlayer extends StatefulWidget {
  final dynamic source; // Can be a File or a String url
  const _InlineVideoPlayer({required this.source});

  @override
  State<_InlineVideoPlayer> createState() => _InlineVideoPlayerState();
}

class _InlineVideoPlayerState extends State<_InlineVideoPlayer> {
  VideoPlayerController? _controller;
  YoutubePlayerController? _youtubeController;
  bool _isYoutube = false;
  bool _initialized = false;
  bool _error = false;
  bool _hasStartedPlaying = false;

  @override
  void initState() {
    super.initState();
    if (widget.source is File) {
      _controller = VideoPlayerController.file(widget.source as File)
        ..initialize().then((_) {
          _setupController();
        }).catchError((e) {
          _handleError(e);
        });
    } else if (widget.source is String) {
      final String url = widget.source as String;
      final youtubeId = YoutubePlayer.convertUrlToId(url);
      if (youtubeId != null) {
        _isYoutube = true;
        _youtubeController = YoutubePlayerController(
          initialVideoId: youtubeId,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: true,
            loop: true,
            hideControls: true,
            disableDragSeek: true,
          ),
        )..addListener(() {
            if (mounted) {
              if (_youtubeController!.value.isPlaying && !_hasStartedPlaying) {
                _hasStartedPlaying = true;
              }
              setState(() {});
            }
          });
        _initialized = true;
      } else {
        _controller = VideoPlayerController.networkUrl(Uri.parse(url))
          ..initialize().then((_) {
            _setupController();
          }).catchError((e) {
            _handleError(e);
          });
      }
    } else {
      _error = true;
    }
  }

  void _setupController() {
    if (mounted && _controller != null) {
      _controller!.setVolume(0); // mute
      _controller!.setLooping(true); // loop
      _controller!.play(); // autoplay
      _controller!.addListener(() {
        if (mounted) {
          if (_controller!.value.isPlaying && !_hasStartedPlaying) {
            _hasStartedPlaying = true;
          }
          setState(() {});
        }
      });
      setState(() {
        _initialized = true;
      });
    }
  }

  void _handleError(dynamic e) {
    debugPrint('Error loading video: $e');
    if (mounted) {
      setState(() {
        _error = true;
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
    if (_error) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 40),
              SizedBox(height: 8),
              CommonText(
                'Error loading video',
                color: Colors.white,
                fontSize: 12,
              ),
            ],
          ),
        ),
      );
    }

    if (!_initialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_isYoutube && _youtubeController != null) {
      final isPlaying = _youtubeController!.value.isPlaying;
      final isBuffering = !_hasStartedPlaying || _youtubeController!.value.playerState == PlayerState.buffering;
      
      return GestureDetector(
        onTap: () {
          setState(() {
            _youtubeController!.value.isPlaying
                ? _youtubeController!.pause()
                : _youtubeController!.play();
          });
        },
        child: Container(
          color: Colors.black,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AbsorbPointer(
                child: YoutubePlayer(
                  controller: _youtubeController!,
                  showVideoProgressIndicator: false,
                ),
              ),
              if (!isPlaying || isBuffering)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: isBuffering
                      ? const SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 40,
                        ),
                ),
            ],
          ),
        ),
      );
    }

    final isPlaying = _controller!.value.isPlaying;
    final isBuffering = !_hasStartedPlaying || _controller!.value.isBuffering;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _controller!.value.isPlaying
              ? _controller!.pause()
              : _controller!.play();
        });
      },
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
            if (!isPlaying || isBuffering)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: isBuffering
                    ? const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Icon(
                        Icons.play_arrow,
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

