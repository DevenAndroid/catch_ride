import 'package:catch_ride/constant/app_strings.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';

import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/social_button.dart';
import 'package:catch_ride/view/select_role_view.dart';
import 'package:flutter_svg/svg.dart';

import 'package:catch_ride/view/login_view.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

class CreateAccountView extends StatefulWidget {
  const CreateAccountView({super.key});

  @override
  State<CreateAccountView> createState() => _CreateAccountViewState();
}

class _CreateAccountViewState extends State<CreateAccountView> {
  final AuthController _authController = Get.find<AuthController>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset("assets/images/logo_with_title.svg"),
                const SizedBox(height: 18),

                // Main Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CommonText(
                        AppStrings.createAccount,
                        fontSize: AppTextSizes.size22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(height: 5),
                      const CommonText(
                        AppStrings.createAccountSubtitle,
                        fontSize: AppTextSizes.size14,
                        color: AppColors.textSecondary,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),

                      CommonTextField(
                        controller: _authController.emailController,
                        label: AppStrings.email,
                        hintText: AppStrings.enterYourEmail,
                        keyboardType: TextInputType.emailAddress,
                        validator: MultiValidator([
                          RequiredValidator(
                            errorText: 'Please enter your email',
                          ),
                          EmailValidator(
                            errorText: 'Please enter a valid email address',
                          ),
                        ]),
                      ),
                      const SizedBox(height: 14),

                      CommonTextField(
                        controller: _authController.passwordController,
                        label: AppStrings.password,
                        hintText: AppStrings.emptyString,
                        obscureText: _obscurePassword,
                        validator: MultiValidator([
                          RequiredValidator(
                            errorText: 'Please enter your password',
                          ),
                          MinLengthValidator(
                            6,
                            errorText:
                                'Password must be at least 6 characters',
                          ),
                          PatternValidator(
                            r'[A-Z]',
                            errorText:
                                'Password must have at least one uppercase letter',
                          ),
                          PatternValidator(
                            r'[!@#\$&*~]',
                            errorText:
                                'Password must have at least one special character',
                          ),
                        ]),
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
                      const SizedBox(height: 14),

                      CommonTextField(
                        controller: _authController.confirmPasswordController,
                        label: AppStrings.confirmPassword,
                        hintText: AppStrings.emptyString,
                        obscureText: _obscureConfirmPassword,
                        validator: (val) =>
                            MatchValidator(
                              errorText:
                                  'Passwords do not match, please check again',
                            ).validateMatch(
                              val ?? '',
                              _authController.passwordController.text,
                            ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 18),
                      Obx(
                        () => CommonButton(
                          text: AppStrings.getStarted,
                          isLoading: _authController.isLoading.value,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              // Store for potential OTP resend
                              _authController.registrationEmail.value =
                                  _authController.emailController.text.trim();
                              _authController.registrationPassword.value =
                                  _authController.passwordController.text;

                              // Call register API — will navigate to OTP screen on success
                              await _authController.register({});
                            }
                          },
                        ),
                      ),
                      if (!kIsWeb) ...[
                        const SizedBox(height: 14),
                        const Center(
                          child: CommonText(
                            AppStrings.orSignUpWith,
                            fontSize: AppTextSizes.size14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Obx(
                          () => SocialButton(
                            text: AppStrings.continueWithGoogle,
                            icon: SvgPicture.asset(
                              'assets/icons/google_icon.svg',
                            ),
                            onPressed: _authController.isLoading.value
                                ? () {}
                                : () => _authController.signInWithGoogle(),
                          ),
                        ),
                        if (defaultTargetPlatform == TargetPlatform.iOS) ...[
                          const SizedBox(height: 12),
                          SocialButton(
                            text: AppStrings.continueWithAppleId,
                            icon:
                                SvgPicture.asset('assets/icons/apple_logo.svg'),
                            onPressed: _authController.isLoading.value
                                ? () {}
                                : () => _authController.signInWithApple(),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),
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
                        Get.off(() => const LoginView());
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
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
