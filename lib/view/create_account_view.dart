import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/segmented_tab_control.dart';
import 'package:catch_ride/widgets/social_button.dart';
import 'package:catch_ride/view/select_role_view.dart';
import 'package:flutter_svg/svg.dart';

class CreateAccountView extends StatefulWidget {
  const CreateAccountView({super.key});

  @override
  State<CreateAccountView> createState() => _CreateAccountViewState();
}

class _CreateAccountViewState extends State<CreateAccountView> {
  int _selectedTabIndex = 0;
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
                    SegmentedTabControl(
                      selectedIndex: _selectedTabIndex,
                      tabs: const ['Create Account', 'Log In'],
                      onTabChanged: (index) {
                        setState(() {
                          _selectedTabIndex = index;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    Text(
                      _selectedTabIndex == 0
                          ? 'Create Account'
                          : 'Welcome Back',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedTabIndex == 0
                          ? 'Let\'s get started by filling out the form below.'
                          : 'Fill out the information below in order to access your account.',
                      style: const TextStyle(
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

                    if (_selectedTabIndex == 1) ...[
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
                    ],

                    if (_selectedTabIndex == 0) ...[
                      const SizedBox(height: 16),
                      CommonTextField(
                        label: 'Confirm Password',
                        hintText: '******',
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
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                    CommonButton(
                      text: _selectedTabIndex == 0 ? 'Get Started' : 'Log In',
                      onPressed: () {
                        if (_selectedTabIndex == 1) {
                          // Log In action
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SelectRoleView(),
                            ),
                          );
                        } else {
                          // Get Started action
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    Center(
                      child: Text(
                        _selectedTabIndex == 0
                            ? 'Or sign up with'
                            : 'Or sign up with', // Matching exact text in Log In design
                        style: const TextStyle(
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
