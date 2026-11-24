enum FeedbackStatus { draft, published }

class FeedbackModel {
  final String id;
  final String submissionId;
  final String teacherName;
  final String message;
  final FeedbackStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FeedbackModel({
    required this.id,
    required this.submissionId,
    required this.teacherName,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  FeedbackModel copyWith({
    String? message,
    FeedbackStatus? status,
    DateTime? updatedAt,
  }) {
    return FeedbackModel(
      id: id,
      submissionId: submissionId,
      teacherName: teacherName,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
