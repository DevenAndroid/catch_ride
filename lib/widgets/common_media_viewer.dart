import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_image_view.dart';

class CommonMediaViewer extends StatefulWidget {
  final List<dynamic> mediaSources;
  final int initialIndex;

  const CommonMediaViewer({
    super.key,
    required this.mediaSources,
    required this.initialIndex,
  });

  @override
  State<CommonMediaViewer> createState() => _CommonMediaViewerState();
}

class _CommonMediaViewerState extends State<CommonMediaViewer> {
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

  bool _isSourceVideo(dynamic source) {
    if (source is File) {
      final path = source.path.toLowerCase();
      return path.endsWith('.mp4') || path.endsWith('.mov') || path.endsWith('.avi');
    }
    if (source is String) {
      final lower = source.toLowerCase();
      final isYoutube = lower.contains('youtube.com') || lower.contains('youtu.be');
      return isYoutube ||
          lower.contains('horsevideos') ||
          lower.endsWith('.mp4') ||
          lower.endsWith('.mov') ||
          lower.endsWith('.avi');
    }
    return false;
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
            itemCount: widget.mediaSources.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final source = widget.mediaSources[index];
              if (_isSourceVideo(source)) {
                return CommonVideoPlayerWidget(source: source);
              } else {
                return Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: source is String
                        ? CommonImageView(
                            url: source,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : CommonImageView(
                            file: source as File,
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
          // Page Indicator
          if (widget.mediaSources.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.mediaSources.length}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CommonVideoPlayerWidget extends StatefulWidget {
  final dynamic source;
  const CommonVideoPlayerWidget({super.key, required this.source});

  @override
  State<CommonVideoPlayerWidget> createState() => _CommonVideoPlayerWidgetState();
}

class _CommonVideoPlayerWidgetState extends State<CommonVideoPlayerWidget> with AutomaticKeepAliveClientMixin {
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
    if (widget.source is File) {
      _videoPlayerController = VideoPlayerController.file(widget.source as File);
      _setupChewie();
    } else if (widget.source is String) {
      final String url = widget.source as String;
      final youtubeId = YoutubePlayer.convertUrlToId(url);
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
        _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
        _setupChewie();
      }
    }
  }

  void _setupChewie() {
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
