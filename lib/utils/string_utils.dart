class StringUtils {
  /// Ensures consistent service capitalization where the first letter of each word
  /// is capitalized (e.g., "Sports Massage" instead of "Sports massage" or "Red Light" instead of "red light").
  /// Known acronyms like PEMF are preserved in full uppercase.
  static String capitalizeServiceWords(String text) {
    if (text == null || text.trim().isEmpty) return '';
    return text.trim().split(RegExp(r'\s+')).map((word) {
      if (word.isEmpty) return word;
      final upper = word.toUpperCase();
      if (upper == 'PEMF' || upper == 'CDL' || upper == 'USDOT' || (word.length > 1 && word == upper)) {
        return upper;
      }
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Normalizes smart quotes/curly apostrophes to standard ones for robust searching.
  static String normalizeQuotes(String text) {
    return text
        .replaceAll('’', "'")
        .replaceAll('‘', "'")
        .replaceAll('“', '"')
        .replaceAll('”', '"');
  }
}

extension StringNormalizeExtension on String {
  String normalizeQuotes() {
    return this
        .replaceAll('’', "'")
        .replaceAll('‘', "'")
        .replaceAll('“', '"')
        .replaceAll('”', '"');
  }
}
