import 'dart:io';
import 'package:flutter/foundation.dart';

class AppUrls {
  static String get host {
    if (kIsWeb) return 'localhost';
    if (Platform.isAndroid) return '10.0.2.2';
    return 'localhost';
  }

  static String get baseUrl => 'http://$host:5000/api';
  static String get socketUrl => 'http://$host:5000';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendOtp = '/auth/resend-otp';
  static const String verifyToken = '/auth/verify';

  // Horses
  static const String horses = '/horses';
  static const String horseDetails = '/horses/'; // + id

  // Bookings
  static const String bookings = '/bookings';
  
  // Trainers
  static const String trainers = '/trainers';

  // System Config (Tags)
  static const String systemConfig = '/system-config';
  static const String programTags = '$systemConfig/program-tags';
  static const String opportunityTags = '$systemConfig/opportunity-tags';
  static const String experienceLevels = '$systemConfig/experience-levels';
  static const String personalityTags = '$systemConfig/personality-tags';

  // Profile
  static const String profile = '/profile';
  static const String updateRole = '/profile/role';
  static const String completeProfile = '/profile/complete';
  static const String uploadProfileImage = '/profile/upload-image';
}
