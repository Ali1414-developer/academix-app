import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/assignment_model.dart';
import '../../models/class_model.dart';
import '../../models/evaluation_model.dart';
import '../../models/feedback_model.dart';
import '../../models/notification_model.dart';
import '../../models/submission_model.dart';
import '../../models/user_model.dart';
import '../mock_data/mock_data.dart';

class AcademiXProvider extends ChangeNotifier {
  final List<UserModel> _users = MockData.initialUsers();
  final List<ClassModel> _classes = MockData.initialClasses();
  final List<AssignmentModel> _assignments = MockData.initialAssignments();
  final List<SubmissionModel> _submissions = MockData.initialSubmissions();
  final List<NotificationModel> _notifications = MockData.initialNotifications();

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  List<ClassModel> get classes => List.unmodifiable(_classes);
  List<AssignmentModel> get assignments => List.unmodifiable(_assignments);
  List<SubmissionModel> get submissions => List.unmodifiable(_submissions);
  List<UserModel> get users => List.unmodifiable(_users);

  List<NotificationModel> get currentNotifications {
    if (_currentUser == null) return [];
    return _notifications
        .where((n) => n.targetRole == _currentUser!.role)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  int get unreadNotificationCount =>
      currentNotifications.where((n) => !n.isRead).length;

  // --- Authentication ---

  String? login({
    required String email,
    required String password,
    UserRole? selectedRole,
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    final match = _users.where((u) => u.email.toLowerCase() == normalizedEmail);

    if (match.isEmpty) {
      return 'No account found with this email. Try a demo account or register.';
    }

    final user = match.first;
    if (user.password != password) {
      return 'Incorrect password. Use "password123" for demo accounts.';
    }

    if (selectedRole != null && user.role != selectedRole) {
      final expected =
          user.role == UserRole.student ? 'Student' : 'Teacher';
      return 'This account belongs to the $expected Portal. Switch the role tab to continue.';
    }

    _currentUser = user;
    notifyListeners();
    return null;
  }

  void quickLogin(UserRole role) {
    _currentUser = _users.firstWhere((u) => u.role == role);
    notifyListeners();
  }

  String? registerUser({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
    required String academicId,
    required String department,
    required String semesterOrDesignation,
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    final exists =
        _users.any((u) => u.email.toLowerCase() == normalizedEmail);
    if (exists) {
      return 'An account with this email already exists.';
    }

    final newUser = UserModel(
      id: '${role == UserRole.student ? 'stu' : 'tch'}-${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName.trim(),
      email: normalizedEmail,
      password: password,
      role: role,
      academicId: academicId.trim(),
      department: department.trim(),
      semesterOrDesignation: semesterOrDesignation.trim(),
    );
    _users.add(newUser);
    _currentUser = newUser;
    notifyListeners();
    return null;
  }

  String? resetPasswordByEmail(String email, String newPassword) {
    final idx = _users
        .indexWhere((u) => u.email.toLowerCase() == email.trim().toLowerCase());
    if (idx == -1) {
      return 'Account not found for $email.';
    }
    _users[idx] = _users[idx].copyWith(password: newPassword);
    if (_currentUser?.id == _users[idx].id) {
      _currentUser = _users[idx];
    }
    notifyListeners();
    return null;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // --- Profile & Settings ---

  void updateProfile({
    required String fullName,
    required String department,
    required String semesterOrDesignation,
    required String phone,
  }) {
    if (_currentUser == null) return;
    final updated = _currentUser!.copyWith(
      fullName: fullName.trim(),
      department: department.trim(),
      semesterOrDesignation: semesterOrDesignation.trim(),
      phone: phone.trim(),
    );
    _replaceUser(updated);
  }

  String? changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    if (_currentUser == null) return 'Not authenticated.';
    if (_currentUser!.password != currentPassword) {
      return 'Current password does not match.';
    }
    _replaceUser(_currentUser!.copyWith(password: newPassword));
    return null;
  }

  void updateNotificationPreferences(NotificationPreferences prefs) {
    if (_currentUser == null) return;
    _replaceUser(_currentUser!.copyWith(notificationPreferences: prefs));
  }

  void _replaceUser(UserModel updated) {
    final idx = _users.indexWhere((u) => u.id == updated.id);
    if (idx != -1) {
      _users[idx] = updated;
    }
    _currentUser = updated;
    notifyListeners();
  }

  // --- Assignments (Shared Student & Teacher) ---

  AssignmentModel? getAssignmentById(String id) {
    for (final a in _assignments) {
      if (a.id == id) return a;
    }
    return null;
  }

  void createAssignment({
    String? classId,
    String? className,
    required String title,
    required String subject,
    required String courseCode,
    required String description,
    required List<String> instructions,
    required int totalMarks,
    required DateTime deadline,
    required List<String> allowedFormats,
    DateTime? evaluationTimeline,
    String? rubricType,
    String? rubricFileName,
    String? rubricContent,
  }) {
    int enrolled = 32;
    if (classId != null) {
      final matchedClass = _classes.firstWhere((c) => c.id == classId, orElse: () => _classes.first);
      enrolled = matchedClass.enrolledCount;
    }

    final newAssignment = AssignmentModel(
      id: 'asg-${DateTime.now().millisecondsSinceEpoch}',
      classId: classId,
      className: className,
      title: title.trim(),
      subject: subject.trim(),
      courseCode: courseCode.trim().isEmpty ? 'SE-399' : courseCode.trim(),
      description: description.trim(),
      instructions: instructions.isEmpty
          ? ['Follow academic integrity guidelines and submit before deadline.']
          : instructions,
      totalMarks: totalMarks,
      deadline: deadline,
      allowedFormats: allowedFormats.isEmpty ? ['PDF'] : allowedFormats,
      teacherName: _currentUser?.fullName ?? 'Dr. Usman Tariq',
      totalStudentsEnrolled: enrolled > 0 ? enrolled : 1,
      createdAt: DateTime.now(),
      evaluationTimeline: evaluationTimeline ?? deadline.add(const Duration(days: 2)),
      rubricType: rubricType ?? 'PDF',
      rubricFileName: rubricFileName ?? 'Assignment_Rubric_Guide.pdf',
      rubricContent: rubricContent ?? 'Standard university academic rubric criteria.',
      isEvaluationCompleted: false,
    );

    _assignments.insert(0, newAssignment);
    _notifications.insert(
      0,
      NotificationModel(
        id: 'not-${DateTime.now().millisecondsSinceEpoch}',
        targetRole: UserRole.student,
        title: 'New Assignment: ${newAssignment.title}',
        message:
            '${newAssignment.subject} (${newAssignment.totalMarks} marks) posted by ${newAssignment.teacherName}.',
        category: NotificationCategory.announcement,
        createdAt: DateTime.now(),
        relatedAssignmentId: newAssignment.id,
      ),
    );
    notifyListeners();
  }

  void updateAssignment(AssignmentModel updated) {
    final idx = _assignments.indexWhere((a) => a.id == updated.id);
    if (idx != -1) {
      _assignments[idx] = updated;
      notifyListeners();
    }
  }

  void deleteAssignment(String assignmentId) {
    _assignments.removeWhere((a) => a.id == assignmentId);
    _submissions.removeWhere((s) => s.assignmentId == assignmentId);
    notifyListeners();
  }

  // --- Submissions (Student Upload -> Teacher Review) ---

  SubmissionModel? getStudentSubmissionForAssignment(String assignmentId) {
    final studentId = _currentUser?.id ?? 'stu-01';
    for (final s in _submissions) {
      if (s.assignmentId == assignmentId && s.studentId == studentId) {
        return s;
      }
    }
    return null;
  }

  SubmissionModel? getSubmissionById(String submissionId) {
    for (final s in _submissions) {
      if (s.id == submissionId) return s;
    }
    return null;
  }

  List<SubmissionModel> getSubmissionsForAssignment(String assignmentId) {
    return _submissions.where((s) => s.assignmentId == assignmentId).toList();
  }

  List<SubmissionModel> get studentSubmissions {
    final studentId = _currentUser?.id ?? 'stu-01';
    return _submissions.where((s) => s.studentId == studentId).toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
  }

  List<SubmissionModel> get flaggedSubmissions {
    return _submissions
        .where((s) =>
            s.status == SubmissionStatus.flagged || s.evaluation.isFlagged)
        .toList();
  }

  SubmissionModel submitAssignment({
    required AssignmentModel assignment,
    required String fileName,
    required String fileFormat,
    required int fileSizeKb,
    String? extractedText,
  }) {
    final student = _currentUser ?? _users.first;
    final rand = Random();
    final refNum = 'ACX-2026-${1000 + rand.nextInt(8999)}';
    final aiScore = (assignment.totalMarks * 0.84).roundToDouble();
    final isHandwritten = ['PNG', 'JPG', 'JPEG'].contains(fileFormat.toUpperCase());
    final defaultExtractedText = extractedText ??
        (isHandwritten
            ? 'Handwritten submission ($fileName). Queued for instructor OCR batch scanning after assignment deadline.'
            : 'Digital submission ($fileName). Queued for rubric evaluation after assignment deadline.');

    final newSubmission = SubmissionModel(
      id: 'sub-${DateTime.now().millisecondsSinceEpoch}',
      assignmentId: assignment.id,
      studentId: student.id,
      studentName: student.fullName,
      studentRollNo: student.academicId,
      fileName: fileName,
      fileFormat: fileFormat.toUpperCase(),
      fileSizeKb: fileSizeKb,
      submittedAt: DateTime.now(),
      referenceNumber: refNum,
      extractedText: defaultExtractedText,
      status: SubmissionStatus.submitted,
      evaluation: EvaluationModel(
        aiSuggestedMarks: aiScore,
        finalMarks: aiScore,
        contentQualityScore: 86,
        grammarScore: 89,
        organizationScore: 85,
        readabilityScore: 88,
        similarityPercentage: 9,
        confidenceScore: 93,
        readabilityLevel: 'Undergraduate Academic (Grade 13)',
        wordCount: defaultExtractedText.split(RegExp(r'\s+')).length + 640,
        isTeacherApproved: false,
        plagiarismReviewed: false,
        isFlagged: false,
        plagiarismMatches: const [
          PlagiarismMatch(
            matchedExcerpt:
                'systematic evaluation methodology and structured academic reasoning',
            sourceTitle: 'Academic Technical Writing Handbook',
            sourceDomain: 'academix.edu/writing',
            matchPercent: 9.0,
          ),
        ],
        grammarIssues: const [
          GrammarIssue(
            type: 'Clarity',
            originalText: 'In order to demonstrate the efficiency of the approach',
            suggestion: 'To demonstrate the approach\'s efficiency',
            explanation:
                'Shorten "in order to" to "to" for sharper technical prose.',
          ),
          GrammarIssue(
            type: 'Sentence Structure',
            originalText: 'The results was verified across multiple test runs',
            suggestion: 'The results were verified across multiple test runs',
            explanation:
                'Ensure subject-verb agreement with the plural subject "results".',
          ),
        ],
        structureFeedback: const [
          'Well-defined introduction and clear section headings detected by simulated OCR.',
          'Supporting analysis aligns with the assignment instructions.',
        ],
        aiSuggestions: const [
          'Add one concise summary table comparing key metrics at the end of Section 2.',
          'Cite primary references consistently using IEEE or APA format.',
        ],
        rubric: [
          RubricBreakdown(
            criterion: 'Conceptual Accuracy',
            earned: (assignment.totalMarks * 0.34).roundToDouble(),
            maxScore: (assignment.totalMarks * 0.40).roundToDouble(),
          ),
          RubricBreakdown(
            criterion: 'Analysis & Evidence',
            earned: (assignment.totalMarks * 0.25).roundToDouble(),
            maxScore: (assignment.totalMarks * 0.30).roundToDouble(),
          ),
          RubricBreakdown(
            criterion: 'Organization & Mechanics',
            earned: (assignment.totalMarks * 0.25).roundToDouble(),
            maxScore: (assignment.totalMarks * 0.30).roundToDouble(),
          ),
        ],
      ),
    );

    _submissions.removeWhere(
      (s) => s.assignmentId == assignment.id && s.studentId == student.id,
    );
    _submissions.insert(0, newSubmission);

    _notifications.insert(
      0,
      NotificationModel(
        id: 'not-stu-${DateTime.now().millisecondsSinceEpoch}',
        targetRole: UserRole.student,
        title: 'Submission Confirmed: ${assignment.title}',
        message:
            'File "$fileName" uploaded successfully. Reference: $refNum. Evaluation scheduled for instructor timeline after deadline.',
        category: NotificationCategory.submission,
        createdAt: DateTime.now(),
        relatedAssignmentId: assignment.id,
        relatedSubmissionId: newSubmission.id,
      ),
    );

    _notifications.insert(
      0,
      NotificationModel(
        id: 'not-tch-${DateTime.now().millisecondsSinceEpoch + 1}',
        targetRole: UserRole.teacher,
        title: 'New Submission: ${student.fullName}',
        message:
            '${student.fullName} submitted "${assignment.title}" ($fileFormat). Pending deadline & evaluation timeline.',
        category: NotificationCategory.submission,
        createdAt: DateTime.now(),
        relatedAssignmentId: assignment.id,
        relatedSubmissionId: newSubmission.id,
      ),
    );

    notifyListeners();
    return newSubmission;
  }

  void runBatchEvaluation({required String assignmentId}) {
    final asgIdx = _assignments.indexWhere((a) => a.id == assignmentId);
    if (asgIdx == -1) return;
    final assignment = _assignments[asgIdx];

    _assignments[asgIdx] = assignment.copyWith(isEvaluationCompleted: true);

    for (int i = 0; i < _submissions.length; i++) {
      final sub = _submissions[i];
      if (sub.assignmentId == assignmentId) {
        final isHandwritten =
            ['PNG', 'JPG', 'JPEG'].contains(sub.fileFormat.toUpperCase());
        final ocrText = isHandwritten
            ? 'OCR Extracted Text from handwritten sheets (${sub.fileName}): '
              'Calculations, formulas, and written analysis successfully parsed using teacher rubric (${assignment.rubricFileName ?? 'Rubric'}).'
            : sub.extractedText;

        final updatedSub = sub.copyWith(
          status: SubmissionStatus.evaluated,
          extractedText: ocrText,
          evaluation: sub.evaluation.copyWith(
            isTeacherApproved: true,
            approvedAt: DateTime.now(),
            teacherFinalComment:
                'Evaluated according to ${assignment.rubricType ?? 'Teacher'} Rubric (${assignment.rubricFileName ?? 'Document'}).',
          ),
        );
        _submissions[i] = updatedSub;
      }
    }

    _notifications.insert(
      0,
      NotificationModel(
        id: 'not-eval-${DateTime.now().millisecondsSinceEpoch}',
        targetRole: UserRole.student,
        title: 'Evaluation Released: ${assignment.title}',
        message:
            'OCR scanning and AI rubric evaluations have been released by ${assignment.teacherName}. You can now view your detailed report.',
        category: NotificationCategory.evaluation,
        createdAt: DateTime.now(),
        relatedAssignmentId: assignment.id,
      ),
    );

    notifyListeners();
  }

  // --- Teacher Review, Grading & Feedback ---

  void approveGrade({
    required String submissionId,
    required double finalMarks,
    required String finalComment,
  }) {
    final idx = _submissions.indexWhere((s) => s.id == submissionId);
    if (idx == -1) return;

    final current = _submissions[idx];
    final assignment = getAssignmentById(current.assignmentId);

    final updatedEval = current.evaluation.copyWith(
      finalMarks: finalMarks,
      teacherFinalComment: finalComment.trim(),
      isTeacherApproved: true,
      isFlagged: false,
      approvedAt: DateTime.now(),
    );

    final updatedFeedbackList = List<FeedbackModel>.from(current.feedbackList);
    if (finalComment.trim().isNotEmpty) {
      updatedFeedbackList.insert(
        0,
        FeedbackModel(
          id: 'fb-${DateTime.now().millisecondsSinceEpoch}',
          submissionId: current.id,
          teacherName: _currentUser?.fullName ?? 'Dr. Usman Tariq',
          message: finalComment.trim(),
          status: FeedbackStatus.published,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }

    _submissions[idx] = current.copyWith(
      status: SubmissionStatus.evaluated,
      evaluation: updatedEval,
      feedbackList: updatedFeedbackList,
    );

    _notifications.insert(
      0,
      NotificationModel(
        id: 'not-eval-${DateTime.now().millisecondsSinceEpoch}',
        targetRole: UserRole.student,
        title: 'Grade Approved: ${assignment?.title ?? 'Assignment'}',
        message:
            'Final score ${finalMarks.toStringAsFixed(0)}/${assignment?.totalMarks ?? 100} has been approved by ${_currentUser?.fullName ?? 'your instructor'}.',
        category: NotificationCategory.evaluation,
        createdAt: DateTime.now(),
        relatedAssignmentId: current.assignmentId,
        relatedSubmissionId: current.id,
      ),
    );

    notifyListeners();
  }

  void saveFeedback({
    required String submissionId,
    required String message,
    required FeedbackStatus status,
    String? editingFeedbackId,
  }) {
    final idx = _submissions.indexWhere((s) => s.id == submissionId);
    if (idx == -1) return;

    final current = _submissions[idx];
    final list = List<FeedbackModel>.from(current.feedbackList);
    final now = DateTime.now();

    if (editingFeedbackId != null) {
      final fbIdx = list.indexWhere((f) => f.id == editingFeedbackId);
      if (fbIdx != -1) {
        list[fbIdx] = list[fbIdx].copyWith(
          message: message.trim(),
          status: status,
          updatedAt: now,
        );
      }
    } else {
      list.insert(
        0,
        FeedbackModel(
          id: 'fb-${now.millisecondsSinceEpoch}',
          submissionId: current.id,
          teacherName: _currentUser?.fullName ?? 'Dr. Usman Tariq',
          message: message.trim(),
          status: status,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    _submissions[idx] = current.copyWith(feedbackList: list);

    if (status == FeedbackStatus.published) {
      final assignment = getAssignmentById(current.assignmentId);
      _notifications.insert(
        0,
        NotificationModel(
          id: 'not-fb-${now.millisecondsSinceEpoch}',
          targetRole: UserRole.student,
          title: 'Teacher Feedback Updated',
          message:
              'New feedback published for ${assignment?.title ?? 'your submission'}.',
          category: NotificationCategory.feedback,
          createdAt: now,
          relatedAssignmentId: current.assignmentId,
          relatedSubmissionId: current.id,
        ),
      );
    }

    notifyListeners();
  }

  void markPlagiarismReviewed(String submissionId, {bool flagIntegrity = false}) {
    final idx = _submissions.indexWhere((s) => s.id == submissionId);
    if (idx == -1) return;

    final current = _submissions[idx];
    final reasons = List<String>.from(current.evaluation.flagReasons);
    if (flagIntegrity && !reasons.contains('Flagged for Academic Integrity Review')) {
      reasons.add('Flagged for Academic Integrity Review');
    }

    _submissions[idx] = current.copyWith(
      status: flagIntegrity ? SubmissionStatus.flagged : current.status,
      evaluation: current.evaluation.copyWith(
        plagiarismReviewed: true,
        isFlagged: flagIntegrity ? true : current.evaluation.isFlagged,
        flagReasons: reasons,
      ),
    );
    notifyListeners();
  }

  // --- Notifications ---

  void markNotificationRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1 && !_notifications[idx].isRead) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllNotificationsRead() {
    if (_currentUser == null) return;
    for (var i = 0; i < _notifications.length; i++) {
      if (_notifications[i].targetRole == _currentUser!.role) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    notifyListeners();
  }

  // --- Dashboard Metrics ---

  int get studentTotalAssignments => studentAssignments.length;

  int get studentSubmittedCount => studentSubmissions.length;

  int get studentEvaluatedCount => studentSubmissions
      .where((s) => s.status == SubmissionStatus.evaluated)
      .length;

  int get studentPendingCount =>
      (studentAssignments.length - studentSubmittedCount).clamp(0, 999);

  int get teacherPendingReviewCount => _submissions
      .where((s) => s.status != SubmissionStatus.evaluated)
      .length;

  int get teacherEvaluatedCount => _submissions
      .where((s) => s.status == SubmissionStatus.evaluated)
      .length;

  // ==========================================
  // --- Class Management Methods & Queries ---
  // ==========================================

  /// Get classes belonging to a teacher
  List<ClassModel> getTeacherClasses([String? teacherId]) {
    final tid = teacherId ?? _currentUser?.id ?? 'tch-01';
    return _classes.where((c) => c.teacherId == tid).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get classes enrolled by a student
  List<ClassModel> getStudentClasses([String? studentId]) {
    final sid = studentId ?? _currentUser?.id ?? 'stu-01';
    return _classes.where((c) => c.enrolledStudentIds.contains(sid)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get enrolled students as UserModel list for a class
  List<UserModel> getClassStudents(String classId) {
    final cls = _classes.firstWhere((c) => c.id == classId, orElse: () => _classes.first);
    return _users.where((u) => cls.enrolledStudentIds.contains(u.id)).toList();
  }

  /// Get assignments for a specific class
  List<AssignmentModel> getClassAssignments(String classId) {
    return _assignments.where((a) => a.classId == classId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Student view of assignments (only from enrolled classes)
  List<AssignmentModel> get studentAssignments {
    if (_currentUser == null || _currentUser!.role != UserRole.student) {
      return assignments;
    }
    final enrolledClassIds = getStudentClasses(_currentUser!.id).map((c) => c.id).toSet();
    return _assignments
        .where((a) => a.classId == null || enrolledClassIds.contains(a.classId))
        .toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  /// Helper to generate a unique 6-8 char class code e.g. "ACX-4819"
  String generateClassCode([String? prefix]) {
    final rnd = Random();
    final p = (prefix != null && prefix.trim().isNotEmpty)
        ? prefix.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '')
        : 'ACX';
    final cleanPrefix = p.length > 4 ? p.substring(0, 4) : (p.isEmpty ? 'ACX' : p);
    final numPart = 1000 + rnd.nextInt(9000);
    final candidate = '$cleanPrefix-$numPart';
    // ensure uniqueness
    if (_classes.any((c) => c.classCode == candidate)) {
      return '$cleanPrefix-${1000 + rnd.nextInt(9000)}';
    }
    return candidate;
  }

  /// Create a new class (Teacher)
  ClassModel createClass({
    required String name,
    required String subject,
    required String courseCode,
    String? section,
    String? semester,
    String? academicYear,
    String? description,
  }) {
    final code = generateClassCode(courseCode);
    final newClass = ClassModel(
      id: 'cls-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      subject: subject.trim(),
      courseCode: courseCode.trim().toUpperCase(),
      section: section?.trim().isEmpty ?? true ? null : section!.trim(),
      semester: semester?.trim().isEmpty ?? true ? null : semester!.trim(),
      academicYear: academicYear?.trim().isEmpty ?? true ? null : academicYear!.trim(),
      description: description?.trim().isEmpty ?? true ? null : description!.trim(),
      teacherId: _currentUser?.id ?? 'tch-01',
      teacherName: _currentUser?.fullName ?? 'Dr. Usman Tariq',
      classCode: code,
      enrolledStudentIds: [],
      createdAt: DateTime.now(),
      status: ClassStatus.active,
    );
    _classes.insert(0, newClass);
    notifyListeners();
    return newClass;
  }

  /// Edit existing class details
  void updateClass({
    required String classId,
    required String name,
    required String subject,
    required String courseCode,
    String? section,
    String? semester,
    String? academicYear,
    String? description,
  }) {
    final idx = _classes.indexWhere((c) => c.id == classId);
    if (idx != -1) {
      _classes[idx] = _classes[idx].copyWith(
        name: name.trim(),
        subject: subject.trim(),
        courseCode: courseCode.trim().toUpperCase(),
        section: section?.trim(),
        semester: semester?.trim(),
        academicYear: academicYear?.trim(),
        description: description?.trim(),
      );
      notifyListeners();
    }
  }

  /// Archive or Unarchive class
  void toggleClassArchived(String classId) {
    final idx = _classes.indexWhere((c) => c.id == classId);
    if (idx != -1) {
      final currentStatus = _classes[idx].status;
      _classes[idx] = _classes[idx].copyWith(
        status: currentStatus == ClassStatus.active
            ? ClassStatus.archived
            : ClassStatus.active,
      );
      notifyListeners();
    }
  }

  /// Join class via code (Student)
  String? joinClass(String code) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) {
      return 'Please enter a valid class code.';
    }

    final matchIdx = _classes.indexWhere(
      (c) => c.classCode.toUpperCase() == cleanCode,
    );

    if (matchIdx == -1) {
      return 'Invalid class code. Please check with your teacher and try again.';
    }

    final targetClass = _classes[matchIdx];

    if (targetClass.status == ClassStatus.archived) {
      return 'This class is archived. New students cannot join an archived class.';
    }

    final studentId = _currentUser?.id ?? 'stu-01';
    if (targetClass.enrolledStudentIds.contains(studentId)) {
      return 'You are already enrolled in "${targetClass.name}".';
    }

    final updatedEnrolled = [...targetClass.enrolledStudentIds, studentId];
    _classes[matchIdx] = targetClass.copyWith(enrolledStudentIds: updatedEnrolled);

    // Notify teacher
    _notifications.insert(
      0,
      NotificationModel(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        title: 'New Student Enrolled',
        message:
            '${_currentUser?.fullName ?? 'A new student'} joined your class "${targetClass.name}".',
        category: NotificationCategory.announcement,
        targetRole: UserRole.teacher,
        createdAt: DateTime.now(),
      ),
    );

    notifyListeners();
    return null; // success
  }

  /// Remove student from class (Teacher action)
  void removeStudentFromClass(String classId, String studentId) {
    final idx = _classes.indexWhere((c) => c.id == classId);
    if (idx != -1) {
      final current = _classes[idx];
      final updated = current.enrolledStudentIds.where((id) => id != studentId).toList();
      _classes[idx] = current.copyWith(enrolledStudentIds: updated);
      notifyListeners();
    }
  }

  /// Leave class (Student action)
  void leaveClass(String classId) {
    final studentId = _currentUser?.id ?? 'stu-01';
    removeStudentFromClass(classId, studentId);
  }

  /// Get submission for an assignment by a student
  SubmissionModel? getStudentSubmission(String assignmentId, String studentId) {
    return _submissions.cast<SubmissionModel?>().firstWhere(
          (s) => s?.assignmentId == assignmentId && s?.studentId == studentId,
          orElse: () => null,
        );
  }

  /// Get status summary for all enrolled students in a class assignment
  List<ClassStudentSubmissionStatus> getClassAssignmentSubmissions(String assignmentId) {
    final asg = _assignments.firstWhere(
      (a) => a.id == assignmentId,
      orElse: () => _assignments.first,
    );

    // Find class
    final targetClass = _classes.firstWhere(
      (c) => c.id == asg.classId,
      orElse: () => _classes.first,
    );

    final enrolledStudents = _users
        .where((u) => targetClass.enrolledStudentIds.contains(u.id))
        .toList();

    return enrolledStudents.map((stu) {
      final sub = getStudentSubmission(assignmentId, stu.id);
      String statusLabel;
      Color statusColor;

      if (sub == null) {
        if (asg.isOverdue) {
          statusLabel = 'Missing / Overdue';
          statusColor = const Color(0xFFEF4444);
        } else {
          statusLabel = 'Not Submitted';
          statusColor = const Color(0xFF64748B);
        }
      } else if (sub.status == SubmissionStatus.evaluated) {
        statusLabel = 'Evaluated';
        statusColor = const Color(0xFF10B981);
      } else if (sub.submittedAt.isAfter(asg.deadline)) {
        statusLabel = 'Late Submission';
        statusColor = const Color(0xFFF59E0B);
      } else {
        statusLabel = 'Submitted';
        statusColor = const Color(0xFF2563EB);
      }

      return ClassStudentSubmissionStatus(
        student: stu,
        assignment: asg,
        submission: sub,
        statusLabel: statusLabel,
        statusColor: statusColor,
      );
    }).toList();
  }
}

class ClassStudentSubmissionStatus {
  final UserModel student;
  final AssignmentModel assignment;
  final SubmissionModel? submission;
  final String statusLabel;
  final Color statusColor;

  const ClassStudentSubmissionStatus({
    required this.student,
    required this.assignment,
    this.submission,
    required this.statusLabel,
    required this.statusColor,
  });

  bool get hasSubmitted => submission != null;
  bool get isEvaluated => submission?.status == SubmissionStatus.evaluated;
}
