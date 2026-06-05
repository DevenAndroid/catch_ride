import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/controllers/google_api_controller.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:catch_ride/models/show_venue_location.dart';
import 'package:catch_ride/utils/string_utils.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

/// Shared "Show Venue or City" field for vendor availability screens.
class VendorShowVenueSection extends StatelessWidget {
  final RxList<ShowVenueLocation> venues;
  final bool includeGooglePlaces;
  final EdgeInsets chipPadding;

  const VendorShowVenueSection({
    super.key,
    required this.venues,
    this.includeGooglePlaces = true,
    this.chipPadding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText(
          'Show Venue or City',
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 12),
        TextField(
          readOnly: true,
          onTap: () => VendorShowVenuePicker.open(
            venues: venues,
            includeGooglePlaces: includeGooglePlaces,
          ),
          decoration: InputDecoration(
            hintText: 'Select Show Venue or City',
            hintStyle: const TextStyle(color: Color(0xFF667085), fontSize: 14),
            suffixIcon: GestureDetector(
              onTap: () => VendorShowVenuePicker.open(
                venues: venues,
                includeGooglePlaces: includeGooglePlaces,
              ),
              child: const Icon(
                Icons.search,
                size: 20,
                color: Color(0xFF667085),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        Obx(() {
          if (venues.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: venues.map(_venueChip).toList(),
            ),
          );
        }),
      ],
    );
  }

  Widget _venueChip(ShowVenueLocation v) {
    final subtitle = v.displaySubtitle;
    return Container(
      padding: chipPadding,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CommonText(
                  v.displayLabel,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  CommonText(
                    subtitle,
                    fontSize: 11,
                    color: const Color(0xFF667085),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () =>
                venues.removeWhere((e) => e.selectionKey == v.selectionKey),
            child: const Icon(Icons.close, size: 14, color: Color(0xFF98A2B3)),
          ),
        ],
      ),
    );
  }
}

class VendorShowVenuePicker {
  static List<ShowVenueLocation>? _cachedVenues;

  static void open({
    required RxList<ShowVenueLocation> venues,
    bool includeGooglePlaces = true,
  }) {
    final profileController = Get.find<ProfileController>();
    if (profileController.rawHorseShows.isEmpty) {
      profileController.fetchMetadata();
    }
    final googleApiController = Get.isRegistered<GoogleApiController>()
        ? Get.find<GoogleApiController>()
        : Get.put(GoogleApiController());

    final searchController = TextEditingController();
    final searchText = ''.obs;
    final RxBool isParsing = false.obs;

    // Cache / Pre-parse the horse shows into ShowVenueLocation in the background using compute()
    void parseHorseShows() async {
      if (_cachedVenues != null &&
          _cachedVenues!.isNotEmpty &&
          _cachedVenues!.length == profileController.rawHorseShows.length) {
        return;
      }
      isParsing.value = true;
      try {
        final List<Map<String, dynamic>> listCopy = profileController.rawHorseShows.toList();
        final List<ShowVenueLocation> temp = await compute(_parseHorseShowsInBackground, listCopy);
        _cachedVenues = temp;
      } catch (e) {
        debugPrint('Error parsing horse shows in background: $e');
      } finally {
        isParsing.value = false;
      }
    }

    // Parse immediately on open if we already have data loaded
    if (profileController.rawHorseShows.isNotEmpty) {
      parseHorseShows();
    }

    Get.bottomSheet(
      Container(
        height: Get.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonText(
                  'Select Venue or City',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search venues or city...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (val) {
                searchText.value = val;
                if (includeGooglePlaces && val.length > 2) {
                  googleApiController.searchGooglePlaces(val);
                } else {
                  googleApiController.googleSuggestions.clear();
                }
              },
            ),
            const SizedBox(height: 20),
            Obx(() {
              if ((profileController.isLoadingMetadata.value &&
                  profileController.rawHorseShows.isEmpty) || isParsing.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (includeGooglePlaces)
                      Obx(() {
                        final suggestions =
                            googleApiController.googleSuggestions;
                        if (suggestions.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 16, bottom: 8),
                              child: CommonText(
                                'Cities',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            ...suggestions.map((g) {
                              final formatted = g['name'] ?? '';
                              final entry = ShowVenueLocation
                                  .fromGoogleFormattedName(
                                formatted.toString(),
                                useAsName: true,
                              );
                              return Obx(() {
                                final isSelected =
                                    ShowVenueLocation.containsVenue(
                                  venues,
                                  entry,
                                );
                                return CheckboxListTile(
                                  value: isSelected,
                                  onChanged: (selected) {
                                    ShowVenueLocation.toggleVenue(
                                      venues,
                                      entry,
                                      selected == true,
                                    );
                                  },
                                  title: CommonText(entry.displayLabel),
                                  subtitle: entry.displaySubtitle != null
                                      ? CommonText(
                                          entry.displaySubtitle!,
                                          fontSize: 12,
                                          color: Colors.grey,
                                        )
                                      : null,
                                  activeColor: const Color(0xFF030D3B),
                                );
                              });
                            }),
                            const Divider(),
                          ],
                        );
                      }),
                    Obx(() {
                      if (isParsing.value) {
                        return const SizedBox.shrink();
                      }
                      final search = searchText.value.normalizeQuotes().toLowerCase();
                      
                      // In case rawHorseShows finished loading asynchronously after sheet opened
                      if ((_cachedVenues == null || _cachedVenues!.isEmpty) && profileController.rawHorseShows.isNotEmpty && !isParsing.value) {
                        Future.microtask(() => parseHorseShows());
                        return const Center(child: CircularProgressIndicator());
                      }

                      final horseShowVenues = <ShowVenueLocation>[];
                      final sourceList = _cachedVenues ?? [];
                      if (search.isEmpty) {
                        horseShowVenues.addAll(sourceList);
                      } else {
                        for (final entry in sourceList) {
                          final hay = '${entry.displayLabel} ${entry.location}'.normalizeQuotes().toLowerCase();
                          if (hay.contains(search)) {
                            horseShowVenues.add(entry);
                          }
                        }
                      }

                      if (horseShowVenues.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CommonText('No venues found'),
                          ),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 16, bottom: 8),
                            child: CommonText(
                              'Venues',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          ...horseShowVenues.map((entry) {
                            return Obx(() {
                              final isSelected =
                                  ShowVenueLocation.containsVenue(
                                venues,
                                entry,
                              );
                              return CheckboxListTile(
                                value: isSelected,
                                onChanged: (selected) {
                                  ShowVenueLocation.toggleVenue(
                                    venues,
                                    entry,
                                    selected == true,
                                  );
                                },
                                title: CommonText(entry.displayLabel),
                                subtitle: entry.displaySubtitle != null
                                    ? CommonText(
                                        entry.displaySubtitle!,
                                        fontSize: 12,
                                        color: Colors.grey,
                                      )
                                    : null,
                                activeColor: const Color(0xFF030D3B),
                              );
                            });
                          }),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: const BorderSide(color: Color(0xFFD0D5DD)),
                    ),
                    child: const CommonText('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const CommonText('Done', color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

/// Pure top-level background parsing function for compute() background isolate execution.
List<ShowVenueLocation> _parseHorseShowsInBackground(List<Map<String, dynamic>> rawHorseShows) {
  final List<ShowVenueLocation> temp = [];
  final seenKeys = <String>{};
  for (final show in rawHorseShows) {
    final venueName = show['showVenue']?.toString() ?? show['name']?.toString() ?? '';
    final city = show['city']?.toString() ?? '';
    final state = show['state']?.toString() ?? '';
    final country = show['country']?.toString() ?? '';
    
    final List<String> locParts = [];
    if (city.trim().isNotEmpty) locParts.add(city.trim());
    if (state.trim().isNotEmpty) locParts.add(state.trim());
    if (country.trim().isNotEmpty) locParts.add(country.trim());
    final loc = locParts.join(', ');

    final key = '${venueName.trim().toLowerCase()}|${loc.trim().toLowerCase()}';
    if (venueName.trim().isEmpty && loc.trim().isEmpty) continue;
    if (venueName.trim() == 'Unknown') continue;
    if (seenKeys.contains(key)) continue;
    seenKeys.add(key);
    temp.add(ShowVenueLocation(name: venueName, location: loc));
  }
  return temp;
}
