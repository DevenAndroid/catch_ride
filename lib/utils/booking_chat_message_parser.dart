import 'dart:convert';

/// Parses backend-generated booking messages into structured fields for chat UI.
class ParsedBookingApprovalMessage {
  final String horseName;
  final String dateRaw;
  final String? notes;

  ParsedBookingApprovalMessage({
    required this.horseName,
    required this.dateRaw,
    this.notes,
  });
}

class ParsedBookingDeclineMessage {
  final String horseName;
  final String dateRaw;
  final String? reason;

  ParsedBookingDeclineMessage({
    required this.horseName,
    required this.dateRaw,
    this.reason,
  });
}

class ParsedBookingPendingMessage {
  final String horseName;
  final String dateRaw;

  ParsedBookingPendingMessage({
    required this.horseName,
    required this.dateRaw,
  });
}

class ParsedBookingUpdateMessage {
  final String horseName;
  final String date;
  final String? location;
  final String? notes;
  final String? startTime;
  final String? endTime;

  ParsedBookingUpdateMessage({
    required this.horseName,
    required this.date,
    this.location,
    this.notes,
    this.startTime,
    this.endTime,
  });
}

class BookingChatMessageParser {
  /// "Booking confirmed for {horse} on {date}." (barn access grant / team confirm)
  static ParsedBookingApprovalMessage? parseConfirmed(String content) {
    const prefix = 'Booking confirmed for ';
    if (!content.startsWith(prefix)) return null;

    var remainder = content.substring(prefix.length).trim();
    final accessIdx = remainder.indexOf('. ');
    if (accessIdx >= 0) {
      remainder = remainder.substring(0, accessIdx + 1);
    } else if (remainder.endsWith('.')) {
      // keep trailing period for marker match below
    }

    const marker = ' on ';
    final onIdx = remainder.lastIndexOf(marker);
    if (onIdx < 0) return null;

    var horseName = remainder.substring(0, onIdx).trim();
    var dateRaw = remainder.substring(onIdx + marker.length).trim();
    if (dateRaw.endsWith('.')) dateRaw = dateRaw.substring(0, dateRaw.length - 1).trim();
    if (horseName.isEmpty || dateRaw.isEmpty) return null;

    return ParsedBookingApprovalMessage(
      horseName: horseName,
      dateRaw: dateRaw,
      notes: null,
    );
  }

  static ParsedBookingApprovalMessage? parseApproval(String content) {
    const prefix = 'Your booking request for ';
    const marker = ' has been approved.';
    if (!content.startsWith(prefix) || !content.contains(marker)) return null;

    final afterPrefix = content.substring(prefix.length);
    final markerIdx = afterPrefix.indexOf(marker);
    if (markerIdx < 0) return null;

    final core = afterPrefix.substring(0, markerIdx);
    var remainder = afterPrefix.substring(markerIdx + marker.length).trim();

    String? notes;
    if (remainder.startsWith('Notes:')) {
      notes = remainder.substring('Notes:'.length).trim();
    }

    final onIdx = core.lastIndexOf(' on ');
    if (onIdx < 0) return null;

    final horseName = core.substring(0, onIdx).trim();
    final dateRaw = core.substring(onIdx + ' on '.length).trim();
    if (horseName.isEmpty || dateRaw.isEmpty) return null;

    return ParsedBookingApprovalMessage(
      horseName: horseName,
      dateRaw: dateRaw,
      notes: notes,
    );
  }

  static ParsedBookingDeclineMessage? parseDecline(String content) {
    const prefix = 'Your booking request for ';
    const marker = ' has been declined.';
    if (!content.startsWith(prefix) || !content.contains(marker)) return null;

    final afterPrefix = content.substring(prefix.length);
    final markerIdx = afterPrefix.indexOf(marker);
    if (markerIdx < 0) return null;

    final core = afterPrefix.substring(0, markerIdx);
    var remainder = afterPrefix.substring(markerIdx + marker.length).trim();

    String? reason;
    if (remainder.startsWith('Reason:')) {
      reason = remainder.substring('Reason:'.length).trim();
    }

    final onIdx = core.lastIndexOf(' on ');
    if (onIdx < 0) return null;

    final horseName = core.substring(0, onIdx).trim();
    final dateRaw = core.substring(onIdx + ' on '.length).trim();
    if (horseName.isEmpty || dateRaw.isEmpty) return null;

    return ParsedBookingDeclineMessage(
      horseName: horseName,
      dateRaw: dateRaw,
      reason: reason,
    );
  }

  /// Expects content with `[System]:` already stripped.
  static ParsedBookingPendingMessage? parsePending(String content) {
    const prefix = 'Booking request submitted for ';
    const suffix = '. Waiting for professional approval.';
    var trimmed = content.trim();
    // Some builds append e.g. `[BOOKING_REF:...]` after the sentence; that
    // breaks a strict endsWith(suffix) check and hides the chat card.
    final refIdx = trimmed.indexOf('[BOOKING_REF:');
    if (refIdx >= 0) {
      trimmed = trimmed.substring(0, refIdx).trim();
    }
    if (!trimmed.startsWith(prefix) || !trimmed.endsWith(suffix)) return null;

    final middle =
        trimmed.substring(prefix.length, trimmed.length - suffix.length);
    final onIdx = middle.lastIndexOf(' on ');
    if (onIdx < 0) return null;

    final horseName = middle.substring(0, onIdx).trim();
    final dateRaw = middle.substring(onIdx + ' on '.length).trim();
    if (horseName.isEmpty || dateRaw.isEmpty) return null;

    return ParsedBookingPendingMessage(
      horseName: horseName,
      dateRaw: dateRaw,
    );
  }

  /// JSON block may be prefixed by a human-readable line (inbox preview).
  static ParsedBookingUpdateMessage? parseUpdate(String content) {
    const marker = '[BOOKING_CARD:UPDATE]\n';
    final idx = content.indexOf(marker);
    if (idx < 0) return null;
    try {
      final jsonStr = content.substring(idx + marker.length).trim();
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      final horseName = map['horseName']?.toString().trim() ?? '';
      final date = map['date']?.toString().trim() ?? '';
      if (horseName.isEmpty || date.isEmpty) return null;

      String? pick(String k) {
        final v = map[k]?.toString();
        if (v == null || v.trim().isEmpty) return null;
        return v.trim();
      }

      return ParsedBookingUpdateMessage(
        horseName: horseName,
        date: date,
        location: pick('location'),
        notes: pick('notes'),
        startTime: pick('startTime'),
        endTime: pick('endTime'),
      );
    } catch (_) {
      return null;
    }
  }
}
