import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/state/academix_provider.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../models/notification_model.dart';
import '../assignments/student_assignments_screens.dart';
import '../evaluation/student_evaluation_screens.dart';

// Student Screen 13: Notifications
class StudentNotificationsScreen extends StatefulWidget {
  const StudentNotificationsScreen({super.key});

  @override
  State<StudentNotificationsScreen> createState() =>
      _StudentNotificationsScreenState();
}

class _StudentNotificationsScreenState
    extends State<StudentNotificationsScreen> {
  String _filter = 'All';

  IconData _iconFor(NotificationCategory cat) {
    switch (cat) {
      case NotificationCategory.announcement:
        return Icons.campaign_outlined;
      case NotificationCategory.submission:
        return Icons.upload_file_outlined;
      case NotificationCategory.evaluation:
        return Icons.verified_outlined;
      case NotificationCategory.feedback:
        return Icons.rate_review_outlined;
      case NotificationCategory.deadline:
        return Icons.alarm_outlined;
    }
  }

  Color _colorFor(NotificationCategory cat) {
    switch (cat) {
      case NotificationCategory.announcement:
        return AppColors.primaryBlue;
      case NotificationCategory.submission:
        return AppColors.darkBlue;
      case NotificationCategory.evaluation:
        return AppColors.success;
      case NotificationCategory.feedback:
        return AppColors.primaryBlue;
      case NotificationCategory.deadline:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademiXProvider>();
    final list = provider.currentNotifications.where((n) {
      if (_filter == 'Unread') return !n.isRead;
      if (_filter == 'Deadlines') {
        return n.category == NotificationCategory.deadline;
      }
      if (_filter == 'Evaluations') {
        return n.category == NotificationCategory.evaluation ||
            n.category == NotificationCategory.feedback;
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
                children: ['All', 'Unread', 'Deadlines', 'Evaluations'].map((f) {
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
            child: list.isEmpty
                ? const EmptyStateView(
                    icon: Icons.notifications_none_rounded,
                    title: 'All caught up',
                    description: 'No notifications match the selected filter.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final n = list[index];
                      final color = _colorFor(n.category);
                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          provider.markNotificationRead(n.id);
                          if (n.relatedSubmissionId != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => StudentEvaluationDetailScreen(
                                  submissionId: n.relatedSubmissionId!,
                                ),
                              ),
                            );
                          } else if (n.relatedAssignmentId != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => StudentAssignmentDetailScreen(
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
                                  : AppColors.primaryBlue.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(_iconFor(n.category),
                                    color: color, size: 20),
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
                                        height: 1.45,
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
