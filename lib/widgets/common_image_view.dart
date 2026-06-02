import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_constants.dart';
import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/widgets/common_media_viewer.dart';
import 'package:flutter_avif/flutter_avif.dart';

class CommonImageView extends StatelessWidget {
  final String? url;
  final double? height;
  final double? width;
  final BoxFit fit;
  final double radius;
  final BoxShape shape;
  final IconData? fallbackIcon;
  final File? file;
  final String? assetPath;
  final bool isUserImage;
  final bool enableFullScreen;
  final VoidCallback? onTap;

  const CommonImageView({
    super.key,
    this.url,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.radius = 0,
    this.shape = BoxShape.rectangle,
    this.fallbackIcon,
    this.file,
    this.assetPath,
    this.isUserImage = true,
    this.enableFullScreen = false,
    this.onTap,
  });

  String _getProcessedUrl(String url) {
    if (url.isEmpty) return url;

    // Normalize slashes
    url = url.replaceAll('\\', '/');

    // Handle protocol-relative URLs
    if (url.startsWith('//')) {
      url = 'https:$url';
    }

    // If it's an already signed AWS S3 URL from the DB, the signature might be expired.
    // We strip it down to the relative uploads/ path so our backend can issue a fresh redirect.
    // However, we avoid stripping AVIF URLs since redirect handling in AvifImage.network
    // can be unreliable, preferring the direct signed S3 URL.
    final String cleanUrl = url.trim();
    final bool isAvifUrl = cleanUrl.toLowerCase().split('?').first.contains('.avif');
    if (!isAvifUrl &&
        cleanUrl.contains('s3.us-east-1.amazonaws.com') &&
        cleanUrl.contains('uploads/')) {
      final index = cleanUrl.indexOf('uploads/');
      if (index != -1) {
        url = cleanUrl.substring(index).split('?').first;
      }
    }

    // If it's already a full URL, handle localhost/mapping
    if (url.startsWith('http')) {
      final String currentHost = AppUrls.host;

      // If we are in live mode, any local host in the data should be replaced by the live domain
      if (AppUrls.isLive) {
        return url
            .replaceFirst('localhost', 'api.catchrideapp.com')
            .replaceFirst('127.0.0.1', 'api.catchrideapp.com')
            .replaceFirst('10.0.2.2', 'api.catchrideapp.com');
      }

      // Dev / ngrok: replace typical local origins (no trailing /api — media is on root)
      final devOrigin = AppUrls.socketUrl.endsWith('/')
          ? AppUrls.socketUrl.substring(0, AppUrls.socketUrl.length - 1)
          : AppUrls.socketUrl;
      url = url
          .replaceFirst('http://localhost:5000', devOrigin)
          .replaceFirst('http://127.0.0.1:5000', devOrigin)
          .replaceFirst('http://10.0.2.2:5000', devOrigin)
          .replaceFirst('https://localhost:5000', devOrigin);

      return url
          .replaceFirst('localhost', currentHost)
          .replaceFirst('127.0.0.1', currentHost)
          .replaceFirst('10.0.2.2', currentHost);
    }

    // If it's a relative path, prepend the socketUrl (without /api suffix)
    String baseUrl = AppUrls.socketUrl;
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    // Ensure relative paths from local storage include 'uploads/' if missing
    String processedPath = url;
    if (!processedPath.startsWith('uploads/') &&
        !processedPath.startsWith('/uploads/')) {
      processedPath = processedPath.startsWith('/')
          ? 'uploads$processedPath'
          : 'uploads/$processedPath';
    }

    final path = processedPath.startsWith('/')
        ? processedPath
        : '/$processedPath';
    return '$baseUrl$path';
  }

  @override
  Widget build(BuildContext context) {
    if (assetPath != null && assetPath!.isNotEmpty) {
      return Container(
        height: height,
        width: width,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.border.withOpacity(0.1),
          shape: shape,
          borderRadius: shape == BoxShape.circle
              ? null
              : BorderRadius.circular(radius),
        ),
        child: GestureDetector(
          onTap:
              onTap ??
              (enableFullScreen
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CommonMediaViewer(
                            mediaSources: [assetPath!],
                            initialIndex: 0,
                          ),
                        ),
                      );
                    }
                  : null),
          child: Image.asset(
            assetPath!,
            height: height,
            width: width,
            fit: fit,
          ),
        ),
      );
    }

    if (file != null) {
      return Container(
        height: height,
        width: width,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.border.withOpacity(0.1),
          shape: shape,
          borderRadius: shape == BoxShape.circle
              ? null
              : BorderRadius.circular(radius),
        ),
        child: GestureDetector(
          onTap:
              onTap ??
              (enableFullScreen
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CommonMediaViewer(
                            mediaSources: [file!],
                            initialIndex: 0,
                          ),
                        ),
                      );
                    }
                  : null),
          child: Image.file(file!, height: height, width: width, fit: fit),
        ),
      );
    }

    if (url == null || url!.isEmpty) {
      return _buildPlaceholder();
    }

    // Handle Base64 strings directly
    if (url!.startsWith('data:image')) {
      try {
        final String base64Data = url!.split(';base64,').last;
        final decodedImage = Uri.parse(url!).data?.contentAsBytes();
        if (decodedImage != null) {
          return Container(
            height: height,
            width: width,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.border.withOpacity(0.1),
              shape: shape,
              borderRadius: shape == BoxShape.circle
                  ? null
                  : BorderRadius.circular(radius),
            ),
            child: GestureDetector(
              onTap:
                  onTap ??
                  (enableFullScreen
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CommonMediaViewer(
                                mediaSources: [url!],
                                initialIndex: 0,
                              ),
                            ),
                          );
                        }
                      : null),
              child: Image.memory(
                decodedImage,
                height: height,
                width: width,
                fit: fit,
              ),
            ),
          );
        }
      } catch (e) {
        debugPrint('❌ CommonImageView: Error decoding base64 image: $e');
      }
    }

    final imageUrl = _getProcessedUrl(url!);
    final String cleanUrl = url!.trim();
    final String cleanImageUrl = imageUrl.trim();
    final bool isAvif = cleanUrl.toLowerCase().split('?').first.contains('.avif') ||
        cleanImageUrl.toLowerCase().split('?').first.contains('.avif');

    return Container(
      height: height,
      width: width,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.border.withOpacity(0.1),
        shape: shape,
        borderRadius: shape == BoxShape.circle
            ? null
            : BorderRadius.circular(radius),
      ),
      child: GestureDetector(
        onTap:
            onTap ??
            (enableFullScreen
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommonMediaViewer(
                          mediaSources: [url!],
                          initialIndex: 0,
                        ),
                      ),
                    );
                  }
                : null),
        child: isAvif
            ? _NetworkAvifImageView(
                url: imageUrl,
                height: height,
                width: width,
                fit: fit,
                placeholderBuilder: () => Container(color: AppColors.lightGray),
                errorBuilder: () => _buildPlaceholder(),
              )
            : CachedNetworkImage(
                imageUrl: imageUrl,
                height: height,
                width: width,
                fit: fit,
                fadeInDuration: const Duration(milliseconds: 3),
                placeholder: (context, url) => Container(
                  color: AppColors.lightGray,
                ),
                errorWidget: (context, url, error) => _buildPlaceholder(),
              ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: height,
      width: width,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.02),
            AppColors.primary.withOpacity(0.08),
          ],
        ),
        shape: shape,
        borderRadius: shape == BoxShape.circle
            ? null
            : BorderRadius.circular(radius),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final effectiveWidth = constraints.hasBoundedWidth
              ? constraints.maxWidth
              : width;
          final effectiveHeight = constraints.hasBoundedHeight
              ? constraints.maxHeight
              : height;
          final shortestSide =
              [
                if (effectiveWidth != null) effectiveWidth,
                if (effectiveHeight != null) effectiveHeight,
              ].fold<double?>(null, (current, value) {
                if (current == null || value < current) return value;
                return current;
              });
          final isTiny = shortestSide != null && shortestSide < 40;
          final isCompact = shortestSide != null && shortestSide < 96;
          final icon =
              fallbackIcon ??
              (isUserImage ? Icons.person_rounded : Icons.error_outline);

          if (isTiny) {
            return Center(
              child: Icon(
                icon,
                size: shortestSide * 0.6,
                color: AppColors.primary.withOpacity(0.4),
              ),
            );
          }

          return Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(isCompact ? 8 : 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: isCompact ? 20 : 28,
                      color: AppColors.primary.withOpacity(0.4),
                    ),
                  ),
                  if (!isCompact) ...[
                    const SizedBox(height: 8),
                    Text(
                      isUserImage ? '' : '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: AppColors.primary.withOpacity(0.4),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NetworkAvifImageView extends StatefulWidget {
  final String url;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Widget Function() placeholderBuilder;
  final Widget Function() errorBuilder;

  const _NetworkAvifImageView({
    required this.url,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    required this.placeholderBuilder,
    required this.errorBuilder,
  });

  @override
  State<_NetworkAvifImageView> createState() => _NetworkAvifImageViewState();
}

class _NetworkAvifImageViewState extends State<_NetworkAvifImageView> {
  static final Map<String, Uint8List> _avifMemoryCache = {};

  Uint8List? _imageBytes;
  bool _isLoading = true;
  bool _hasError = false;
  String? _loadedUrl;

  @override
  void initState() {
    super.initState();
    final String cacheKey = widget.url.split('?').first;
    if (_avifMemoryCache.containsKey(cacheKey)) {
      _imageBytes = _avifMemoryCache[cacheKey];
      _isLoading = false;
    } else {
      _loadImage();
    }
  }

  @override
  void didUpdateWidget(_NetworkAvifImageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      final String cacheKey = widget.url.split('?').first;
      if (_avifMemoryCache.containsKey(cacheKey)) {
        setState(() {
          _imageBytes = _avifMemoryCache[cacheKey];
          _isLoading = false;
          _hasError = false;
        });
      } else {
        _loadImage();
      }
    }
  }

  Future<void> _loadImage() async {
    if (!mounted) return;
    
    final String targetUrl = widget.url;
    _loadedUrl = targetUrl;
    
    final String cacheKey = targetUrl.split('?').first;

    if (_avifMemoryCache.containsKey(cacheKey)) {
      setState(() {
        _imageBytes = _avifMemoryCache[cacheKey];
        _isLoading = false;
        _hasError = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
      _imageBytes = null;
    });

    try {
      final response = await http.get(Uri.parse(targetUrl));

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        debugPrint('ℹ️ _NetworkAvifImageView: Downloaded ${bytes.length} bytes successfully.');
        
        if (bytes.length > 12) {
          final signature = bytes.sublist(4, 12);
          final sigHex = signature.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
          debugPrint('ℹ️ _NetworkAvifImageView: Container signature (hex): $sigHex');
          if (sigHex == '6674797061766966') {
            debugPrint('ℹ️ _NetworkAvifImageView: Valid AVIF container signature found.');
          } else {
            debugPrint('⚠️ _NetworkAvifImageView: Signature does not match standard AVIF. Check if the image source is a valid AVIF.');
          }
        }

        // Cache the bytes
        _avifMemoryCache[cacheKey] = bytes;

        if (mounted && _loadedUrl == targetUrl) {
          setState(() {
            _imageBytes = bytes;
            _isLoading = false;
          });
        }
      } else {
        debugPrint('❌ _NetworkAvifImageView: Failed to load image. Status: ${response.statusCode}, URL: $targetUrl');
        if (mounted && _loadedUrl == targetUrl) {
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('❌ _NetworkAvifImageView: Error fetching URL: $e');
      if (mounted && _loadedUrl == targetUrl) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.placeholderBuilder();
    }
    if (_hasError || _imageBytes == null) {
      return widget.errorBuilder();
    }
    return AvifImage.memory(
      _imageBytes!,
      height: widget.height,
      width: widget.width,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) => widget.errorBuilder(),
    );
  }
}

