import 'package:flutter/foundation.dart';

class AppUrls {
  /// Ngrok HTTPS origin (no trailing slash). From `ngrok http <backend-port>`.
  ///
  /// Override without editing:
  /// `flutter run --dart-define=NGROK_ORIGIN=https://xxxx.ngrok-free.dev`
  static const String devTunnelOrigin = String.fromEnvironment(
    'NGROK_ORIGIN',
    //    defaultValue: 'https://fremdly-monogenistic-collette.ngrok-free.dev',
          defaultValue: 'http://192.168.1.13:5000',
  );


  /// Production vs dev/ngrok — **false** uses [devTunnelOrigin] for API + sockets.
  static bool isLive = true;

  /// Hostname fragment for replacing `localhost` in legacy URLs (no scheme).
  static String get host {
    if (kIsWeb) return 'localhost';
    if (isLive) return 'api.catchrideapp.com';
    return Uri.parse(devTunnelOrigin).host;
  }

  static String get baseUrl {
    if (isLive) return 'https://api.catchrideapp.com/api';

    // Ngrok terminates TLS on 443 and forwards to your local :5000 — the public URL
    // must not include :5000 on the tunnel hostname or requests can hang until timeout.
    // For a device hitting a machine-only API, use e.g. `http://$host:5000/api` instead.
    final String origin =
        devTunnelOrigin.endsWith('/')
            ? devTunnelOrigin.substring(0, devTunnelOrigin.length - 1)
            : devTunnelOrigin;
    return '$origin/api';
  }

  static String get socketUrl {
    if (isLive) return 'https://api.catchrideapp.com';
    return devTunnelOrigin;
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
  static const String tagTypesWithValues = '$systemConfig/tag-types/with-values';

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
  static const String messagesByConversation = '/messages/conversation/'; // + id + '/messages'
  static const String acceptChatRequest = '/messages/conversation/'; // + id + '/accept'
  static const String declineChatRequest = '/messages/conversation/'; // + id + '/decline'
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

  // Locations
  static const String locationsSuggest = '/locations/suggest';
}
