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
  static const String logout = '/auth/logout';
  static const String verifyToken = '/auth/verify';

  // Horses
  static const String horses = '/horses';
  static const String horseDetails = '/horses/'; // + id

  // Bookings
  static const String bookings = '/bookings';
  static const String myBookings = '$bookings/my';
  
  // Trainers
  static const String trainers = '/trainers';
  static const String vendors = '/vendors';

  // System Config (Tags)
  static const String systemConfig = '/system-config';
  static const String programTags = '$systemConfig/program-tags';
  static const String opportunityTags = '$systemConfig/opportunity-tags';
  static const String experienceLevels = '$systemConfig/experience-levels';
  static const String personalityTags = '$systemConfig/personality-tags';

  // Horse Shows
  static const String horseShows = '/horse-shows';

  // Profile
  static const String profile = '/profile';
  static const String updateRole = '/profile/role';
  static const String completeProfile = '/profile/complete';
  static const String upload = '/upload';
  static const String uploadProfileImage = '/profile/upload-image';
  
  // Support
  static const String faqs = '/faq';
  static const String supportTickets = '/support-tickets';
  static const String conversations = '/messages/conversations';
  static const String messagesByConversation = '/messages/conversation/'; // + id + '/messages'
  static const String acceptChatRequest = '/messages/conversation/'; // + id + '/accept'
  static const String declineChatRequest = '/messages/conversation/'; // + id + '/decline'
  static const String blockUser = '/messages/user/'; // + userId + '/block'

}
