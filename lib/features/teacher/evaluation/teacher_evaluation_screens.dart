import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/state/academix_provider.dart';
import '../../../core/widgets/charts.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../models/submission_model.dart';
import '../grading/teacher_grading_feedback_screens.dart';

// Teacher Screen 6: Submission Review
class TeacherSubmissionReviewScreen extends StatelessWidget {
  final String submissionId;

  const TeacherSubmissionReviewScreen({super.key, required this.submissionId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademiXProvider>();
    final sub = provider.getSubmissionById(submissionId);
    if (sub == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Submission Review')),
        body: const EmptyStateView(
          icon: Icons.error_outline_rounded,
          title: 'Submission not found',
          description: 'Unable to load the requested student submission.',
        ),
      );
    }

    final asg = provider.getAssignmentById(sub.assignmentId);
    final eval = sub.evaluation;
    final totalMarks = asg?.totalMarks ?? 100;

    return Scaffold(
      appBar: AppBar(title: const Text('Submission Review')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Student & File Header
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sub.studentName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${sub.studentRollNo} · Ref ${sub.referenceNumber}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SemanticStatusLabel(
                      label: sub.status == SubmissionStatus.evaluated
                          ? 'Approved'
                          : sub.status == SubmissionStatus.flagged
                              ? 'Flagged'
                              : 'Pending',
                      color: sub.status == SubmissionStatus.evaluated
                          ? AppColors.success
                          : sub.status == SubmissionStatus.flagged
                              ? AppColors.error
                              : AppColors.warning,
                      icon: sub.status == SubmissionStatus.evaluated
                          ? Icons.verified_rounded
                          : Icons.pending_outlined,
                    ),
                  ],
                ),
                const Divider(height: 24),
                Text(
                  asg?.title ?? 'Assignment',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'File: ${sub.fileName} (${sub.fileFormat}, ${sub.formattedFileSize})',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  'Submitted: ${formatDateTime(sub.submittedAt)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick Metrics Strip
          Row(
            children: [
              Expanded(
                child: KpiCard(
                  label: 'Final / AI Marks',
                  value: '${eval.finalMarks.toInt()}/$totalMarks',
                  icon: Icons.grade_outlined,
                  accentColor: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KpiCard(
                  label: 'Similarity',
                  value: '${eval.similarityPercentage.toInt()}%',
                  icon: Icons.plagiarism_outlined,
                  accentColor: eval.similarityPercentage > 25
                      ? AppColors.error
                      : AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Extracted Content Preview
          const SectionHeader(title: 'Submission Content Preview (OCR Sample)'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              sub.extractedText,
              style: const TextStyle(
                fontSize: 13,
                height: 1.6,
                color: AppColors.primaryText,
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Review Tools Navigation
          const SectionHeader(title: 'Review & Grading Actions'),
          const SizedBox(height: 8),
          _ReviewActionTile(
            icon: Icons.analytics_outlined,
            title: 'AI Evaluation Report',
            subtitle:
                'Content ${eval.contentQualityScore.toInt()}% · Grammar ${eval.grammarScore.toInt()}% · Rubric chart',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      TeacherAiEvaluationReportScreen(submissionId: sub.id),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _ReviewActionTile(
            icon: Icons.plagiarism_outlined,
            title: 'Plagiarism Review',
            subtitle:
                '${eval.similarityPercentage.toInt()}% similarity · ${eval.plagiarismReviewed ? 'Reviewed' : 'Needs Review'}',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      TeacherPlagiarismReviewScreen(submissionId: sub.id),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _ReviewActionTile(
            icon: Icons.spellcheck_rounded,
            title: 'Grammar & Content Review',
            subtitle:
                '${eval.grammarIssues.length} detected issue(s) · ${eval.readabilityLevel}',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      TeacherGrammarReviewScreen(submissionId: sub.id),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _ReviewActionTile(
            icon: Icons.fact_check_outlined,
            title: 'Grade Management',
            subtitle:
                'Modify marks, confirm final grade (${eval.finalMarks.toInt()}/$totalMarks), and approve',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      TeacherGradeManagementScreen(submissionId: sub.id),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _ReviewActionTile(
            icon: Icons.rate_review_outlined,
            title: 'Feedback Management',
            subtitle:
                '${sub.feedbackList.length} feedback record(s) · Write or edit student feedback',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      TeacherFeedbackManagementScreen(submissionId: sub.id),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ReviewActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ReviewActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.lightBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primaryBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 12, color: AppColors.secondaryText),
            ],
          ),
        ),
      ),
    );
  }
}

// Teacher Screen 7: AI Evaluation Report
class TeacherAiEvaluationReportScreen extends StatelessWidget {
  final String submissionId;

  const TeacherAiEvaluationReportScreen({
    super.key,
    required this.submissionId,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademiXProvider>();
    final sub = provider.getSubmissionById(submissionId);
    if (sub == null) {
      return Scaffold(appBar: AppBar(title: const Text('AI Evaluation Report')));
    }
    final asg = provider.getAssignmentById(sub.assignmentId);
    final eval = sub.evaluation;
    final total = asg?.totalMarks ?? 100;
    final pct = total == 0 ? 0.0 : (eval.aiSuggestedMarks / total) * 100;

    return Scaffold(
      appBar: AppBar(title: const Text('AI Evaluation Report')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SimulatedNoticeBanner(
            text:
                'Simulated AI evaluation report. Teacher review and manual confirmation are required before final marks are published.',
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                ScoreRingChart(
                  value: pct,
                  centerLabel: '${eval.aiSuggestedMarks.toInt()}/$total',
                  caption: 'AI Suggested',
                  color: AppColors.primaryBlue,
                  size: 110,
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    children: [
                      MetricBarRow(
                        label: 'Content Quality',
                        value: eval.contentQualityScore,
                        displayValue: '${eval.contentQualityScore.toInt()}%',
                      ),
                      const SizedBox(height: 10),
                      MetricBarRow(
                        label: 'Grammar',
                        value: eval.grammarScore,
                        displayValue: '${eval.grammarScore.toInt()}%',
                        color: AppColors.darkBlue,
                      ),
                      const SizedBox(height: 10),
                      MetricBarRow(
                        label: 'Similarity',
                        value: eval.similarityPercentage,
                        displayValue: '${eval.similarityPercentage.toInt()}%',
                        color: eval.similarityPercentage > 25
                            ? AppColors.error
                            : AppColors.success,
                      ),
                      const SizedBox(height: 10),
                      MetricBarRow(
                        label: 'Confidence',
                        value: eval.confidenceScore,
                        displayValue: '${eval.confidenceScore.toInt()}%',
                        color: eval.confidenceScore < 75
                            ? AppColors.warning
                            : AppColors.success,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const SectionHeader(title: 'Rubric Criterion Breakdown'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                AcademiXBarChart(
                  maxY: 100,
                  items: eval.rubric.map((r) {
                    final rPct =
                        r.maxScore == 0 ? 0.0 : (r.earned / r.maxScore) * 100;
                    return SimpleBarSeriesItem(
                      label: r.criterion.split(' ').first,
                      value: rPct,
                    );
                  }).toList(),
                ),
                const Divider(height: 24),
                ...eval.rubric.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: MetricBarRow(
                      label: r.criterion,
                      value: r.maxScore == 0 ? 0 : (r.earned / r.maxScore) * 100,
                      displayValue:
                          '${r.earned.toInt()} / ${r.maxScore.toInt()}',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      TeacherGradeManagementScreen(submissionId: sub.id),
                ),
              );
            },
            child: const Text('Proceed to Grade Management'),
          ),
        ],
      ),
    );
  }
}

// Teacher Screen 8: Plagiarism Review
class TeacherPlagiarismReviewScreen extends StatelessWidget {
  final String submissionId;

  const TeacherPlagiarismReviewScreen({super.key, required this.submissionId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademiXProvider>();
    final sub = provider.getSubmissionById(submissionId);
    if (sub == null) {
      return Scaffold(appBar: AppBar(title: const Text('Plagiarism Review')));
    }
    final eval = sub.evaluation;
    final simColor = eval.similarityPercentage <= 15
        ? AppColors.success
        : eval.similarityPercentage <= 30
            ? AppColors.warning
            : AppColors.error;

    return Scaffold(
      appBar: AppBar(title: const Text('Plagiarism Review')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                ScoreRingChart(
                  value: eval.similarityPercentage,
                  centerLabel: '${eval.similarityPercentage.toInt()}%',
                  caption: 'Similarity',
                  color: simColor,
                  size: 104,
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SemanticStatusLabel(
                        label: eval.originalityStatus,
                        color: simColor,
                        icon: Icons.plagiarism_outlined,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        eval.plagiarismReviewed
                            ? 'Instructor Check: Reviewed'
                            : 'Instructor Check: Pending Verification',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${eval.plagiarismMatches.length} matched passage(s) detected in simulated scan.',
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
          const SizedBox(height: 16),
          const SectionHeader(title: 'Highlighted Matching Content'),
          const SizedBox(height: 8),
          ...eval.plagiarismMatches.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            m.sourceTitle,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          '${m.matchPercent.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: simColor,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      m.sourceDomain,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.secondaryText),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '"${m.matchedExcerpt}"',
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    provider.markPlagiarismReviewed(sub.id,
                        flagIntegrity: true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Submission flagged for academic integrity.'),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                  child: const Text('Flag Integrity'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    provider.markPlagiarismReviewed(sub.id,
                        flagIntegrity: false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Plagiarism report marked as reviewed.'),
                      ),
                    );
                  },
                  child: const Text('Mark Reviewed'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Teacher Screen 9: Grammar and Content Review
class TeacherGrammarReviewScreen extends StatelessWidget {
  final String submissionId;

  const TeacherGrammarReviewScreen({super.key, required this.submissionId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademiXProvider>();
    final sub = provider.getSubmissionById(submissionId);
    if (sub == null) {
      return Scaffold(
          appBar: AppBar(title: const Text('Grammar & Content Review')));
    }
    final eval = sub.evaluation;

    return Scaffold(
      appBar: AppBar(title: const Text('Grammar & Content Review')),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
                Text(
                  'Writing Quality — ${sub.studentName}',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 14),
                MetricBarRow(
                  label: 'Grammar Score',
                  value: eval.grammarScore,
                  displayValue: '${eval.grammarScore.toInt()}%',
                ),
                const SizedBox(height: 10),
                MetricBarRow(
                  label: 'Content Quality',
                  value: eval.contentQualityScore,
                  displayValue: '${eval.contentQualityScore.toInt()}%',
                  color: AppColors.success,
                ),
                const SizedBox(height: 10),
                MetricBarRow(
                  label: 'Content Structure',
                  value: eval.organizationScore,
                  displayValue: '${eval.organizationScore.toInt()}%',
                  color: AppColors.darkBlue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const SectionHeader(title: 'Detected Grammar & Spelling Issues'),
          const SizedBox(height: 8),
          if (eval.grammarIssues.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No grammar or spelling errors detected.'),
              ),
            )
          else
            ...eval.grammarIssues.map(
              (issue) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        issue.type,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        issue.originalText,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.error,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      Text(
                        issue.suggestion,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        issue.explanation,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          const SectionHeader(title: 'Simulated AI Suggestions'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: eval.aiSuggestions
                  .map(
                    (tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('• $tip', style: const TextStyle(fontSize: 13)),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
