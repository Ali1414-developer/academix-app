import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/state/academix_provider.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../models/assignment_model.dart';
import '../../../models/submission_model.dart';
import '../calendar/student_calendar_screen.dart';
import '../evaluation/student_evaluation_screens.dart';
import '../submissions/student_upload_flow_screens.dart';

// Student Screen 2: My Assignments
class StudentAssignmentsScreen extends StatefulWidget {
  const StudentAssignmentsScreen({super.key});

  @override
  State<StudentAssignmentsScreen> createState() =>
      _StudentAssignmentsScreenState();
}

class _StudentAssignmentsScreenState extends State<StudentAssignmentsScreen> {
  final _searchCtrl = TextEditingController();
  String _statusFilter = 'All';
  String _sortBy = 'Deadline';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademiXProvider>();
    final query = _searchCtrl.text.trim().toLowerCase();

    final filtered = provider.assignments.where((asg) {
      final sub = provider.getStudentSubmissionForAssignment(asg.id);
      final matchesSearch = query.isEmpty ||
          asg.title.toLowerCase().contains(query) ||
          asg.subject.toLowerCase().contains(query) ||
          asg.courseCode.toLowerCase().contains(query);
      if (!matchesSearch) return false;

      if (_statusFilter == 'Pending') return sub == null;
      if (_statusFilter == 'Submitted') {
        return sub != null && sub.status != SubmissionStatus.evaluated;
      }
      if (_statusFilter == 'Evaluated') {
        return sub != null && sub.status == SubmissionStatus.evaluated;
      }
      return true;
    }).toList();

    filtered.sort((a, b) {
      if (_sortBy == 'Marks') return b.totalMarks.compareTo(a.totalMarks);
      if (_sortBy == 'Title') return a.title.compareTo(b.title);
      return a.deadline.compareTo(b.deadline);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Assignments'),
        actions: [
          IconButton(
            tooltip: 'Deadlines & Calendar',
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const StudentCalendarScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search assignments or subjects...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['All', 'Pending', 'Submitted', 'Evaluated']
                              .map((status) {
                            final active = _statusFilter == status;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(status),
                                selected: active,
                                onSelected: (_) =>
                                    setState(() => _statusFilter = status),
                                selectedColor: AppColors.primaryBlue,
                                backgroundColor: AppColors.background,
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: active
                                      ? AppColors.white
                                      : AppColors.primaryText,
                                ),
                                side: BorderSide(
                                  color: active
                                      ? AppColors.primaryBlue
                                      : AppColors.border,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'Sort assignments',
                      icon: const Icon(Icons.sort_rounded),
                      onSelected: (v) => setState(() => _sortBy = v),
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                            value: 'Deadline', child: Text('Sort by Deadline')),
                        PopupMenuItem(
                            value: 'Marks', child: Text('Sort by Total Marks')),
                        PopupMenuItem(
                            value: 'Title', child: Text('Sort by Title')),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: filtered.isEmpty
                ? EmptyStateView(
                    icon: Icons.assignment_outlined,
                    title: 'No matching assignments',
                    description:
                        'Try adjusting your search query or selected status filter.',
                    actionLabel: 'Reset Filters',
                    onAction: () {
                      _searchCtrl.clear();
                      setState(() => _statusFilter = 'All');
                    },
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final asg = filtered[index];
                      final sub =
                          provider.getStudentSubmissionForAssignment(asg.id);
                      return _StudentAssignmentCard(
                        assignment: asg,
                        submission: sub,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _StudentAssignmentCard extends StatelessWidget {
  final AssignmentModel assignment;
  final SubmissionModel? submission;

  const _StudentAssignmentCard({
    required this.assignment,
    required this.submission,
  });

  @override
  Widget build(BuildContext context) {
    final isEvaluated = submission?.status == SubmissionStatus.evaluated;
    final isSubmitted = submission != null && !isEvaluated;

    final statusLabel = isEvaluated
        ? 'Evaluated'
        : isSubmitted
            ? 'Submitted'
            : (assignment.isOverdue ? 'Overdue' : 'Pending');
    final statusColor = isEvaluated
        ? AppColors.success
        : isSubmitted
            ? AppColors.primaryBlue
            : (assignment.isOverdue ? AppColors.error : AppColors.warning);
    final statusIcon = isEvaluated
        ? Icons.verified_rounded
        : isSubmitted
            ? Icons.check_circle_rounded
            : (assignment.isOverdue ? Icons.error_outline_rounded : Icons.schedule_rounded);

    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  StudentAssignmentDetailScreen(assignmentId: assignment.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.lightBlue,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${assignment.courseCode} · ${assignment.subject}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SemanticStatusLabel(
                    label: statusLabel,
                    color: statusColor,
                    icon: statusIcon,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                assignment.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 13, color: AppColors.secondaryText),
                      const SizedBox(width: 5),
                      Text(
                        'Due ${formatShortDate(assignment.deadline)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    isEvaluated
                        ? 'Marks: ${submission!.evaluation.finalMarks.toStringAsFixed(0)} / ${assignment.totalMarks}'
                        : '${assignment.totalMarks} Marks',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isEvaluated
                          ? AppColors.success
                          : AppColors.primaryText,
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

// Student Screen 3: Assignment Details
class StudentAssignmentDetailScreen extends StatelessWidget {
  final String assignmentId;

  const StudentAssignmentDetailScreen({super.key, required this.assignmentId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademiXProvider>();
    final assignment = provider.getAssignmentById(assignmentId);
    if (assignment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Assignment Details')),
        body: const EmptyStateView(
          icon: Icons.error_outline_rounded,
          title: 'Assignment not found',
          description: 'This assignment may have been removed by the instructor.',
        ),
      );
    }

    final submission = provider.getStudentSubmissionForAssignment(assignment.id);
    final isEvaluated = submission?.status == SubmissionStatus.evaluated;

    return Scaffold(
      appBar: AppBar(title: const Text('Assignment Details')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${assignment.courseCode} · ${assignment.subject}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SemanticStatusLabel(
                      label: isEvaluated
                          ? '${submission!.evaluation.finalMarks.toStringAsFixed(0)}/${assignment.totalMarks}'
                          : submission != null
                              ? 'Submitted'
                              : 'Pending',
                      color: isEvaluated
                          ? AppColors.success
                          : submission != null
                              ? AppColors.primaryBlue
                              : AppColors.warning,
                      icon: isEvaluated
                          ? Icons.verified_rounded
                          : submission != null
                              ? Icons.check_circle_rounded
                              : Icons.schedule_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  assignment.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _MetaBox(
                        icon: Icons.calendar_today_outlined,
                        label: 'Deadline',
                        value: formatShortDate(assignment.deadline),
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MetaBox(
                        icon: Icons.schedule_rounded,
                        label: 'Evaluation',
                        value: formatShortDate(assignment.evaluationTimeline ??
                            assignment.deadline.add(const Duration(days: 2))),
                        color: AppColors.darkBlue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MetaBox(
                        icon: Icons.grade_outlined,
                        label: 'Max Marks',
                        value: '${assignment.totalMarks}',
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Attached Rubric Announcement (Word / PDF / Image / Text criteria)
          if (assignment.rubricFileName != null || assignment.rubricContent != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.lightBlue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          assignment.rubricType == 'PDF'
                              ? Icons.picture_as_pdf_outlined
                              : assignment.rubricType == 'Word'
                                  ? Icons.article_outlined
                                  : assignment.rubricType == 'Image'
                                      ? Icons.image_outlined
                                      : Icons.rule_rounded,
                          size: 20,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assignment Rubric (${assignment.rubricType ?? 'Standard'})',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryText,
                              ),
                            ),
                            Text(
                              assignment.rubricFileName ?? 'Scoring Guidelines',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          assignment.rubricType?.toUpperCase() ?? 'DOC',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (assignment.rubricContent != null &&
                      assignment.rubricContent!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        assignment.rubricContent!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryText,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  assignment.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryText,
                    height: 1.55,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(),
                ),
                const Text(
                  'Submission Instructions',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                ...List.generate(assignment.instructions.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${i + 1}. ',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            assignment.instructions[i],
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.primaryText,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          if (submission != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primaryBlue.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description_outlined,
                      color: AppColors.primaryBlue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          submission.fileName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Ref: ${submission.referenceNumber} · ${submission.formattedFileSize}',
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
          ],
        ],
      ),
      bottomSheet: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              if (submission != null) ...[
                if (isEvaluated)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => StudentEvaluationDetailScreen(
                              submissionId: submission.id,
                            ),
                          ),
                        );
                      },
                      child: const Text('View Evaluation'),
                    ),
                  )
                else
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryBlue.withValues(alpha: 0.25),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.schedule_rounded, size: 16, color: AppColors.primaryBlue),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Evaluation Pending',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AssignmentUploadScreen(
                          assignment: assignment,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.upload_file_rounded, size: 18),
                  label: Text(
                    submission == null ? 'Upload Assignment' : 'Resubmit File',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetaBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}
