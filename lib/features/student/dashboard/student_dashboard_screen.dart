import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/state/academix_provider.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../models/assignment_model.dart';
import '../../../models/class_model.dart';
import '../../../models/submission_model.dart';
import '../assignments/student_assignments_screens.dart';
import '../calendar/student_calendar_screen.dart';
import '../classes/student_classes_screens.dart';
import '../evaluation/student_evaluation_screens.dart';
import '../notifications/student_notifications_screen.dart';
import '../submissions/student_upload_flow_screens.dart';

// Student Screen 1: Student Dashboard (Mobile-First Redesign)
class StudentDashboardScreen extends StatelessWidget {
  final VoidCallback onNavigateToAssignments;
  final VoidCallback onNavigateToResults;

  const StudentDashboardScreen({
    super.key,
    required this.onNavigateToAssignments,
    required this.onNavigateToResults,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademiXProvider>();
    final user = provider.currentUser!;
    final assignments = provider.assignments;
    final submissions = provider.studentSubmissions;
    final enrolledClasses = provider.getStudentClasses();
    final unreadNotifications = provider.unreadNotificationCount;

    // Upcoming assignments ordered by deadline
    final upcoming = assignments
        .where((a) => !a.isOverdue)
        .toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));

    // Nearest pending assignment for priority highlight
    AssignmentModel? nearestPending;
    for (final asg in upcoming) {
      final sub = provider.getStudentSubmissionForAssignment(asg.id);
      if (sub == null) {
        nearestPending = asg;
        break;
      }
    }

    final evaluatedSubs = submissions
        .where((s) => s.status == SubmissionStatus.evaluated)
        .toList();

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
                  color: AppColors.primaryBlue,
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
                    '${_getGreeting()}, ${user.fullName.split(' ').first}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                    ),
                  ),
                  Text(
                    '${user.department} · ${user.semesterOrDesignation}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w400,
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
                  builder: (_) => const StudentClassesScreen(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Deadlines & Calendar',
            icon: const Icon(Icons.calendar_month_outlined, size: 22),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const StudentCalendarScreen(),
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
                  builder: (_) => const StudentNotificationsScreen(),
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
            // 1. "Due Next" Hero Card
            if (nearestPending != null) ...[
              _DueNextHeroCard(
                assignment: nearestPending,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => StudentAssignmentDetailScreen(
                        assignmentId: nearestPending!.id,
                      ),
                    ),
                  );
                },
                onSubmit: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AssignmentUploadScreen(
                        assignment: nearestPending!,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ] else ...[
              _AllCaughtUpCard(onBrowse: onNavigateToAssignments),
              const SizedBox(height: 16),
            ],

            // 2. Compact Coursework Snapshot Row (Mobile Ergonomic Pills)
            Row(
              children: [
                Expanded(
                  child: _StatusPillCard(
                    icon: Icons.pending_actions_rounded,
                    count: '${provider.studentPendingCount}',
                    label: 'To Do',
                    color: AppColors.warning,
                    onTap: onNavigateToAssignments,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatusPillCard(
                    icon: Icons.task_alt_rounded,
                    count: '${provider.studentSubmittedCount}',
                    label: 'Turned In',
                    color: AppColors.primaryBlue,
                    onTap: onNavigateToAssignments,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatusPillCard(
                    icon: Icons.verified_rounded,
                    count: '${provider.studentEvaluatedCount}',
                    label: 'Graded',
                    color: AppColors.success,
                    onTap: onNavigateToResults,
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
                      'My Classes (${enrolledClasses.length})',
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
                        builder: (_) => const StudentClassesScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 122,
              child: enrolledClasses.isEmpty
                  ? _EmptyClassesBanner(
                      onJoin: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const StudentClassesScreen(),
                          ),
                        );
                      },
                    )
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: enrolledClasses.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        if (i == enrolledClasses.length) {
                          return _JoinClassCard(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const StudentClassesScreen(),
                                ),
                              );
                            },
                          );
                        }
                        final cls = enrolledClasses[i];
                        final asgCount =
                            provider.getClassAssignments(cls.id).length;
                        return _DashboardClassCard(
                          classModel: cls,
                          assignmentCount: asgCount,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    StudentClassDetailScreen(classModel: cls),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),

            // 4. Upcoming Deadlines Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 16, color: AppColors.primaryBlue),
                    SizedBox(width: 6),
                    Text(
                      'Upcoming Deadlines',
                      style: TextStyle(
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
                        builder: (_) => const StudentCalendarScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('Calendar'),
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
                        'No upcoming deadlines right now.',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.secondaryText),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...upcoming.take(3).map((asg) {
                final sub = provider.getStudentSubmissionForAssignment(asg.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _DashboardDeadlineCard(
                    assignment: asg,
                    submission: sub,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => StudentAssignmentDetailScreen(
                            assignmentId: asg.id,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            const SizedBox(height: 18),

            // 5. Recent Grades & Feedback
            if (evaluatedSubs.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.verified_outlined,
                          size: 16, color: AppColors.success),
                      SizedBox(width: 6),
                      Text(
                        'Recent Evaluation Results',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: onNavigateToResults,
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...evaluatedSubs.take(2).map((sub) {
                final asg = provider.getAssignmentById(sub.assignmentId);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _DashboardGradeCard(
                    submission: sub,
                    assignment: asg,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => StudentEvaluationDetailScreen(
                            submissionId: sub.id,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// Sub-components for Student Dashboard (Mobile Native)
// -------------------------------------------------------------

class _DueNextHeroCard extends StatelessWidget {
  final AssignmentModel assignment;
  final VoidCallback onTap;
  final VoidCallback onSubmit;

  const _DueNextHeroCard({
    required this.assignment,
    required this.onTap,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final daysLeft = assignment.deadline.difference(DateTime.now()).inDays;
    final isUrgent = daysLeft <= 1;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUrgent ? const Color(0xFFFDE68A) : AppColors.border,
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
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
                      color: isUrgent ? const Color(0xFFFEF3C7) : AppColors.lightBlue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isUrgent ? 'DUE SOON' : 'UP NEXT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isUrgent ? AppColors.warning : AppColors.primaryBlue,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${assignment.courseCode} · ${assignment.subject}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isUrgent ? const Color(0xFFFFF1F2) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 11,
                          color: isUrgent ? AppColors.error : AppColors.secondaryText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          daysLeft <= 0
                              ? 'Due Today'
                              : daysLeft == 1
                                  ? 'Tomorrow'
                                  : '$daysLeft days left',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isUrgent ? AppColors.error : AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                assignment.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Total Marks: ${assignment.totalMarks} · Deadline: ${formatShortDate(assignment.deadline)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onSubmit,
                      icon: const Icon(Icons.upload_file_rounded, size: 16),
                      label: const Text(
                        'Submit Work',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Instructions', style: TextStyle(fontSize: 13)),
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

class _AllCaughtUpCard extends StatelessWidget {
  final VoidCallback onBrowse;

  const _AllCaughtUpCard({required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.task_alt_rounded,
                color: AppColors.success, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All caught up!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'No urgent coursework pending. Great job!',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onBrowse,
            child: const Text('Browse', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _StatusPillCard extends StatelessWidget {
  final IconData icon;
  final String count;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _StatusPillCard({
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

class _DashboardClassCard extends StatelessWidget {
  final ClassModel classModel;
  final int assignmentCount;
  final VoidCallback onTap;

  const _DashboardClassCard({
    required this.classModel,
    required this.assignmentCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
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
                    classModel.teacherName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                  Text(
                    '$assignmentCount assignments',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryBlue,
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

class _JoinClassCard extends StatelessWidget {
  final VoidCallback onTap;

  const _JoinClassCard({required this.onTap});

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
              'Join Class',
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

class _EmptyClassesBanner extends StatelessWidget {
  final VoidCallback onJoin;

  const _EmptyClassesBanner({required this.onJoin});

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
                  'No classes joined yet',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                Text(
                  'Enter a class code from your teacher',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onJoin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Join', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

class _DashboardDeadlineCard extends StatelessWidget {
  final AssignmentModel assignment;
  final SubmissionModel? submission;
  final VoidCallback onTap;

  const _DashboardDeadlineCard({
    required this.assignment,
    required this.submission,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSubmitted = submission != null;
    final isEvaluated = submission?.status == SubmissionStatus.evaluated;

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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isEvaluated
                      ? AppColors.successLight
                      : isSubmitted
                          ? AppColors.lightBlue
                          : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isEvaluated
                      ? Icons.verified_rounded
                      : isSubmitted
                          ? Icons.check_circle_rounded
                          : Icons.schedule_rounded,
                  size: 18,
                  color: isEvaluated
                      ? AppColors.success
                      : isSubmitted
                          ? AppColors.primaryBlue
                          : AppColors.warning,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    const SizedBox(height: 2),
                    Text(
                      '${assignment.courseCode} · Due ${formatShortDate(assignment.deadline)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isEvaluated
                    ? '${submission!.evaluation.finalMarks.toStringAsFixed(0)}/${assignment.totalMarks}'
                    : isSubmitted
                        ? 'Submitted'
                        : '${assignment.totalMarks} pts',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isEvaluated
                      ? AppColors.success
                      : isSubmitted
                          ? AppColors.primaryBlue
                          : AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardGradeCard extends StatelessWidget {
  final SubmissionModel submission;
  final AssignmentModel? assignment;
  final VoidCallback onTap;

  const _DashboardGradeCard({
    required this.submission,
    required this.assignment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final marks = submission.evaluation.finalMarks;
    final totalMarks = assignment?.totalMarks ?? 100;
    final pct = totalMarks > 0 ? (marks / totalMarks) * 100 : 0.0;

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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${pct.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                    Text(
                      '${marks.toInt()}/$totalMarks',
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment?.title ?? 'Evaluated Coursework',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      submission.evaluation.teacherFinalComment.isNotEmpty
                          ? '"${submission.evaluation.teacherFinalComment}"'
                          : 'AI & Rubric evaluation complete',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.secondaryText,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 12, color: AppColors.secondaryText),
            ],
          ),
        ),
      ),
    );
  }
}
