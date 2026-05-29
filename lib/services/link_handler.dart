import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/services/referral_service.dart';
import 'package:catch_ride/view/create_account_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LinkHandler extends GetxService {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  Future<LinkHandler> init() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint('Initial deep link received: $initialUri');
        // Cold start: save referral code immediately, do NOT navigate.
        // SplashScreen → checkAuthStatus() will check for pending referral
        // and route to CreateAccountView if the user is not logged in.
        _saveReferralFromUri(initialUri);
      } else {
        debugPrint('No initial deep link found at launch');
      }
    } catch (e) {
      debugPrint('Error getting initial link: $e');
    }

    // Warm start: app already running / in background (e.g. link tapped in Apple Notes).
    // Here we must both save AND navigate because checkAuthStatus() already ran.
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      debugPrint('Deep link stream event: $uri');
      handleDeepLink(uri);
    }, onError: (err) {
      debugPrint('Error listening to links: $err');
    });

    return this;
  }

  /// Extracts and persists the referral code from a URI without navigating.
  /// Used on cold start so checkAuthStatus() is the single navigation authority.
  void _saveReferralFromUri(Uri uri) {
    final referralCode = ReferralService.extractCodeFromUri(uri);
    if (referralCode != null) {
      ReferralService.to.saveReferralCode(referralCode);
      debugPrint('Referral saved from initial deep link: $referralCode');
    } else {
      debugPrint('Initial deep link had no extractable referral code');
    }
  }

  /// Handles deep links received while the app is already running (warm start).
  /// Saves the referral code AND navigates to CreateAccountView if needed.
  void handleDeepLink(Uri uri) {
    debugPrint('Handling deep link (warm): $uri');

    // Invite path on any host (ngrok dev or production)
    final isInvitePath = uri.path == '/invite' ||
        uri.path.startsWith('/invite/') ||
        uri.host == 'invite' ||
        (uri.scheme == 'catchride' && uri.host == 'invite');

    final referralCode = ReferralService.extractCodeFromUri(uri);
    if (referralCode != null || isInvitePath) {
      if (referralCode != null) {
        ReferralService.to.saveReferralCode(referralCode);
        debugPrint('Referral found from deep link: $referralCode');
      } else {
        debugPrint('Invite deep link received without referral code');
      }
      _navigateToSignupIfNeeded();
      return;
    }

    final screen = uri.queryParameters['screen'];
    final id = uri.queryParameters['id'];

    if (screen != null) {
      switch (screen) {
        case 'register':
        case 'signup':
          _navigateToSignupIfNeeded();
          break;
        case 'application_status':
          debugPrint('Navigating to Application Status');
          break;
        case 'home':
          debugPrint('Navigating to Home');
          break;
        case 'booking':
          debugPrint('Navigating to Booking ID: $id');
          break;
        case 'login':
          debugPrint('Navigating to Login');
          break;
        case 'support':
          debugPrint('Navigating to Support');
          break;
        case 'view_ticket':
        case 'reply_ticket':
          debugPrint('Navigating to Ticket ID: $id');
          break;
        default:
          debugPrint('Unknown screen in deep link: $screen');
      }
    }
  }

  void _navigateToSignupIfNeeded() {
    if (!Get.isRegistered<AuthController>()) {
      debugPrint('AuthController not registered yet; skipping signup redirect.');
      return;
    }
    final auth = Get.find<AuthController>();
    if (auth.isLoggedIn.value) {
      debugPrint('User already logged in; skipping signup redirect.');
      return;
    }

    debugPrint('Navigating to CreateAccountView with referral pre-fill');
    // Sync the referral code into the text controller before navigating
    auth.syncReferralCodeFromStorage();
    Future.microtask(() => Get.offAll(() => const CreateAccountView()));
  }

  @override
  void onClose() {
    _linkSubscription?.cancel();
    super.onClose();
  }
}
