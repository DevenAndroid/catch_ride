import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';

class GoogleApiController extends GetxController {
  final RxList<Map<String, String>> googleSuggestions =
      <Map<String, String>>[].obs;
  final RxInt refreshInt = 0.obs;

  static const Map<String, String> _usStates = {
    'AL': 'Alabama', 'AK': 'Alaska', 'AZ': 'Arizona', 'AR': 'Arkansas', 'CA': 'California',
    'CO': 'Colorado', 'CT': 'Connecticut', 'DE': 'Delaware', 'FL': 'Florida', 'GA': 'Georgia',
    'HI': 'Hawaii', 'ID': 'Idaho', 'IL': 'Illinois', 'IN': 'Indiana', 'IA': 'Iowa',
    'KS': 'Kansas', 'KY': 'Kentucky', 'LA': 'Louisiana', 'ME': 'Maine', 'MD': 'Maryland',
    'MA': 'Massachusetts', 'MI': 'Michigan', 'MN': 'Minnesota', 'MS': 'Mississippi', 'MO': 'Missouri',
    'MT': 'Montana', 'NE': 'Nebraska', 'NV': 'Nevada', 'NH': 'New Hampshire', 'NJ': 'New Jersey',
    'NM': 'New Mexico', 'NY': 'New York', 'NC': 'North Carolina', 'ND': 'North Dakota', 'OH': 'Ohio',
    'OK': 'Oklahoma', 'OR': 'Oregon', 'PA': 'Pennsylvania', 'RI': 'Rhode Island', 'SC': 'South Carolina',
    'SD': 'South Dakota', 'TN': 'Tennessee', 'TX': 'Texas', 'UT': 'Utah', 'VT': 'Vermont',
    'VA': 'Virginia', 'WA': 'Washington', 'WV': 'West Virginia', 'WI': 'Wisconsin', 'WY': 'Wyoming',
    'DC': 'District of Columbia',
  };

  String _formatAddress(String description) {
    if (description.isEmpty) return description;
    List<String> parts = description.split(',').map((e) => e.trim()).toList();
    for (int i = 0; i < parts.length; i++) {
      String upperPart = parts[i].toUpperCase();
      if (_usStates.containsKey(upperPart)) {
        parts[i] = _usStates[upperPart]!;
      }
    }
    return parts.join(', ');
  }

  Future<void> searchGooglePlaces(String query, {String? location, int? radius}) async {
    if (query.trim().isEmpty) {
      googleSuggestions.clear();
      return;
    }

    try {
      String url = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$googleApiKey&components=country:us|country:ca";
      
      if (location != null && radius != null) {
        url += "&location=$location&radius=$radius&strictbounds=true";
      }

      final response = await http.get(Uri.parse(url));
      log(jsonEncode(jsonDecode(response.body)));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List predictions = data['predictions'] ?? [];
        final List<Map<String, String>> suggestions = predictions.map((p) {
          String description = p['description']?.toString() ?? '';
          return {
            'name': _formatAddress(description),
            'place_id': p['place_id']?.toString() ?? '',
          };
        }).toList();

        googleSuggestions.assignAll(suggestions);
      }
      refreshInt.value = DateTime.now().millisecondsSinceEpoch;
    } catch (e) {
      debugPrint('Error searching Google Places: $e');
    }
  }

  Future<void> openSMS(String phoneNo) async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNo,
      queryParameters: {
        'body': '', // optional
      },
    );

    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(
          smsUri,
          mode: LaunchMode.externalApplication, // IMPORTANT
        );
      } else {
        throw 'SMS not supported';
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not open messaging app');
    }
  }
}
