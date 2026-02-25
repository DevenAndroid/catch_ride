import 'package:catch_ride/constant/app_strings.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';

import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/segmented_tab_control.dart';
import 'package:catch_ride/widgets/social_button.dart';
import 'package:catch_ride/view/select_role_view.dart';
import 'package:flutter_svg/svg.dart';

import 'package:catch_ride/view/login_view.dart';

class CreateAccountView extends StatefulWidget {
  const CreateAccountView({super.key});

  @override
  State<CreateAccountView> createState() => _CreateAccountViewState();
}

class _CreateAccountViewState extends State<CreateAccountView> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset("assets/images/logo.svg"),

              const SizedBox(height: 12),
              const CommonText(
                AppStrings.catchRide1,
                fontSize: AppTextSizes.size18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 1.5,
              ),
              const SizedBox(height: 32),

              // Main Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CommonText(
                      AppStrings.createAccount,
                      fontSize: AppTextSizes.size22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                    ),
                    const SizedBox(height: 8),
                    const CommonText(
                      'Let\'s get started by filling out the form below.',
                      fontSize: AppTextSizes.size14,
                        color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 24),

                    const CommonTextField(
                      label: AppStrings.email,
                      hintText: AppStrings.enterYourEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    CommonTextField(
                      label: AppStrings.password,
                      hintText: AppStrings.emptyString,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    CommonTextField(
                      label: AppStrings.confirmPassword,
                      hintText: AppStrings.emptyString,
                      obscureText: _obscureConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 24),
                    CommonButton(
                      text: AppStrings.getStarted,
                      onPressed: () {
                        // Get Started action
                      },
                    ),
                    const SizedBox(height: 20),

                    const Center(
                      child: CommonText(
                        AppStrings.orSignUpWith,
                        fontSize: AppTextSizes.size14,
                          color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    SocialButton(
                      text: AppStrings.continueWithGoogle,
                      icon: SvgPicture.asset("assets/icons/google_icon.svg"),
                      onPressed: () {
                        // Google Sign In Action
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SelectRoleView(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    SocialButton(
                      text: AppStrings.continueWithAppleId,
                      icon: SvgPicture.asset("assets/icons/apple_logo.svg"),
                      onPressed: () {
                        // Apple Sign In Action
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CommonText(
                    AppStrings.alreadyHaveAnAccount,
                    fontSize: AppTextSizes.size14,
                      color: AppColors.textSecondary,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginView(),
                        ),
                      );
                    },
                    child: const CommonText(
                      AppStrings.logIn,
                      fontSize: AppTextSizes.size14,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
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
}
