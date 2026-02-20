import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/vendor/inbox/vendor_inbox_models.dart';
import 'package:catch_ride/view/vendor/inbox/vendor_chat_detail_screen.dart';

class VendorInboxScreen extends StatefulWidget {
  const VendorInboxScreen({super.key});

  @override
  State<VendorInboxScreen> createState() => _VendorInboxScreenState();
}

class _VendorInboxScreenState extends State<VendorInboxScreen> {
  String _activeFilter = 'All';

  List<VendorThread> get _filtered {
    switch (_activeFilter) {
      case 'Unread':
        return mockVendorThreads.where((t) => t.isUnread).toList();
      case 'Bookings':
        return mockVendorThreads
            .where((t) => t.hasSystemMessage || t.relatedBookingId != null)
            .toList();
      case 'Trainers':
        return mockVendorThreads
            .where((t) => t.participantRole == VendorParticipantRole.trainer)
            .toList();
      case 'Barn Mgrs':
        return mockVendorThreads
            .where(
              (t) => t.participantRole == VendorParticipantRole.barnManager,
            )
            .toList();
      default:
        return mockVendorThreads;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: open search delegate
            },
          ),
        ],
      ),
      // ── NO FAB: vendors cannot create threads independently (MVP rule) ──
      body: Column(
        children: [
          // ── Restriction Info Banner ─────────────────────────────────────
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.deepNavy.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.deepNavy.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.deepNavy,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You can reply to existing conversations. Trainers or Barn Managers must initiate new threads.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.deepNavy,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ── Filter Chips ────────────────────────────────────────────────
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: ['All', 'Unread', 'Bookings', 'Trainers', 'Barn Mgrs']
                  .map(
                    (f) => _InboxFilterChip(
                      label: f,
                      isSelected: _activeFilter == f,
                      onTap: () => setState(() => _activeFilter = f),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 4),

          // ── Thread List ─────────────────────────────────────────────────
          Expanded(
            child: _filtered.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 80),
                    itemBuilder: (context, index) {
                      final thread = _filtered[index];
                      return _ThreadTile(
                        thread: thread,
                        onTap: () => Get.to(
                          () => VendorChatDetailScreen(thread: thread),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, size: 64, color: AppColors.grey300),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.grey500),
          ),
          const SizedBox(height: 8),
          Text(
            'Conversations will appear here once a\ntrainer or barn manager contacts you.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey400),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Thread Tile
// ─────────────────────────────────────────────────────────────────────────────

class _ThreadTile extends StatelessWidget {
  final VendorThread thread;
  final VoidCallback onTap;

  const _ThreadTile({required this.thread, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isBM = thread.participantRole == VendorParticipantRole.barnManager;
    final initials = thread.participantName
        .split(' ')
        .take(2)
        .map((p) => p[0])
        .join();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar + role badge ──
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: isBM
                      ? AppColors.mutedGold.withOpacity(0.18)
                      : AppColors.deepNavy.withOpacity(0.12),
                  child: Text(
                    initials,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: isBM ? AppColors.mutedGold : AppColors.deepNavy,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isBM ? AppColors.mutedGold : AppColors.deepNavy,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      isBM ? 'BM' : 'TR',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),

            // ── Content ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        thread.participantName,
                        style: thread.isUnread
                            ? AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              )
                            : AppTextStyles.titleMedium,
                      ),
                      Text(
                        thread.time,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: thread.isUnread
                              ? AppColors.deepNavy
                              : AppColors.grey500,
                          fontWeight: thread.isUnread
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // System message pill
                  if (thread.hasSystemMessage &&
                      thread.systemMessageText != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.deepNavy.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.deepNavy.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.bookmark_border_rounded,
                            size: 12,
                            color: AppColors.deepNavy,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            thread.systemMessageText!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.deepNavy,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],

                  // Preview + unread dot
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          thread.previewText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: thread.isUnread
                                ? AppColors.textPrimary
                                : AppColors.grey600,
                            fontWeight: thread.isUnread
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (thread.isUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.deepNavy,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Animated Filter Chip
// ─────────────────────────────────────────────────────────────────────────────

class _InboxFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _InboxFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.deepNavy : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.deepNavy : AppColors.grey300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.deepNavy,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
