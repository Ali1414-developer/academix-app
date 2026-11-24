import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/state/academix_provider.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../models/feedback_model.dart';

// Teacher Screen 11: Grade Management
class TeacherGradeManagementScreen extends StatefulWidget {
  final String submissionId;

  const TeacherGradeManagementScreen({super.key, required this.submissionId});

  @override
  State<TeacherGradeManagementScreen> createState() =>
      _TeacherGradeManagementScreenState();
}

class _TeacherGradeManagementScreenState
    extends State<TeacherGradeManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _marksCtrl;
  late TextEditingController _commentCtrl;
  double _sliderMarks = 0;
  bool _initialized = false;

  @override
  void dispose() {
    _marksCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  String _letterGrade(double pct) {
    if (pct >= 90) return 'A';
    if (pct >= 85) return 'A-';
    if (pct >= 80) return 'B+';
    if (pct >= 75) return 'B';
    if (pct >= 70) return 'C+';
    if (pct >= 60) return 'C';
    return 'F';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademiXProvider>();
    final sub = provider.getSubmissionById(widget.submissionId);
    if (sub == null) {
      return Scaffold(appBar: AppBar(title: const Text('Grade Management')));
    }
    final asg = provider.getAssignmentById(sub.assignmentId);
    final totalMarks = (asg?.totalMarks ?? 100).toDouble();
    final eval = sub.evaluation;

    if (!_initialized) {
      _sliderMarks = eval.finalMarks.clamp(0, totalMarks);
      _marksCtrl =
          TextEditingController(text: _sliderMarks.toStringAsFixed(0));
      _commentCtrl = TextEditingController(text: eval.teacherFinalComment);
      _initialized = true;
    }

    final pct = totalMarks == 0 ? 0.0 : (_sliderMarks / totalMarks) * 100;

    return Scaffold(
      appBar: AppBar(title: const Text('Grade Management')),
      body: Form(
        key: _formKey,
        child: ListView(
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
                    '${sub.studentName} (${sub.studentRollNo})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    asg?.title ?? 'Assignment',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'AI-Suggested Marks (Simulated)',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.secondaryText),
                      ),
                      Text(
                        '${eval.aiSuggestedMarks.toStringAsFixed(0)} / ${totalMarks.toInt()}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Final Approved Marks',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${_sliderMarks.toStringAsFixed(0)}/${totalMarks.toInt()} (${_letterGrade(pct)})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _sliderMarks,
                    min: 0,
                    max: totalMarks,
                    divisions: totalMarks.toInt().clamp(1, 100),
                    activeColor: AppColors.primaryBlue,
                    onChanged: (v) {
                      setState(() {
                        _sliderMarks = v;
                        _marksCtrl.text = v.toStringAsFixed(0);
                      });
                    },
                  ),
                  TextFormField(
                    controller: _marksCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Override Marks (0 – ${totalMarks.toInt()})',
                    ),
                    onChanged: (val) {
                      final parsed = double.tryParse(val);
                      if (parsed != null &&
                          parsed >= 0 &&
                          parsed <= totalMarks) {
                        setState(() => _sliderMarks = parsed);
                      }
                    },
                    validator: (v) {
                      final parsed = double.tryParse(v ?? '');
                      if (parsed == null || parsed < 0 || parsed > totalMarks) {
                        return 'Enter a score between 0 and ${totalMarks.toInt()}';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _commentCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Final Evaluation Comments (Visible to Student)',
                hintText:
                    'Summarize strengths, rubric adjustments, and recommendations...',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                final confirmed = await showAcademiXConfirmDialog(
                  context: context,
                  title: 'Approve Final Grade',
                  message:
                      'Publish ${_sliderMarks.toStringAsFixed(0)}/${totalMarks.toInt()} for ${sub.studentName}? The updated grade will appear immediately in the Student Portal.',
                  confirmLabel: 'Approve Grade',
                );
                if (confirmed && context.mounted) {
                  provider.approveGrade(
                    submissionId: sub.id,
                    finalMarks: _sliderMarks,
                    finalComment: _commentCtrl.text,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Grade approved and published to Student Portal.'),
                    ),
                  );
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.verified_outlined, size: 18),
              label: Text(
                eval.isTeacherApproved
                    ? 'Update Approved Grade'
                    : 'Approve & Confirm Final Grade',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Teacher Screen 12: Feedback Management
class TeacherFeedbackManagementScreen extends StatefulWidget {
  final String submissionId;

  const TeacherFeedbackManagementScreen({
    super.key,
    required this.submissionId,
  });

  @override
  State<TeacherFeedbackManagementScreen> createState() =>
      _TeacherFeedbackManagementScreenState();
}

class _TeacherFeedbackManagementScreenState
    extends State<TeacherFeedbackManagementScreen> {
  final _feedbackCtrl = TextEditingController();
  FeedbackStatus _status = FeedbackStatus.published;
  String? _editingId;

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  void _saveFeedback(AcademiXProvider provider) {
    if (_feedbackCtrl.text.trim().length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter at least 5 characters of feedback.')),
      );
      return;
    }

    provider.saveFeedback(
      submissionId: widget.submissionId,
      message: _feedbackCtrl.text,
      status: _status,
      editingFeedbackId: _editingId,
    );

    setState(() {
      _feedbackCtrl.clear();
      _editingId = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _status == FeedbackStatus.published
              ? 'Feedback published to Student Portal.'
              : 'Feedback saved as draft.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademiXProvider>();
    final sub = provider.getSubmissionById(widget.submissionId);
    if (sub == null) {
      return Scaffold(appBar: AppBar(title: const Text('Feedback Management')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Feedback Management')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
                Text(
                  _editingId == null
                      ? 'Write Feedback for ${sub.studentName}'
                      : 'Edit Selected Feedback',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _feedbackCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText:
                        'Provide constructive academic feedback, rubric guidance, or next steps...',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Publish to Student'),
                      selected: _status == FeedbackStatus.published,
                      selectedColor: AppColors.primaryBlue,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: _status == FeedbackStatus.published
                            ? AppColors.white
                            : AppColors.primaryText,
                      ),
                      onSelected: (_) =>
                          setState(() => _status = FeedbackStatus.published),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Save Draft'),
                      selected: _status == FeedbackStatus.draft,
                      selectedColor: AppColors.darkBlue,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: _status == FeedbackStatus.draft
                            ? AppColors.white
                            : AppColors.primaryText,
                      ),
                      onSelected: (_) =>
                          setState(() => _status = FeedbackStatus.draft),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    if (_editingId != null) ...[
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _editingId = null;
                            _feedbackCtrl.clear();
                          });
                        },
                        child: const Text('Cancel Edit'),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _saveFeedback(provider),
                        child: Text(_editingId == null
                            ? 'Save Feedback'
                            : 'Update Feedback'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Quick Adopt Simulated AI Suggestion
          const SectionHeader(title: 'Adopt Simulated AI Suggestions'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sub.evaluation.aiSuggestions
                .map(
                  (tip) => OutlinedButton(
                    onPressed: () {
                      final existing = _feedbackCtrl.text.trim();
                      _feedbackCtrl.text =
                          existing.isEmpty ? tip : '$existing\n$tip';
                    },
                    child: Text(
                      '+ ${tip.length > 44 ? '${tip.substring(0, 44)}...' : tip}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),

          // Previously Provided Feedback
          SectionHeader(
              title: 'Previously Provided Feedback (${sub.feedbackList.length})'),
          const SizedBox(height: 8),
          if (sub.feedbackList.isEmpty)
            const EmptyStateView(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'No feedback provided yet',
              description:
                  'Write your first instructor comment above to guide the student.',
            )
          else
            ...sub.feedbackList.map(
              (fb) {
                final isPublished = fb.status == FeedbackStatus.published;
                return Padding(
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
                            SemanticStatusLabel(
                              label: isPublished ? 'Published' : 'Draft',
                              color: isPublished
                                  ? AppColors.success
                                  : AppColors.warning,
                              icon: isPublished
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.edit_note_rounded,
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _editingId = fb.id;
                                  _feedbackCtrl.text = fb.message;
                                  _status = fb.status;
                                });
                              },
                              child: const Text('Edit'),
                            ),
                          ],
                        ),
                        Text(
                          fb.message,
                          style: const TextStyle(fontSize: 13, height: 1.5),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Updated ${formatDateTime(fb.updatedAt)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
