import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/state/academix_provider.dart';
import '../../../core/widgets/charts.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../models/submission_model.dart';
import '../feedback/student_feedback_screen.dart';

// Student Screen 8 (Tab Root): Evaluation Results List
class StudentResultsTabScreen extends StatelessWidget {
  const StudentResultsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademiXProvider>();
    final submissions = provider.studentSubmissions;

    return Scaffold(
      appBar: AppBar(title: const Text('Evaluation Results')),
      body: submissions.isEmpty
          ? const EmptyStateView(
              icon: Icons.bar_chart_rounded,
              title: 'No evaluation reports yet',
              description:
                  'Upload an assignment to inspect simulated evaluation scores, plagiarism analysis, and teacher feedback.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: submissions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final sub = submissions[index];
                final asg = provider.getAssignmentById(sub.assignmentId);
                final isEvaluated = sub.status == SubmissionStatus.evaluated;
                final isApproved = sub.evaluation.isTeacherApproved;
                final totalMarks = asg?.totalMarks ?? 100;

                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            StudentEvaluationDetailScreen(submissionId: sub.id),
                      ),
                    );
                  },
                  child: Container(
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
                            Expanded(
                              child: Text(
                                '${asg?.courseCode ?? 'COURSE'} · ${asg?.subject ?? ''}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SemanticStatusLabel(
                              label: isEvaluated
                                  ? (isApproved ? 'Approved' : 'AI Evaluated')
                                  : 'Pending Release',
                              color: isEvaluated
                                  ? (isApproved ? AppColors.success : AppColors.primaryBlue)
                                  : AppColors.warning,
                              icon: isEvaluated
                                  ? (isApproved ? Icons.verified_rounded : Icons.auto_awesome_rounded)
                                  : Icons.schedule_rounded,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          asg?.title ?? 'Submission',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (isEvaluated)
                          Row(
                            children: [
                              _MiniScoreCell(
                                label: 'Marks',
                                value:
                                    '${sub.evaluation.finalMarks.toStringAsFixed(0)}/$totalMarks',
                                color: AppColors.primaryBlue,
                              ),
                              _MiniScoreCell(
                                label: 'Content',
                                value:
                                    '${sub.evaluation.contentQualityScore.toInt()}%',
                                color: AppColors.success,
                              ),
                              _MiniScoreCell(
                                label: 'Grammar',
                                value: '${sub.evaluation.grammarScore.toInt()}%',
                                color: AppColors.darkBlue,
                              ),
                              _MiniScoreCell(
                                label: 'Similarity',
                                value:
                                    '${sub.evaluation.similarityPercentage.toInt()}%',
                                color: sub.evaluation.similarityPercentage > 25
                                    ? AppColors.error
                                    : AppColors.success,
                              ),
                            ],
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.schedule_rounded, size: 14, color: AppColors.secondaryText),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Evaluation Release: ${formatShortDate(asg?.evaluationTimeline ?? (asg != null ? asg.deadline.add(const Duration(days: 2)) : DateTime.now()))} (by ${asg?.teacherName ?? 'Teacher'})',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _MiniScoreCell extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniScoreCell({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// Student Screen 8 (Detail): Evaluation Results Breakdown
class StudentEvaluationDetailScreen extends StatelessWidget {
  final String submissionId;

  const StudentEvaluationDetailScreen({super.key, required this.submissionId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademiXProvider>();
    final submission = provider.getSubmissionById(submissionId);
    if (submission == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Evaluation Results')),
        body: const EmptyStateView(
          icon: Icons.bar_chart_outlined,
          title: 'Report unavailable',
          description: 'The selected submission could not be found.',
        ),
      );
    }

    final assignment = provider.getAssignmentById(submission.assignmentId);
    final eval = submission.evaluation;
    final totalMarks = assignment?.totalMarks ?? 100;
    final pct = totalMarks == 0 ? 0.0 : (eval.finalMarks / totalMarks) * 100;

    return Scaffold(
      appBar: AppBar(title: const Text('Evaluation Results')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (submission.status != SubmissionStatus.evaluated) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryBlue.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.schedule_rounded,
                          color: AppColors.primaryBlue, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Evaluation Pending Release',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Instructor ${assignment?.teacherName ?? 'Teacher'} will run automated OCR scanning (for handwritten files) and AI rubric grading after the assignment deadline on ${formatShortDate(assignment?.evaluationTimeline ?? assignment?.deadline.add(const Duration(days: 2)) ?? DateTime.now())}.',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.primaryText,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ] else if (!eval.isTeacherApproved) ...[
            const SimulatedNoticeBanner(
              text:
                  'Pending teacher approval: current scores reflect simulated AI evaluation preview data.',
            ),
            const SizedBox(height: 14),
          ],
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment?.title ?? 'Assignment Evaluation',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${submission.fileName} · Ref ${submission.referenceNumber}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    ScoreRingChart(
                      value: pct,
                      centerLabel:
                          '${eval.finalMarks.toStringAsFixed(0)}/$totalMarks',
                      caption: eval.isTeacherApproved
                          ? 'Final Grade'
                          : 'AI Preview',
                      color: eval.isTeacherApproved
                          ? AppColors.success
                          : AppColors.primaryBlue,
                      size: 112,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        children: [
                          MetricBarRow(
                            label: 'Content Quality',
                            value: eval.contentQualityScore,
                            displayValue: '${eval.contentQualityScore.toInt()}%',
                            color: AppColors.primaryBlue,
                          ),
                          const SizedBox(height: 12),
                          MetricBarRow(
                            label: 'Grammar & Clarity',
                            value: eval.grammarScore,
                            displayValue: '${eval.grammarScore.toInt()}%',
                            color: AppColors.darkBlue,
                          ),
                          const SizedBox(height: 12),
                          MetricBarRow(
                            label: 'Similarity Index',
                            value: eval.similarityPercentage,
                            displayValue:
                                '${eval.similarityPercentage.toInt()}%',
                            color: eval.similarityPercentage > 25
                                ? AppColors.error
                                : AppColors.success,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const SectionHeader(title: 'Rubric Score Chart'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: AcademiXBarChart(
              maxY: 100,
              items: eval.rubric.map((r) {
                final ratio = r.maxScore == 0 ? 0.0 : (r.earned / r.maxScore) * 100;
                return SimpleBarSeriesItem(
                  label: r.criterion.split(' ').first,
                  value: ratio,
                  color: AppColors.primaryBlue,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),
          const SectionHeader(title: 'Detailed Analysis Reports'),
          const SizedBox(height: 8),
          _ReportLinkTile(
            icon: Icons.plagiarism_outlined,
            title: 'Plagiarism Report',
            subtitle:
                '${eval.similarityPercentage.toInt()}% similarity · ${eval.originalityStatus}',
            accent: eval.similarityPercentage > 25
                ? AppColors.error
                : AppColors.success,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      StudentPlagiarismReportScreen(submission: submission),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _ReportLinkTile(
            icon: Icons.spellcheck_rounded,
            title: 'Grammar & Content Analysis',
            subtitle:
                'Grammar ${eval.grammarScore.toInt()}% · ${eval.grammarIssues.length} suggestions · ${eval.readabilityLevel}',
            accent: AppColors.primaryBlue,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      StudentGrammarAnalysisScreen(submission: submission),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _ReportLinkTile(
            icon: Icons.rate_review_outlined,
            title: 'Feedback & Suggestions',
            subtitle:
                '${submission.feedbackList.length} teacher comment(s) · ${eval.aiSuggestions.length} simulated AI suggestions',
            accent: AppColors.darkBlue,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      StudentFeedbackScreen(submissionId: submission.id),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ReportLinkTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  const _ReportLinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent, size: 20),
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
                  size: 13, color: AppColors.secondaryText),
            ],
          ),
        ),
      ),
    );
  }
}

// Student Screen 9: Plagiarism Report
class StudentPlagiarismReportScreen extends StatelessWidget {
  final SubmissionModel submission;

  const StudentPlagiarismReportScreen({super.key, required this.submission});

  @override
  Widget build(BuildContext context) {
    final eval = submission.evaluation;
    final simColor = eval.similarityPercentage <= 15
        ? AppColors.success
        : eval.similarityPercentage <= 30
            ? AppColors.warning
            : AppColors.error;

    return Scaffold(
      appBar: AppBar(title: const Text('Plagiarism Report')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SimulatedNoticeBanner(
            text:
                'Simulated similarity report using sample text matching for frontend prototype verification.',
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(20),
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
                  size: 108,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SemanticStatusLabel(
                        label: eval.originalityStatus,
                        color: simColor,
                        icon: eval.similarityPercentage <= 15
                            ? Icons.verified_user_outlined
                            : Icons.warning_amber_rounded,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${(100 - eval.similarityPercentage).toInt()}% Original Content',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${eval.plagiarismMatches.length} matched source(s) identified across ${eval.wordCount} words.',
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
          const SizedBox(height: 18),
          const SectionHeader(title: 'Highlighted Document Excerpt'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: _HighlightedPlagiarismText(
              fullText: submission.extractedText,
              highlights: eval.plagiarismMatches
                  .map((m) => m.matchedExcerpt)
                  .toList(),
            ),
          ),
          const SizedBox(height: 18),
          const SectionHeader(title: 'Matched Sources Breakdown'),
          const SizedBox(height: 8),
          ...eval.plagiarismMatches.map(
            (match) => Padding(
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
                            match.sourceTitle,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          '${match.matchPercent.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: simColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      match.sourceDomain,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.warningLight.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '"${match.matchedExcerpt}"',
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightedPlagiarismText extends StatelessWidget {
  final String fullText;
  final List<String> highlights;

  const _HighlightedPlagiarismText({
    required this.fullText,
    required this.highlights,
  });

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    String remaining = fullText;

    for (final excerpt in highlights) {
      final idx = remaining.toLowerCase().indexOf(excerpt.toLowerCase());
      if (idx != -1) {
        if (idx > 0) {
          spans.add(TextSpan(text: remaining.substring(0, idx)));
        }
        spans.add(
          TextSpan(
            text: remaining.substring(idx, idx + excerpt.length),
            style: const TextStyle(
              backgroundColor: AppColors.warningLight,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
        );
        remaining = remaining.substring(idx + excerpt.length);
      }
    }
    if (remaining.isNotEmpty) {
      spans.add(TextSpan(text: remaining));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 13,
          height: 1.65,
          color: AppColors.primaryText,
        ),
        children: spans,
      ),
    );
  }
}

// Student Screen 10: Grammar and Content Analysis
class StudentGrammarAnalysisScreen extends StatelessWidget {
  final SubmissionModel submission;

  const StudentGrammarAnalysisScreen({super.key, required this.submission});

  @override
  Widget build(BuildContext context) {
    final eval = submission.evaluation;

    return Scaffold(
      appBar: AppBar(title: const Text('Grammar & Content Analysis')),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Writing Quality Metrics',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${eval.wordCount} words',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Readability: ${eval.readabilityLevel}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                MetricBarRow(
                  label: 'Grammar Accuracy',
                  value: eval.grammarScore,
                  displayValue: '${eval.grammarScore.toInt()}%',
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(height: 12),
                MetricBarRow(
                  label: 'Content Quality',
                  value: eval.contentQualityScore,
                  displayValue: '${eval.contentQualityScore.toInt()}%',
                  color: AppColors.success,
                ),
                const SizedBox(height: 12),
                MetricBarRow(
                  label: 'Organization & Structure',
                  value: eval.organizationScore,
                  displayValue: '${eval.organizationScore.toInt()}%',
                  color: AppColors.darkBlue,
                ),
                const SizedBox(height: 12),
                MetricBarRow(
                  label: 'Readability & Flow',
                  value: eval.readabilityScore,
                  displayValue: '${eval.readabilityScore.toInt()}%',
                  color: AppColors.primaryBlue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const SectionHeader(title: 'Spelling & Sentence Suggestions'),
          const SizedBox(height: 8),
          if (eval.grammarIssues.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'No spelling or sentence structure issues detected in this submission.',
                style: TextStyle(color: AppColors.success, fontSize: 13),
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
                      const SizedBox(height: 6),
                      Text(
                        issue.originalText,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.error,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        issue.suggestion,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(height: 6),
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
          const SizedBox(height: 14),
          const SectionHeader(title: 'Organization & Structure Feedback'),
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
              children: eval.structureFeedback
                  .map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 16,
                            color: AppColors.primaryBlue,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              f,
                              style: const TextStyle(fontSize: 13, height: 1.45),
                            ),
                          ),
                        ],
                      ),
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
