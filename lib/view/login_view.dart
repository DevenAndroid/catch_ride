import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/social_button.dart';
import 'package:catch_ride/view/select_role_view.dart';
import 'package:catch_ride/view/create_account_view.dart';
import 'package:flutter_svg/svg.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _obscurePassword = true;

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
              const Text(
                'CATCH RIDE',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 1.5,
                ),
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
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Fill out the information below in order to access your account.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    const CommonTextField(
                      label: 'Email',
                      hintText: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    CommonTextField(
                      label: 'Password',
                      hintText: '******',
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
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          // Forget Password action
                        },
                        child: const Text(
                          'Forget Password?',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFD92D20),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    CommonButton(
                      text: 'Log In',
                      onPressed: () {
                        // Log In action
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SelectRoleView(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    const Center(
                      child: Text(
                        'Or Log In with',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    SocialButton(
                      text: 'Continue with Google',
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
                      text: 'Continue with Apple ID',
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
                  const Text(
                    'Don’t have an account? ',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateAccountView(),
                        ),
                      );
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
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
}
