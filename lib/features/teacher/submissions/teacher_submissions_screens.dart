import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/state/academix_provider.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../models/submission_model.dart';
import '../evaluation/teacher_evaluation_screens.dart';

// Teacher Screen 5: Student Submissions
class TeacherSubmissionsScreen extends StatefulWidget {
  const TeacherSubmissionsScreen({super.key});

  @override
  State<TeacherSubmissionsScreen> createState() =>
      _TeacherSubmissionsScreenState();
}

class _TeacherSubmissionsScreenState extends State<TeacherSubmissionsScreen> {
  final _searchCtrl = TextEditingController();
  String _statusFilter = 'All';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademiXProvider>();
    final q = _searchCtrl.text.trim().toLowerCase();

    final filtered = provider.submissions.where((s) {
      final asg = provider.getAssignmentById(s.assignmentId);
      final matchesSearch = q.isEmpty ||
          s.studentName.toLowerCase().contains(q) ||
          s.studentRollNo.toLowerCase().contains(q) ||
          (asg?.title.toLowerCase().contains(q) ?? false);
      if (!matchesSearch) return false;

      if (_statusFilter == 'Pending') {
        return s.status == SubmissionStatus.submitted;
      }
      if (_statusFilter == 'Evaluated') {
        return s.status == SubmissionStatus.evaluated;
      }
      if (_statusFilter == 'Flagged') {
        return s.status == SubmissionStatus.flagged || s.evaluation.isFlagged;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submissions'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const FlaggedSubmissionsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.flag_outlined,
                size: 16, color: AppColors.error),
            label: Text(
              'Flagged (${provider.flaggedSubmissions.length})',
              style: const TextStyle(fontSize: 12, color: AppColors.error),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Search by student name, roll no, or assignment...',
                    prefixIcon: Icon(Icons.search_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Pending', 'Evaluated', 'Flagged']
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
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: active
                                ? AppColors.white
                                : AppColors.primaryText,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: filtered.isEmpty
                ? const EmptyStateView(
                    icon: Icons.inbox_outlined,
                    title: 'No submissions match your filter',
                    description:
                        'Try switching status tabs or clearing the search bar.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final sub = filtered[index];
                      final asg = provider.getAssignmentById(sub.assignmentId);
                      final isFlagged = sub.status == SubmissionStatus.flagged;
                      final isEval = sub.status == SubmissionStatus.evaluated;

                      return Material(
                        color: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isFlagged
                                ? AppColors.error.withValues(alpha: 0.45)
                                : AppColors.border,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TeacherSubmissionReviewScreen(
                                  submissionId: sub.id,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${sub.studentName} · ${sub.studentRollNo}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    SemanticStatusLabel(
                                      label: isFlagged
                                          ? 'Flagged'
                                          : isEval
                                              ? 'Evaluated'
                                              : 'Pending Review',
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
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  asg?.title ?? 'Assignment',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Submitted ${formatShortDate(sub.submittedAt)}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.secondaryText,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'AI: ${sub.evaluation.aiSuggestedMarks.toInt()}/${asg?.totalMarks ?? 100} · Sim ${sub.evaluation.similarityPercentage.toInt()}%',
                                      maxLines: 1,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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

// Teacher Screen 10: Flagged Submissions
class FlaggedSubmissionsScreen extends StatefulWidget {
  const FlaggedSubmissionsScreen({super.key});

  @override
  State<FlaggedSubmissionsScreen> createState() =>
      _FlaggedSubmissionsScreenState();
}

class _FlaggedSubmissionsScreenState extends State<FlaggedSubmissionsScreen> {
  String _flagFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademiXProvider>();
    final flagged = provider.flaggedSubmissions.where((s) {
      if (_flagFilter == 'High Similarity') {
        return s.evaluation.similarityPercentage >= 30;
      }
      if (_flagFilter == 'Low Confidence') {
        return s.evaluation.confidenceScore < 75;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Flagged Submissions')),
      body: Column(
        children: [
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'High Similarity', 'Low Confidence'].map((f) {
                  final active = _flagFilter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(f),
                      selected: active,
                      onSelected: (_) => setState(() => _flagFilter = f),
                      selectedColor: AppColors.error,
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
            child: flagged.isEmpty
                ? const EmptyStateView(
                    icon: Icons.verified_user_outlined,
                    title: 'No flagged submissions',
                    description:
                        'All submissions currently meet originality and OCR confidence thresholds.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: flagged.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final sub = flagged[index];
                      final asg = provider.getAssignmentById(sub.assignmentId);

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.45),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${sub.studentName} (${sub.studentRollNo})',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SemanticStatusLabel(
                                  label: 'Requires Attention',
                                  color: AppColors.error,
                                  icon: Icons.warning_amber_rounded,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${asg?.title ?? 'Assignment'} · ${sub.fileName}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.secondaryText,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...sub.evaluation.flagReasons.map(
                              (reason) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline_rounded,
                                        size: 16, color: AppColors.error),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        reason,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        TeacherSubmissionReviewScreen(
                                      submissionId: sub.id,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Inspect & Resolve Submission'),
                            ),
                          ],
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
