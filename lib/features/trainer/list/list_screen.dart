
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/trainer/list/add_horse_screen.dart';

class ListScreen extends StatelessWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Listings')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.grey400),
            const SizedBox(height: 16),
            Text('No horses listed yet', style: AppTextStyles.titleMedium),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Get.to(() => const AddHorseScreen());
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Horse'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepNavy,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
