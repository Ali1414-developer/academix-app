import 'user_model.dart';

enum NotificationCategory {
  announcement,
  submission,
  evaluation,
  feedback,
  deadline,
}

class NotificationModel {
  final String id;
  final UserRole targetRole;
  final String title;
  final String message;
  final NotificationCategory category;
  final DateTime createdAt;
  final bool isRead;
  final String? relatedAssignmentId;
  final String? relatedSubmissionId;

  const NotificationModel({
    required this.id,
    required this.targetRole,
    required this.title,
    required this.message,
    required this.category,
    required this.createdAt,
    this.isRead = false,
    this.relatedAssignmentId,
    this.relatedSubmissionId,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      targetRole: targetRole,
      title: title,
      message: message,
      category: category,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      relatedAssignmentId: relatedAssignmentId,
      relatedSubmissionId: relatedSubmissionId,
    );
  }
}
