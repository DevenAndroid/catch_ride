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
  });

  String _getProcessedUrl(String url) {
    if (url.startsWith('http') && url.contains('localhost')) {
      return url.replaceFirst('localhost', AppUrls.host);
    }
    return url;
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
          borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(radius),
        ),
        child: Image.asset(
          assetPath!,
          height: height,
          width: width,
          fit: fit,
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
          borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(radius),
        ),
        child: Image.file(
          file!,
          height: height,
          width: width,
          fit: fit,
        ),
      );
    }

    if ((url == null || url!.isEmpty) && fallbackIcon != null) {
      return _buildPlaceholder();
    }

    final imageUrl = (url != null && url!.isNotEmpty)
        ? _getProcessedUrl(url!)
        : AppConstants.dummyImageUrl;

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
      decoration: BoxDecoration(
        color: AppColors.border.withOpacity(0.1),
        shape: shape,
        borderRadius: shape == BoxShape.circle
            ? null
            : BorderRadius.circular(radius),
      ),
      child: Center(
        child: Icon(
          fallbackIcon ?? Icons.broken_image_outlined,
          color: AppColors.textSecondary,
          size: height != null ? height! * 0.5 : 24,
        ),
      ),
    );
  }
}
