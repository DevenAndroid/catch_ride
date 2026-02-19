
import 'package:flutter/material.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/view/trainer/trainer_main_screen.dart';

class BarnManagerMainScreen extends StatelessWidget {
  const BarnManagerMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barn Manager Mode'),
        backgroundColor: AppColors.mutedGold.withOpacity(0.1),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show info
            },
          ),
        ],
      ),
      body: const TrainerMainScreen(), // Reusing Trainer UI
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('Manage Setup'),
        icon: const Icon(Icons.settings),
        backgroundColor: AppColors.mutedGold,
      ),
    );
  }
}
