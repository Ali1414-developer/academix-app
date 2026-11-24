import 'evaluation_model.dart';
import 'feedback_model.dart';

enum SubmissionStatus { submitted, evaluated, flagged }

class SubmissionModel {
  final String id;
  final String assignmentId;
  final String studentId;
  final String studentName;
  final String studentRollNo;
  final String fileName;
  final String fileFormat;
  final int fileSizeKb;
  final DateTime submittedAt;
  final String referenceNumber;
  final String extractedText;
  final SubmissionStatus status;
  final EvaluationModel evaluation;
  final List<FeedbackModel> feedbackList;

  const SubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.studentName,
    required this.studentRollNo,
    required this.fileName,
    required this.fileFormat,
    required this.fileSizeKb,
    required this.submittedAt,
    required this.referenceNumber,
    required this.extractedText,
    required this.status,
    required this.evaluation,
    this.feedbackList = const [],
  });

  String get formattedFileSize {
    if (fileSizeKb >= 1024) {
      return '${(fileSizeKb / 1024).toStringAsFixed(2)} MB';
    }
    return '$fileSizeKb KB';
  }

  SubmissionModel copyWith({
    SubmissionStatus? status,
    EvaluationModel? evaluation,
    List<FeedbackModel>? feedbackList,
    String? fileName,
    String? fileFormat,
    int? fileSizeKb,
    String? extractedText,
  }) {
    return SubmissionModel(
      id: id,
      assignmentId: assignmentId,
      studentId: studentId,
      studentName: studentName,
      studentRollNo: studentRollNo,
      fileName: fileName ?? this.fileName,
      fileFormat: fileFormat ?? this.fileFormat,
      fileSizeKb: fileSizeKb ?? this.fileSizeKb,
      submittedAt: submittedAt,
      referenceNumber: referenceNumber,
      extractedText: extractedText ?? this.extractedText,
      status: status ?? this.status,
      evaluation: evaluation ?? this.evaluation,
      feedbackList: feedbackList ?? this.feedbackList,
    );
  }
}
