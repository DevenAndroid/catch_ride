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
  });
}

// Mock threads — replace with API calls
final mockVendorThreads = [
  const VendorThread(
    id: 't1',
    participantName: 'Sarah Williams',
    participantRole: VendorParticipantRole.trainer,
    previewText: 'Hi, are you available for grooming on March 5th?',
    time: 'Just now',
    isUnread: true,
    hasSystemMessage: true,
    systemMessageText: 'New booking request from Sarah Williams',
    relatedBookingId: 'BK-001',
  ),
  const VendorThread(
    id: 't2',
    participantName: 'Emily Johnson',
    participantRole: VendorParticipantRole.barnManager,
    previewText: 'Can you do braiding for two horses at WEF?',
    time: '2:15 PM',
    isUnread: true,
  ),
  const VendorThread(
    id: 't3',
    participantName: 'Michael Davis',
    participantRole: VendorParticipantRole.trainer,
    previewText: 'Great, I\'ll confirm the booking then!',
    time: '11:30 AM',
    hasSystemMessage: true,
    systemMessageText: 'Booking accepted',
    relatedBookingId: 'BK-002',
  ),
  const VendorThread(
    id: 't4',
    participantName: 'Lisa Chen',
    participantRole: VendorParticipantRole.trainer,
    previewText: 'Do you travel to Ocala for shows?',
    time: 'Yesterday',
  ),
  const VendorThread(
    id: 't5',
    participantName: 'Rachel Brooks',
    participantRole: VendorParticipantRole.barnManager,
    previewText: 'What\'s your rate for a full show weekend?',
    time: 'Feb 17',
  ),
];
