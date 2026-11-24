enum UserRole { student, teacher }

class NotificationPreferences {
  final bool deadlineReminders;
  final bool evaluationUpdates;
  final bool feedbackAlerts;
  final bool announcements;
  final bool newSubmissionAlerts;

  const NotificationPreferences({
    this.deadlineReminders = true,
    this.evaluationUpdates = true,
    this.feedbackAlerts = true,
    this.announcements = true,
    this.newSubmissionAlerts = true,
  });

  NotificationPreferences copyWith({
    bool? deadlineReminders,
    bool? evaluationUpdates,
    bool? feedbackAlerts,
    bool? announcements,
    bool? newSubmissionAlerts,
  }) {
    return NotificationPreferences(
      deadlineReminders: deadlineReminders ?? this.deadlineReminders,
      evaluationUpdates: evaluationUpdates ?? this.evaluationUpdates,
      feedbackAlerts: feedbackAlerts ?? this.feedbackAlerts,
      announcements: announcements ?? this.announcements,
      newSubmissionAlerts: newSubmissionAlerts ?? this.newSubmissionAlerts,
    );
  }
}

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String password;
  final UserRole role;
  final String academicId; // Roll number for Student, Faculty ID for Teacher
  final String department;
  final String semesterOrDesignation;
  final String phone;
  final NotificationPreferences notificationPreferences;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
    required this.academicId,
    required this.department,
    required this.semesterOrDesignation,
    this.phone = '+92 300 4829104',
    this.notificationPreferences = const NotificationPreferences(),
  });

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : 'A';
  }

  UserModel copyWith({
    String? fullName,
    String? email,
    String? password,
    String? academicId,
    String? department,
    String? semesterOrDesignation,
    String? phone,
    NotificationPreferences? notificationPreferences,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role,
      academicId: academicId ?? this.academicId,
      department: department ?? this.department,
      semesterOrDesignation: semesterOrDesignation ?? this.semesterOrDesignation,
      phone: phone ?? this.phone,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
    );
  }
}
