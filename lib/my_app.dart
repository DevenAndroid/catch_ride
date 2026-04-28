import 'package:catch_ride/constant/app_strings.dart';
import 'package:catch_ride/view/trainer/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/constant/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "CatchRide",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(context).textScaler.clamp(
                  minScaleFactor: 1.0,
                  maxScaleFactor: 1.0,
                ),
          ),
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}
