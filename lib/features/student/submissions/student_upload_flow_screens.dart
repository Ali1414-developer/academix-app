import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/state/academix_provider.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../models/assignment_model.dart';
import '../../../models/submission_model.dart';

class SelectedUploadFile {
  final String name;
  final String extension;
  final int sizeKb;

  const SelectedUploadFile({
    required this.name,
    required this.extension,
    required this.sizeKb,
  });

  String get formattedSize => sizeKb >= 1024
      ? '${(sizeKb / 1024).toStringAsFixed(2)} MB'
      : '$sizeKb KB';
}

// Student Screen: Assignment Upload (Direct Student Submission — No Student OCR/Check Access)
class AssignmentUploadScreen extends StatefulWidget {
  final AssignmentModel assignment;

  const AssignmentUploadScreen({super.key, required this.assignment});

  @override
  State<AssignmentUploadScreen> createState() => _AssignmentUploadScreenState();
}

class _AssignmentUploadScreenState extends State<AssignmentUploadScreen> {
  SelectedUploadFile? _selectedFile;
  bool _isSubmitting = false;

  Future<void> _pickDeviceFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'doc', 'png', 'jpg', 'jpeg'],
      );
      if (result != null && result.files.isNotEmpty) {
        final f = result.files.first;
        setState(() {
          _selectedFile = SelectedUploadFile(
            name: f.name,
            extension: (f.extension ?? 'pdf').toUpperCase(),
            sizeKb: (f.size / 1024).ceil().clamp(1, 50000),
          );
        });
      }
    } catch (_) {
      _useSampleFile(
        const SelectedUploadFile(
          name: 'Ayesha_Coursework_Submission.pdf',
          extension: 'PDF',
          sizeKb: 1420,
        ),
      );
    }
  }

  void _useSampleFile(SelectedUploadFile file) {
    setState(() => _selectedFile = file);
  }

  bool get _isFormatValid {
    if (_selectedFile == null) return false;
    return widget.assignment.allowedFormats.contains(_selectedFile!.extension);
  }

  bool get _isSizeValid {
    if (_selectedFile == null) return false;
    return _selectedFile!.sizeKb <= 10240; // 10 MB
  }

  bool get _canSubmit =>
      _selectedFile != null && _isFormatValid && _isSizeValid && !_isSubmitting;

  Future<void> _handleSubmit() async {
    if (!_canSubmit) return;

    setState(() => _isSubmitting = true);

    // Subtle mobile upload simulation
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    final isHandwritten =
        ['PNG', 'JPG', 'JPEG'].contains(_selectedFile!.extension);
    final ocrPendingNote = isHandwritten
        ? 'Handwritten submission (${_selectedFile!.name}). Queued for automated OCR processing after deadline.'
        : 'Digital document submission (${_selectedFile!.name}). Queued for instructor rubric evaluation.';

    final submission = context.read<AcademiXProvider>().submitAssignment(
          assignment: widget.assignment,
          fileName: _selectedFile!.name,
          fileFormat: _selectedFile!.extension,
          fileSizeKb: _selectedFile!.sizeKb,
          extractedText: ocrPendingNote,
        );

    setState(() => _isSubmitting = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => SubmissionConfirmationScreen(
          assignment: widget.assignment,
          submission: submission,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asg = widget.assignment;

    return Scaffold(
      appBar: AppBar(title: const Text('Submit Assignment')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Assignment Brief Card
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${asg.courseCode} · ${asg.subject}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${asg.totalMarks} Marks',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  asg.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Allowed formats: ${asg.allowedFormats.join(', ')} · Max size: 10 MB',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Policy Banner (Explaining Teacher Evaluation Timeline & OCR Workflow)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primaryBlue.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Coursework Submission Policy',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Upload your solution below. If your work is handwritten, automated OCR scanning and AI rubric grading will be processed and released by ${asg.teacherName} after the submission deadline.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryText,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Native File Picker Card
          InkWell(
            onTap: _pickDeviceFile,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryBlue.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.cloud_upload_outlined,
                      size: 26,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Select Coursework File',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to browse device for PDF, DOCX, or handwritten photo (${asg.allowedFormats.join(', ')})',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Sample Test Files Strip
          const Text(
            'Or select a sample submission file:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _useSampleFile(
                  const SelectedUploadFile(
                    name: 'Ayesha_Coursework_Final.pdf',
                    extension: 'PDF',
                    sizeKb: 1580,
                  ),
                ),
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                label: const Text('Valid PDF'),
              ),
              OutlinedButton.icon(
                onPressed: () => _useSampleFile(
                  const SelectedUploadFile(
                    name: 'Handwritten_Assignment_Scan.png',
                    extension: 'PNG',
                    sizeKb: 2150,
                  ),
                ),
                icon: const Icon(Icons.image_outlined, size: 16),
                label: const Text('Handwritten Scan (PNG)'),
              ),
              OutlinedButton.icon(
                onPressed: () => _useSampleFile(
                  const SelectedUploadFile(
                    name: 'Coursework_Draft.docx',
                    extension: 'DOCX',
                    sizeKb: 890,
                  ),
                ),
                icon: const Icon(Icons.description_outlined, size: 16),
                label: const Text('Word DOCX'),
              ),
            ],
          ),

          // Selected File Card with validation feedback
          if (_selectedFile != null) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isFormatValid && _isSizeValid
                      ? AppColors.border
                      : AppColors.error,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _isFormatValid && _isSizeValid
                              ? AppColors.lightBlue
                              : AppColors.errorLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _selectedFile!.extension == 'PDF'
                              ? Icons.picture_as_pdf_outlined
                              : _selectedFile!.extension == 'DOCX'
                                  ? Icons.article_outlined
                                  : Icons.image_outlined,
                          color: _isFormatValid && _isSizeValid
                              ? AppColors.primaryBlue
                              : AppColors.error,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedFile!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Format: ${_selectedFile!.extension} · Size: ${_selectedFile!.formattedSize}',
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
                  if (!_isFormatValid) ...[
                    const SizedBox(height: 8),
                    Text(
                      '⚠ Format ${_selectedFile!.extension} not accepted. Allowed: ${asg.allowedFormats.join(', ')}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (!_isSizeValid) ...[
                    const SizedBox(height: 8),
                    const Text(
                      '⚠ File exceeds maximum allowed size of 10 MB.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _pickDeviceFile,
                          child: const Text('Replace'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _selectedFile = null),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                          ),
                          child: const Text('Remove'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Primary Submission Button
          ElevatedButton.icon(
            onPressed: _canSubmit ? _handleSubmit : null,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.send_rounded, size: 18),
            label: Text(_isSubmitting ? 'Submitting...' : 'Submit Assignment'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Student Screen: Submission Confirmation (Clear Deadline & Timeline Information)
class SubmissionConfirmationScreen extends StatelessWidget {
  final AssignmentModel assignment;
  final SubmissionModel submission;

  const SubmissionConfirmationScreen({
    super.key,
    required this.assignment,
    required this.submission,
  });

  @override
  Widget build(BuildContext context) {
    final evalTimeline = assignment.evaluationTimeline ??
        assignment.deadline.add(const Duration(days: 2));

    final isHandwritten =
        ['PNG', 'JPG', 'JPEG'].contains(submission.fileFormat.toUpperCase());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submission Confirmed'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                color: AppColors.successLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 38,
                color: AppColors.success,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Assignment Submitted!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          const Text(
            'Your submission has been securely recorded and queued for instructor evaluation.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.secondaryText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Evaluation Timeline Notice
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
                    Icon(
                      Icons.schedule_rounded,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Instructor Evaluation Timeline',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '• Submission Deadline: ${formatShortDate(assignment.deadline)}\n'
                  '• Evaluation Release Date: ${formatShortDate(evalTimeline)}\n'
                  '• Evaluation Mode: ${isHandwritten ? 'Automated OCR Scan & AI Rubric Scoring' : 'Digital Rubric Scoring'}\n'
                  '• Instructor: ${assignment.teacherName}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.primaryText,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Results and detailed feedback will be available in the Results tab once your instructor conducts the evaluation run.',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontStyle: FontStyle.italic,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Official Submission Receipt
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _ReceiptRow(
                  label: 'Reference Number',
                  value: submission.referenceNumber,
                  highlight: true,
                ),
                const Divider(height: 20),
                _ReceiptRow(label: 'Assignment', value: assignment.title),
                const Divider(height: 20),
                _ReceiptRow(label: 'Subject', value: assignment.subject),
                const Divider(height: 20),
                _ReceiptRow(
                  label: 'Submitted File',
                  value:
                      '${submission.fileName} (${submission.formattedFileSize})',
                ),
                const Divider(height: 20),
                _ReceiptRow(
                  label: 'Submission Type',
                  value: isHandwritten ? 'Handwritten Work' : 'Digital Document',
                ),
                const Divider(height: 20),
                _ReceiptRow(
                  label: 'Timestamp',
                  value: formatDateTime(submission.submittedAt),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Navigation CTA Buttons
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Return to Coursework'),
          ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _ReceiptRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: highlight ? AppColors.primaryBlue : AppColors.primaryText,
            ),
          ),
        ),
      ],
    );
  }
}
