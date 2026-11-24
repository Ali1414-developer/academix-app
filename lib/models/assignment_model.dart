class AssignmentModel {
  final String id;
  final String? classId; // Linked Classroom ID
  final String? className;
  final String title;
  final String subject;
  final String courseCode;
  final String description;
  final List<String> instructions;
  final int totalMarks;
  final DateTime deadline;
  final List<String> allowedFormats;
  final String teacherName;
  final int totalStudentsEnrolled;
  final DateTime createdAt;
  final DateTime? evaluationTimeline;
  final String? rubricType;
  final String? rubricFileName;
  final String? rubricContent;
  final bool isEvaluationCompleted;

  const AssignmentModel({
    required this.id,
    this.classId,
    this.className,
    required this.title,
    required this.subject,
    required this.courseCode,
    required this.description,
    required this.instructions,
    required this.totalMarks,
    required this.deadline,
    required this.allowedFormats,
    required this.teacherName,
    this.totalStudentsEnrolled = 32,
    required this.createdAt,
    this.evaluationTimeline,
    this.rubricType,
    this.rubricFileName,
    this.rubricContent,
    this.isEvaluationCompleted = false,
  });

  bool get isOverdue => deadline.isBefore(DateTime.now());

  AssignmentModel copyWith({
    String? classId,
    String? className,
    String? title,
    String? subject,
    String? courseCode,
    String? description,
    List<String>? instructions,
    int? totalMarks,
    DateTime? deadline,
    List<String>? allowedFormats,
    String? teacherName,
    int? totalStudentsEnrolled,
    DateTime? evaluationTimeline,
    String? rubricType,
    String? rubricFileName,
    String? rubricContent,
    bool? isEvaluationCompleted,
  }) {
    return AssignmentModel(
      id: id,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      courseCode: courseCode ?? this.courseCode,
      description: description ?? this.description,
      instructions: instructions ?? this.instructions,
      totalMarks: totalMarks ?? this.totalMarks,
      deadline: deadline ?? this.deadline,
      allowedFormats: allowedFormats ?? this.allowedFormats,
      teacherName: teacherName ?? this.teacherName,
      totalStudentsEnrolled:
          totalStudentsEnrolled ?? this.totalStudentsEnrolled,
      createdAt: createdAt,
      evaluationTimeline: evaluationTimeline ?? this.evaluationTimeline,
      rubricType: rubricType ?? this.rubricType,
      rubricFileName: rubricFileName ?? this.rubricFileName,
      rubricContent: rubricContent ?? this.rubricContent,
      isEvaluationCompleted:
          isEvaluationCompleted ?? this.isEvaluationCompleted,
    );
  }
}
