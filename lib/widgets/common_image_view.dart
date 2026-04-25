import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_constants.dart';
import 'package:catch_ride/constant/app_urls.dart';

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
    if (url.contains('s3.us-east-1.amazonaws.com') && url.contains('uploads/')) {
      final index = url.indexOf('uploads/');
      if (index != -1) {
        url = url.substring(index).split('?').first;
      }
    }

    // If it's already a full URL, handle localhost/mapping
    if (url.startsWith('http')) {
      final String currentHost = AppUrls.host;
      
      // If we are in live mode, any local host in the data should be replaced by the live domain
      if (AppUrls.isLive) {
        return url.replaceFirst('localhost', 'api.catchrideapp.com').replaceFirst('127.0.0.1', 'api.catchrideapp.com').replaceFirst('10.0.2.2', 'api.catchrideapp.com');
      }
      
      // Otherwise map to current host constant
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
    if (!processedPath.startsWith('uploads/') && !processedPath.startsWith('/uploads/')) {
      processedPath = processedPath.startsWith('/') ? 'uploads$processedPath' : 'uploads/$processedPath';
    }
    
    final path = processedPath.startsWith('/') ? processedPath : '/$processedPath';
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
        child: Image.asset(assetPath!, height: height, width: width, fit: fit),
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
        child: Image.file(file!, height: height, width: width, fit: fit),
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
            child: Image.memory(decodedImage, height: height, width: width, fit: fit),
          );
        }
      } catch (e) {
        debugPrint('❌ CommonImageView: Error decoding base64 image: $e');
      }
    }

    final imageUrl = _getProcessedUrl(url!);

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
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: height,
        width: width,
        fit: fit,
        placeholder: (context, url) => Container(
          color: AppColors.border.withOpacity(0.1),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.textSecondary,
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildPlaceholder(),
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
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all((width != null && width! < 50) ? 8 : 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isUserImage ? Icons.person_rounded : Icons.pets_rounded,
                size: (width != null && width! < 100) ? 20 : 28,
                color: AppColors.primary.withOpacity(0.4),
              ),
            ),
            if (width == null || width! >= 120) ...[
              const SizedBox(height: 8),
              Text(
                isUserImage ? 'Profile Not Set' : 'No Photo Available',
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
  }
}

