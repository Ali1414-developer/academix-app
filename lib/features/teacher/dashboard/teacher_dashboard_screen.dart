import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/state/academix_provider.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../models/assignment_model.dart';
import '../../../models/class_model.dart';
import '../../../models/submission_model.dart';
import '../assignments/teacher_assignments_screens.dart';
import '../classes/teacher_classes_screens.dart';
import '../evaluation/teacher_evaluation_screens.dart';
import '../notifications/teacher_notifications_screen.dart';
import '../submissions/teacher_submissions_screens.dart';

// Teacher Screen 1: Teacher Dashboard (Mobile-First Redesign)
class TeacherDashboardScreen extends StatelessWidget {
  final VoidCallback onNavigateToAssignments;
  final VoidCallback onNavigateToSubmissions;

  const TeacherDashboardScreen({
    super.key,
    required this.onNavigateToAssignments,
    required this.onNavigateToSubmissions,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademiXProvider>();
    final user = provider.currentUser!;
    final assignments = provider.assignments;
    final submissions = provider.submissions;
    final teacherClasses = provider.getTeacherClasses();
    final flagged = provider.flaggedSubmissions;
    final pendingCount = provider.teacherPendingReviewCount;
    final unreadNotifications = provider.unreadNotificationCount;

    final upcoming = assignments.where((a) => !a.isOverdue).toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: AppColors.white,
        scrolledUnderElevation: 1,
        titleSpacing: 16,
        title: Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: AppColors.lightBlue,
              child: Text(
                user.initials,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBlue,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                    ),
                  ),
                  Text(
                    '${user.semesterOrDesignation} · ${user.department}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'My Classes',
            icon: const Icon(Icons.school_outlined, size: 22),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const TeacherClassesScreen(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'New Assignment',
            icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CreateAssignmentScreen(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Notifications',
            icon: Badge(
              isLabelVisible: unreadNotifications > 0,
              label: Text('$unreadNotifications'),
              child: const Icon(Icons.notifications_outlined, size: 22),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const TeacherNotificationsScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
          children: [
            // 1. Action Required Banner (Grading Queue Priority)
            if (pendingCount > 0 || flagged.isNotEmpty) ...[
              _GradingQueueHero(
                pendingCount: pendingCount,
                flaggedCount: flagged.length,
                onStartGrading: onNavigateToSubmissions,
                onViewFlagged: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const FlaggedSubmissionsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ] else ...[
              const _AllGradedBanner(),
              const SizedBox(height: 16),
            ],

            // 2. Compact Metric Strip (Mobile Ergonomics)
            Row(
              children: [
                Expanded(
                  child: _TeacherMetricPill(
                    icon: Icons.school_outlined,
                    count: '${teacherClasses.length}',
                    label: 'Classes',
                    color: AppColors.primaryBlue,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TeacherClassesScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TeacherMetricPill(
                    icon: Icons.assignment_outlined,
                    count: '${assignments.length}',
                    label: 'Assignments',
                    color: const Color(0xFF4F46E5),
                    onTap: onNavigateToAssignments,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TeacherMetricPill(
                    icon: Icons.inbox_outlined,
                    count: '${submissions.length}',
                    label: 'Submissions',
                    color: AppColors.success,
                    onTap: onNavigateToSubmissions,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 3. My Classes (Google Classroom Style Mobile Carousel)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.school_rounded,
                        size: 18, color: AppColors.primaryBlue),
                    const SizedBox(width: 6),
                    Text(
                      'My Classes (${teacherClasses.length})',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TeacherClassesScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('Manage All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 126,
              child: teacherClasses.isEmpty
                  ? _EmptyTeacherClassesBanner(
                      onCreate: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TeacherClassesScreen(),
                          ),
                        );
                      },
                    )
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: teacherClasses.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        if (i == teacherClasses.length) {
                          return _CreateClassCard(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const TeacherClassesScreen(),
                                ),
                              );
                            },
                          );
                        }
                        final cls = teacherClasses[i];
                        final asgCount =
                            provider.getClassAssignments(cls.id).length;
                        return _TeacherClassCard(
                          classModel: cls,
                          assignmentCount: asgCount,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    TeacherClassDetailScreen(classModel: cls),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),

            // 4. Active Coursework & Submission Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.assignment_outlined,
                        size: 16, color: AppColors.primaryBlue),
                    SizedBox(width: 6),
                    Text(
                      'Active Coursework',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: onNavigateToAssignments,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (upcoming.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        color: AppColors.success, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No active assignment deadlines right now.',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.secondaryText),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...upcoming.take(3).map((asg) {
                final subs = provider.getSubmissionsForAssignment(asg.id);
                final pendingForAsg = subs
                    .where((s) => s.status == SubmissionStatus.submitted)
                    .length;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _TeacherAssignmentProgressCard(
                    assignment: asg,
                    submittedCount: subs.length,
                    pendingReviewCount: pendingForAsg,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TeacherAssignmentDetailScreen(
                            assignmentId: asg.id,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            const SizedBox(height: 18),

            // 5. Recent Submissions Stream
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.inbox_rounded,
                        size: 16, color: AppColors.darkBlue),
                    SizedBox(width: 6),
                    Text(
                      'Recent Submissions',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: onNavigateToSubmissions,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('All Submissions'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Material(
              color: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppColors.border),
              ),
              child: submissions.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(18),
                      child: Text(
                        'No student submissions received yet.',
                        style: TextStyle(
                            color: AppColors.secondaryText, fontSize: 13),
                      ),
                    )
                  : Column(
                      children: submissions.take(3).map((sub) {
                        final asg = provider.getAssignmentById(sub.assignmentId);
                        final isFlagged = sub.status == SubmissionStatus.flagged;
                        final isEval = sub.status == SubmissionStatus.evaluated;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          leading: CircleAvatar(
                            radius: 17,
                            backgroundColor: isFlagged
                                ? AppColors.errorLight
                                : isEval
                                    ? AppColors.successLight
                                    : AppColors.lightBlue,
                            child: Text(
                              sub.studentName.isNotEmpty
                                  ? sub.studentName[0]
                                  : 'S',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isFlagged
                                    ? AppColors.error
                                    : isEval
                                        ? AppColors.success
                                        : AppColors.primaryBlue,
                              ),
                            ),
                          ),
                          title: Text(
                            sub.studentName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${asg?.courseCode ?? 'Course'} · ${formatRelativeTime(sub.submittedAt)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          trailing: SemanticStatusLabel(
                            label: isFlagged
                                ? 'Flagged'
                                : isEval
                                    ? 'Evaluated'
                                    : 'Pending',
                            color: isFlagged
                                ? AppColors.error
                                : isEval
                                    ? AppColors.success
                                    : AppColors.warning,
                            icon: isFlagged
                                ? Icons.flag_rounded
                                : isEval
                                    ? Icons.verified_rounded
                                    : Icons.schedule_rounded,
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TeacherSubmissionReviewScreen(
                                  submissionId: sub.id,
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// Sub-components for Teacher Dashboard (Mobile Native)
// -------------------------------------------------------------

class _GradingQueueHero extends StatelessWidget {
  final int pendingCount;
  final int flaggedCount;
  final VoidCallback onStartGrading;
  final VoidCallback onViewFlagged;

  const _GradingQueueHero({
    required this.pendingCount,
    required this.flaggedCount,
    required this.onStartGrading,
    required this.onViewFlagged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFDE68A),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'GRADING QUEUE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.warning,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                if (flaggedCount > 0)
                  InkWell(
                    onTap: onViewFlagged,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.flag_rounded,
                              size: 12, color: AppColors.error),
                          const SizedBox(width: 4),
                          Text(
                            '$flaggedCount Flagged',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '$pendingCount Submissions Need Review',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Review OCR extracted text, verify AI grading scores, and release final feedback to students.',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.secondaryText,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onStartGrading,
              icon: const Icon(Icons.rate_review_rounded, size: 16),
              label: const Text(
                'Open Review Queue',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size.fromHeight(40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllGradedBanner extends StatelessWidget {
  const _AllGradedBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.successLight,
            child: Icon(Icons.verified_rounded,
                color: AppColors.success, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Grading Up to Date! 🎉',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'All student submissions have been evaluated and released.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherMetricPill extends StatelessWidget {
  final IconData icon;
  final String count;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _TeacherMetricPill({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      count,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: color,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeacherClassCard extends StatelessWidget {
  final ClassModel classModel;
  final int assignmentCount;
  final VoidCallback onTap;

  const _TeacherClassCard({
    required this.classModel,
    required this.assignmentCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 215,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.lightBlue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            classModel.courseCode,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ),
                      if (classModel.section?.isNotEmpty == true) ...[
                        const SizedBox(width: 6),
                        Text(
                          'Sec ${classModel.section}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    classModel.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${classModel.enrolledStudentIds.length} students enrolled',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: classModel.classCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Class code copied: ${classModel.classCode}'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            classModel.classCode,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryText,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.copy_rounded,
                              size: 10, color: AppColors.secondaryText),
                        ],
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 11, color: AppColors.secondaryText),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateClassCard extends StatelessWidget {
  final VoidCallback onTap;

  const _CreateClassCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
          style: BorderStyle.solid,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.white,
              child: Icon(Icons.add_rounded, size: 20, color: AppColors.primaryBlue),
            ),
            SizedBox(height: 6),
            Text(
              'New Class',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyTeacherClassesBanner extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyTeacherClassesBanner({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.school_outlined,
              size: 28, color: AppColors.primaryBlue),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No classes created yet',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                Text(
                  'Create your first class and share code',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onCreate,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Create', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

class _TeacherAssignmentProgressCard extends StatelessWidget {
  final AssignmentModel assignment;
  final int submittedCount;
  final int pendingReviewCount;
  final VoidCallback onTap;

  const _TeacherAssignmentProgressCard({
    required this.assignment,
    required this.submittedCount,
    required this.pendingReviewCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalEnrolled = assignment.totalStudentsEnrolled > 0
        ? assignment.totalStudentsEnrolled
        : 1;
    final progress = (submittedCount / totalEnrolled).clamp(0.0, 1.0);

    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      assignment.courseCode,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      assignment.className ?? assignment.subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                  Text(
                    'Due ${formatShortDate(assignment.deadline)}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                assignment.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$submittedCount of $totalEnrolled submitted (${(progress * 100).toInt()}%)',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  if (pendingReviewCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$pendingReviewCount to review',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
