import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/state/academix_provider.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../models/feedback_model.dart';

// Student Screen 11: Feedback and Suggestions
class StudentFeedbackScreen extends StatelessWidget {
  final String submissionId;

  const StudentFeedbackScreen({super.key, required this.submissionId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademiXProvider>();
    final submission = provider.getSubmissionById(submissionId);
    if (submission == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Feedback & Suggestions')),
        body: const EmptyStateView(
          icon: Icons.rate_review_outlined,
          title: 'Submission not found',
          description: 'Unable to load feedback for this submission.',
        ),
      );
    }

    final publishedTeacherFeedback = submission.feedbackList
        .where((f) => f.status == FeedbackStatus.published)
        .toList();
    final aiSuggestions = submission.evaluation.aiSuggestions;

    return Scaffold(
      appBar: AppBar(title: const Text('Feedback & Suggestions')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section 1: Teacher-Approved Feedback
          const SectionHeader(title: 'Teacher-Approved Feedback'),
          const SizedBox(height: 8),
          if (publishedTeacherFeedback.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SemanticStatusLabel(
                    label: 'Awaiting Instructor Review',
                    color: AppColors.warning,
                    icon: Icons.hourglass_empty_rounded,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Your instructor has not published written feedback for this submission yet. Once approved in the Teacher Portal, it will appear here.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            )
          else
            ...publishedTeacherFeedback.map(
              (fb) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              fb.teacherName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const SemanticStatusLabel(
                            label: 'Approved',
                            color: AppColors.success,
                            icon: Icons.verified_rounded,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatDateTime(fb.updatedAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        fb.message,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.55,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Section 2: Simulated AI Suggestions (Clearly Separated)
          const SectionHeader(title: 'Simulated AI Study Suggestions'),
          const SizedBox(height: 8),
          const SimulatedNoticeBanner(
            text:
                'These automated suggestions are simulated prototype tips and are kept strictly separate from official teacher-approved feedback.',
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: List.generate(aiSuggestions.length, (i) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: i == aiSuggestions.length - 1 ? 0 : 12,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.lightBlue,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          aiSuggestions[i],
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: AppColors.primaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
