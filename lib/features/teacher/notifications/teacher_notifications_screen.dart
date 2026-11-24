import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/state/academix_provider.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../models/notification_model.dart';
import '../assignments/teacher_assignments_screens.dart';
import '../evaluation/teacher_evaluation_screens.dart';

// Teacher Screen 14: Notifications
class TeacherNotificationsScreen extends StatefulWidget {
  const TeacherNotificationsScreen({super.key});

  @override
  State<TeacherNotificationsScreen> createState() =>
      _TeacherNotificationsScreenState();
}

class _TeacherNotificationsScreenState
    extends State<TeacherNotificationsScreen> {
  String _filter = 'All';

  IconData _iconFor(NotificationCategory cat) {
    switch (cat) {
      case NotificationCategory.submission:
        return Icons.inbox_outlined;
      case NotificationCategory.evaluation:
        return Icons.pending_actions_rounded;
      case NotificationCategory.deadline:
        return Icons.event_outlined;
      case NotificationCategory.feedback:
        return Icons.rate_review_outlined;
      case NotificationCategory.announcement:
        return Icons.campaign_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademiXProvider>();
    final items = provider.currentNotifications.where((n) {
      if (_filter == 'Unread') return !n.isRead;
      if (_filter == 'Submissions') {
        return n.category == NotificationCategory.submission;
      }
      if (_filter == 'Deadlines') {
        return n.category == NotificationCategory.deadline;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (provider.unreadNotificationCount > 0)
            TextButton(
              onPressed: provider.markAllNotificationsRead,
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Unread', 'Submissions', 'Deadlines']
                    .map((f) {
                  final active = _filter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(f),
                      selected: active,
                      onSelected: (_) => setState(() => _filter = f),
                      selectedColor: AppColors.primaryBlue,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: active ? AppColors.white : AppColors.primaryText,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: items.isEmpty
                ? const EmptyStateView(
                    icon: Icons.notifications_none_rounded,
                    title: 'No alerts found',
                    description: 'You are up to date on all faculty alerts.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final n = items[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          provider.markNotificationRead(n.id);
                          if (n.relatedSubmissionId != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TeacherSubmissionReviewScreen(
                                  submissionId: n.relatedSubmissionId!,
                                ),
                              ),
                            );
                          } else if (n.relatedAssignmentId != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TeacherAssignmentDetailScreen(
                                  assignmentId: n.relatedAssignmentId!,
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: n.isRead
                                ? AppColors.white
                                : AppColors.lightBlue.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: n.isRead
                                  ? AppColors.border
                                  : AppColors.primaryBlue
                                      .withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.lightBlue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  _iconFor(n.category),
                                  color: AppColors.primaryBlue,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            n.title,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: n.isRead
                                                  ? FontWeight.w500
                                                  : FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          formatRelativeTime(n.createdAt),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.secondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      n.message,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
