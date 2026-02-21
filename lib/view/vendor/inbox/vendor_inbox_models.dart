// vendor_inbox_models.dart
// Shared data models for Vendor Inbox & Chat Detail

enum VendorParticipantRole { trainer, barnManager }

class VendorThread {
  final String id;
  final String participantName;
  final VendorParticipantRole participantRole;
  final String previewText;
  final String time;
  final bool isUnread;
  final bool hasSystemMessage;
  final String? systemMessageText;
  final String? relatedBookingId;
  final String? relatedLoadId;

  const VendorThread({
    required this.id,
    required this.participantName,
    required this.participantRole,
    required this.previewText,
    required this.time,
    this.isUnread = false,
    this.hasSystemMessage = false,
    this.systemMessageText,
    this.relatedBookingId,
    this.relatedLoadId,
  });
}

// Mock threads — replace with API calls
final mockVendorThreads = [
  const VendorThread(
    id: 't1',
    participantName: 'Sarah Williams',
    participantRole: VendorParticipantRole.trainer,
    previewText:
        'Interested in the Wellington → Lexington run. Do you have room for 2?',
    time: 'Just now',
    isUnread: true,
    hasSystemMessage: true,
    systemMessageText: 'Load Inquiry',
    relatedLoadId: 'L-101',
  ),
  const VendorThread(
    id: 't2',
    participantName: 'Emily Johnson',
    participantRole: VendorParticipantRole.barnManager,
    previewText: 'Sent you a booking request for the Ocala trip.',
    time: '2:15 PM',
    isUnread: true,
    hasSystemMessage: true,
    systemMessageText: 'Booking Request',
    relatedBookingId: 'BK-002',
  ),
  const VendorThread(
    id: 't3',
    participantName: 'Michael Davis',
    participantRole: VendorParticipantRole.trainer,
    previewText: 'Slot confirmed. We will be ready for pickup at 8am.',
    time: '11:30 AM',
    hasSystemMessage: true,
    systemMessageText: 'Slot Confirmed',
    relatedBookingId: 'BK-003',
  ),
  const VendorThread(
    id: 'sh-1',
    participantName: 'Lisa Chen',
    participantRole: VendorParticipantRole.trainer,
    previewText: 'Is there a layover included in this route?',
    time: 'Yesterday',
    hasSystemMessage: true,
    systemMessageText: 'Load Inquiry',
    relatedLoadId: 'L-102',
  ),
  const VendorThread(
    id: 't5',
    participantName: 'Rachel Brooks',
    participantRole: VendorParticipantRole.barnManager,
    previewText: 'Do you come out to Ocala for shows?',
    time: 'Feb 17',
  ),
];
