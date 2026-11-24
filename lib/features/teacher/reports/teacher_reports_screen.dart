import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/state/academix_provider.dart';
import '../../../core/widgets/charts.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../models/submission_model.dart';

// Teacher Screen 13: Student Performance and Reports
class TeacherReportsScreen extends StatelessWidget {
  const TeacherReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademiXProvider>();
    final assignments = provider.assignments;
    final submissions = provider.submissions;

    double avgPct = 0;
    if (submissions.isNotEmpty) {
      double sum = 0;
      for (final s in submissions) {
        final asg = provider.getAssignmentById(s.assignmentId);
        final maxM = (asg?.totalMarks ?? 100).toDouble();
        sum += maxM == 0 ? 0 : (s.evaluation.finalMarks / maxM) * 100;
      }
      avgPct = sum / submissions.length;
    }

    final avgSimilarity = submissions.isEmpty
        ? 0.0
        : submissions
                .map((s) => s.evaluation.similarityPercentage)
                .reduce((a, b) => a + b) /
            submissions.length;

    final chartItems = assignments.map((asg) {
      final subs = provider.getSubmissionsForAssignment(asg.id);
      double mean = 0;
      if (subs.isNotEmpty && asg.totalMarks > 0) {
        mean = (subs
                    .map((s) => s.evaluation.finalMarks)
                    .reduce((a, b) => a + b) /
                subs.length) /
            asg.totalMarks *
            100;
      }
      return SimpleBarSeriesItem(
        label: asg.courseCode,
        value: mean,
        color: AppColors.primaryBlue,
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Student Performance & Reports')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.48,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              KpiCard(
                label: 'Class Average',
                value: '${avgPct.toStringAsFixed(1)}%',
                icon: Icons.trending_up_rounded,
                accentColor: AppColors.success,
              ),
              KpiCard(
                label: 'Evaluated Rate',
                value: submissions.isEmpty
                    ? '0%'
                    : '${((provider.teacherEvaluatedCount / submissions.length) * 100).toInt()}%',
                icon: Icons.verified_outlined,
                accentColor: AppColors.primaryBlue,
              ),
              KpiCard(
                label: 'Avg Similarity',
                value: '${avgSimilarity.toStringAsFixed(1)}%',
                icon: Icons.plagiarism_outlined,
                accentColor: avgSimilarity > 20
                    ? AppColors.warning
                    : AppColors.success,
              ),
              KpiCard(
                label: 'Total Submissions',
                value: '${submissions.length}',
                icon: Icons.folder_copy_outlined,
                accentColor: AppColors.darkBlue,
              ),
            ],
          ),
          const SizedBox(height: 20),

          const SectionHeader(title: 'Assignment-Wise Average Score (%)'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: AcademiXBarChart(items: chartItems, maxY: 100),
          ),
          const SizedBox(height: 20),

          const SectionHeader(title: 'Assignment Submission Statistics'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: assignments.map((asg) {
                final subs = provider.getSubmissionsForAssignment(asg.id);
                final evalCount = subs
                    .where((s) => s.status == SubmissionStatus.evaluated)
                    .length;
                final ratio = asg.totalStudentsEnrolled == 0
                    ? 0.0
                    : (subs.length / asg.totalStudentsEnrolled) * 100;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: MetricBarRow(
                    label: '${asg.courseCode} · ${asg.title}',
                    value: ratio,
                    displayValue:
                        '${subs.length}/${asg.totalStudentsEnrolled} ($evalCount graded)',
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          const SectionHeader(title: 'Student-Wise Results Breakdown'),
          const SizedBox(height: 8),
          Material(
            color: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
            ),
            child: Column(
              children: submissions.map((s) {
                final asg = provider.getAssignmentById(s.assignmentId);
                return ListTile(
                  title: Text(
                    '${s.studentName} (${s.studentRollNo})',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${asg?.courseCode ?? ''} · Sim ${s.evaluation.similarityPercentage.toInt()}% · Grammar ${s.evaluation.grammarScore.toInt()}%',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.secondaryText),
                  ),
                  trailing: Text(
                    '${s.evaluation.finalMarks.toInt()}/${asg?.totalMarks ?? 100}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
