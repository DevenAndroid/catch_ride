import 'dart:io';

import 'package:flutter/foundation.dart';

class AppUrls {
  static String get host {
    if (kIsWeb) return 'localhost';
   if (Platform.isAndroid) return '192.168.1.12';
   // if (Platform.isAndroid) return '10.0.2.2';
    return 'localhost';
  }

  static bool isLive = false;

  static String get baseUrl {
    try {
      if (isLive) return 'https://api.catchrideapp.com/api';
    } catch (_) {}
    return 'http://$host:5000/api';
  }

  static String get socketUrl {
    try {
      if (isLive) return 'https://api.catchrideapp.com';
    } catch (_) {}
    return 'http://$host:5000';
  }

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendOtp = '/auth/resend-otp';
  static const String logout = '/auth/logout';
  static const String googleLogin = '/auth/google';
  static const String appleLogin = '/auth/apple';
  static const String verifyToken = '/auth/verify';
  static const String sessions = '/auth/my-sessions';
  static const String terminateSession = '/auth/sessions/'; // + token
  static const String toggle2FA = '/auth/2fa/toggle';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyResetOtp = '/auth/verify-reset-otp';
  static const String resetPassword = '/auth/reset-password';

  // Horses
  static const String horses = '/horses';
  static const String horseDetails = '/horses/'; // + id

  // Bookings
  static const String bookings = '/bookings';
  static const String myBookings = '$bookings/my';

  // Trainers
  static const String trainers = '/trainers';
  static const String vendors = '/vendors';
  static const String availableServices = '$vendors/available-services';
  static const String myVendorProfile = '$vendors/me';

  // System Config (Tags)
  static const String systemConfig = '/system-config';
  static const String programTags = '$systemConfig/program-tags';
  static const String opportunityTags = '$systemConfig/opportunity-tags';
  static const String experienceLevels = '$systemConfig/experience-levels';
  static const String personalityTags = '$systemConfig/personality-tags';
  static const String tagTypesWithValues =
      '$systemConfig/tag-types/with-values';

  // Settings
  static const String settings = '/settings';

  // Horse Shows
  static const String horseShows = '/horse-shows';

  // Profile
  static const String profile = '/profile';
  static const String updateRole = '/profile/role';
  static const String completeProfile = '/profile/complete';
  static const String toggleNotifications = '/profile/toggle-notifications';
  static const String upload = '/upload';
  static const String uploadProfileImage = '/profile/upload-image';
  static const String changePassword = '/profile/password';
  static const String deleteAccount = '/users/'; // + id

  // Support
  static const String faqs = '/faq';
  static const String supportTickets = '/support-tickets';
  static const String conversations = '/messages/conversations';
  static const String messagesByConversation =
      '/messages/conversation/'; // + id + '/messages'
  static const String acceptChatRequest =
      '/messages/conversation/'; // + id + '/accept'
  static const String declineChatRequest =
      '/messages/conversation/'; // + id + '/decline'
  static const String blockUser = '/messages/user/'; // + userId + '/block'

  // Notifications
  static const String notifications = '/notifications';
  static const String feedback = '/feedback';

  static const String pages = '/pages';

  // Barn Manager
  static const String barnManagers = '/barn-managers';
  static const String inviteBarnManager = '$barnManagers/invite';
  static const String removeBarnManager = '$barnManagers/remove';
  static const String createVendorBooking = bookings;
}
