import 'package:catch_ride/constant/app_strings.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/social_button.dart';
import 'package:catch_ride/view/select_role_view.dart';
import 'package:catch_ride/view/create_account_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:catch_ride/view/forget_password_flow/forgot_password_request_view.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:get/get.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AuthController _authController = Get.find<AuthController>();
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
     final  size= MediaQuery.of(context).size.height;

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
                SizedBox(height: size * 0.024),

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
                        AppStrings.welcomeBack,
                        fontSize: AppTextSizes.size22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      SizedBox(height: size * 0.006),
                      const CommonText(
                        AppStrings.welcomeBackSubtitle,
                        fontSize: AppTextSizes.size14,
                        color: AppColors.textSecondary,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: size * 0.022),

                      CommonTextField(
                        label: AppStrings.email,
                        hintText: AppStrings.enterYourEmail,
                        keyboardType: TextInputType.emailAddress,
                        controller: _authController.emailController,
                        validator: MultiValidator([
                          RequiredValidator(
                            errorText: 'Please enter your email',
                          ),
                          EmailValidator(
                            errorText: 'Please enter a valid email address',
                          ),
                        ]),
                      ),
                      SizedBox(height: size * 0.02),

                      CommonTextField(
                        label: AppStrings.password,
                        hintText: AppStrings.emptyString,
                        obscureText: _obscurePassword,
                        controller: _authController.passwordController,
                        validator: RequiredValidator(
                          errorText: 'Please enter your password',
                        ),
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
                      SizedBox(height: size * 0.015),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Get.to(() => const ForgotPasswordRequestView());
                          },
                          child: const CommonText(
                            AppStrings.forgetPassword,
                            fontSize: AppTextSizes.size14,
                            color: Color(0xFFD92D20),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      SizedBox(height: size * 0.024),
                      Obx(
                        () => CommonButton(
                          text: _authController.isLoading.value
                              ? AppStrings.loggingIn
                              : AppStrings.logIn,
                          onPressed: _authController.isLoading.value
                              ? () {}
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    _authController.login();
                                  }
                                },
                        ),
                      ),
                      if (!kIsWeb) ...[
                        SizedBox(height: size * 0.02),
                        const Center(
                          child: CommonText(
                            AppStrings.orLogInWith,
                            fontSize: AppTextSizes.size14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: size * 0.02),
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
                          SizedBox(height: size * 0.015),
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
                SizedBox(height: size * 0.022),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CommonText(
                      AppStrings.dontHaveAnAccount,
                      fontSize: AppTextSizes.size14,
                      color: AppColors.textSecondary,
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.off(() => const CreateAccountView());
                      },
                      child: const CommonText(
                        AppStrings.signUp,
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
      ),
    );
  }
}
