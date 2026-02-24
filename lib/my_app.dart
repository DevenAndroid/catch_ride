import 'package:catch_ride/view/create_account_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/constant/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Catch Ride',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const CreateAccountView(),
    );
  }
}
