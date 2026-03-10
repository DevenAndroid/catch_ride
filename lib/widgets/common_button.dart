import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';

import 'package:catch_ride/constant/app_colors.dart';
import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  final String? text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double width;
  final double? height;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? child;

  const CommonButton({
    super.key,
    this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width = double.infinity,
    this.height,
    this.borderRadius,
    this.backgroundColor,
    this.textColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onPressed,
      borderRadius: BorderRadius.circular(borderRadius ?? 12),
      child: Container(
        width: width,
        height: height ?? 52,
        decoration: BoxDecoration(
          color: isLoading
              ? (backgroundColor ?? AppColors.primary).withValues(alpha: 0.7)
              : (backgroundColor ?? AppColors.primary),
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : child ??
                CommonText(
                  text ?? "",
                  color: textColor ?? Colors.white,
                  fontSize: AppTextSizes.size16,
                  fontWeight: FontWeight.w600,
                ),
      ),
    );
  }
}
