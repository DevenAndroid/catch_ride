import 'package:catch_ride/view/auth/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';

import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.deepNavy, // Start with Deep Navy
              Color(0xFF0F2C52), // Slightly lighter shade for depth
              AppColors.deepNavy, // Back to deep navy
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),

                // Logo Placeholder
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.mutedGold.withOpacity(0.5),
                        width: 1,
                      ),
                      color: AppColors.deepNavy.withOpacity(0.5),
                    ),
                    child: Icon(
                      Icons
                          .bedroom_baby_outlined, // Placeholder for horse/stable icon
                      size: 64,
                      color: AppColors.mutedGold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Brand
                Text(
                  'CATCH RIDE',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.mutedGold,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Premium Equestrian Marketplace',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.warmCream.withOpacity(0.8),
                    letterSpacing: 0.5,
                  ),
                ),

                const Spacer(flex: 2),

                // CTA Buttons
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mutedGold,
                    foregroundColor: AppColors.deepNavy,
                  ),
                  child: const Text('Get Started'),
                ),

                const SizedBox(height: 16),

                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.mutedGold),
                    foregroundColor: AppColors.mutedGold,
                  ),
                  child: const Text('Log In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
