enum ClassStatus { active, archived }

class ClassModel {
  final String id;
  final String name; // e.g. "Software Engineering - Fall 2026"
  final String subject; // e.g. "Software Engineering"
  final String courseCode; // e.g. "SE-301"
  final String? section; // e.g. "Section A"
  final String? semester; // e.g. "6th Semester"
  final String? academicYear; // e.g. "2026-2027"
  final String? description;
  final String teacherId;
  final String teacherName;
  final String classCode; // Unique joining code e.g. "ACX-7824"
  final List<String> enrolledStudentIds;
  final DateTime createdAt;
  final ClassStatus status;

  const ClassModel({
    required this.id,
    required this.name,
    required this.subject,
    required this.courseCode,
    this.section,
    this.semester,
    this.academicYear,
    this.description,
    required this.teacherId,
    required this.teacherName,
    required this.classCode,
    this.enrolledStudentIds = const [],
    required this.createdAt,
    this.status = ClassStatus.active,
  });

  bool get isArchived => status == ClassStatus.archived;
  int get enrolledCount => enrolledStudentIds.length;

  ClassModel copyWith({
    String? name,
    String? subject,
    String? courseCode,
    String? section,
    String? semester,
    String? academicYear,
    String? description,
    String? teacherId,
    String? teacherName,
    String? classCode,
    List<String>? enrolledStudentIds,
    DateTime? createdAt,
    ClassStatus? status,
  }) {
    return ClassModel(
      id: id,
      name: name ?? this.name,
      subject: subject ?? this.subject,
      courseCode: courseCode ?? this.courseCode,
      section: section ?? this.section,
      semester: semester ?? this.semester,
      academicYear: academicYear ?? this.academicYear,
      description: description ?? this.description,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      classCode: classCode ?? this.classCode,
      enrolledStudentIds: enrolledStudentIds ?? this.enrolledStudentIds,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}
