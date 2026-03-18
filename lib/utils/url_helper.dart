import 'package:url_launcher/url_launcher.dart';

class UrlHelper {
  static Future<void> launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      // If parsing fails, try adding https://
      if (!url.startsWith('http')) {
        await launchURL('https://$url');
      } else {
        rethrow;
      }
    }
  }

  static Future<void> launchFacebook(String url) async {
    String formattedUrl = url.trim();
    if (formattedUrl.isEmpty) return;

    if (!formattedUrl.startsWith('http')) {
      formattedUrl = 'https://$formattedUrl';
    }
    await launchURL(formattedUrl);
  }

  static Future<void> launchInstagram(String handle) async {
    String username = handle.trim();
    if (username.isEmpty) return;

    if (username.startsWith('@')) {
      username = username.substring(1);
    }

    // Check if it's already a full URL
    if (username.contains('instagram.com')) {
      if (!username.startsWith('http')) {
        username = 'https://$username';
      }
      await launchURL(username);
      return;
    }

    final String url = 'https://www.instagram.com/$username/';
    await launchURL(url);
  }

  static Future<void> launchWebsite(String url) async {
    String formattedUrl = url.trim();
    if (formattedUrl.isEmpty) return;

    if (!formattedUrl.startsWith('http')) {
      formattedUrl = 'https://$formattedUrl';
    }
    await launchURL(formattedUrl);
  }
}
