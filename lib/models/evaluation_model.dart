class PlagiarismMatch {
  final String matchedExcerpt;
  final String sourceTitle;
  final String sourceDomain;
  final double matchPercent;

  const PlagiarismMatch({
    required this.matchedExcerpt,
    required this.sourceTitle,
    required this.sourceDomain,
    required this.matchPercent,
  });
}

class GrammarIssue {
  final String type; // Spelling, Sentence Structure, Punctuation, Clarity
  final String originalText;
  final String suggestion;
  final String explanation;

  const GrammarIssue({
    required this.type,
    required this.originalText,
    required this.suggestion,
    required this.explanation,
  });
}

class RubricBreakdown {
  final String criterion;
  final double earned;
  final double maxScore;

  const RubricBreakdown({
    required this.criterion,
    required this.earned,
    required this.maxScore,
  });
}

class EvaluationModel {
  final double aiSuggestedMarks;
  final double finalMarks;
  final double contentQualityScore; // 0-100
  final double grammarScore; // 0-100
  final double organizationScore; // 0-100
  final double readabilityScore; // 0-100
  final double similarityPercentage; // 0-100
  final double confidenceScore; // 0-100
  final String readabilityLevel;
  final int wordCount;
  final List<PlagiarismMatch> plagiarismMatches;
  final List<GrammarIssue> grammarIssues;
  final List<String> structureFeedback;
  final List<String> aiSuggestions;
  final List<RubricBreakdown> rubric;
  final bool isTeacherApproved;
  final bool plagiarismReviewed;
  final bool isFlagged;
  final List<String> flagReasons;
  final String teacherFinalComment;
  final DateTime? approvedAt;

  const EvaluationModel({
    required this.aiSuggestedMarks,
    required this.finalMarks,
    required this.contentQualityScore,
    required this.grammarScore,
    required this.organizationScore,
    required this.readabilityScore,
    required this.similarityPercentage,
    required this.confidenceScore,
    required this.readabilityLevel,
    required this.wordCount,
    required this.plagiarismMatches,
    required this.grammarIssues,
    required this.structureFeedback,
    required this.aiSuggestions,
    required this.rubric,
    this.isTeacherApproved = false,
    this.plagiarismReviewed = false,
    this.isFlagged = false,
    this.flagReasons = const [],
    this.teacherFinalComment = '',
    this.approvedAt,
  });

  String get originalityStatus {
    if (similarityPercentage <= 15) return 'Original';
    if (similarityPercentage <= 30) return 'Moderate Similarity';
    return 'High Similarity Risk';
  }

  EvaluationModel copyWith({
    double? aiSuggestedMarks,
    double? finalMarks,
    double? contentQualityScore,
    double? grammarScore,
    double? organizationScore,
    double? readabilityScore,
    double? similarityPercentage,
    double? confidenceScore,
    String? readabilityLevel,
    int? wordCount,
    List<PlagiarismMatch>? plagiarismMatches,
    List<GrammarIssue>? grammarIssues,
    List<String>? structureFeedback,
    List<String>? aiSuggestions,
    List<RubricBreakdown>? rubric,
    bool? isTeacherApproved,
    bool? plagiarismReviewed,
    bool? isFlagged,
    List<String>? flagReasons,
    String? teacherFinalComment,
    DateTime? approvedAt,
  }) {
    return EvaluationModel(
      aiSuggestedMarks: aiSuggestedMarks ?? this.aiSuggestedMarks,
      finalMarks: finalMarks ?? this.finalMarks,
      contentQualityScore: contentQualityScore ?? this.contentQualityScore,
      grammarScore: grammarScore ?? this.grammarScore,
      organizationScore: organizationScore ?? this.organizationScore,
      readabilityScore: readabilityScore ?? this.readabilityScore,
      similarityPercentage: similarityPercentage ?? this.similarityPercentage,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      readabilityLevel: readabilityLevel ?? this.readabilityLevel,
      wordCount: wordCount ?? this.wordCount,
      plagiarismMatches: plagiarismMatches ?? this.plagiarismMatches,
      grammarIssues: grammarIssues ?? this.grammarIssues,
      structureFeedback: structureFeedback ?? this.structureFeedback,
      aiSuggestions: aiSuggestions ?? this.aiSuggestions,
      rubric: rubric ?? this.rubric,
      isTeacherApproved: isTeacherApproved ?? this.isTeacherApproved,
      plagiarismReviewed: plagiarismReviewed ?? this.plagiarismReviewed,
      isFlagged: isFlagged ?? this.isFlagged,
      flagReasons: flagReasons ?? this.flagReasons,
      teacherFinalComment: teacherFinalComment ?? this.teacherFinalComment,
      approvedAt: approvedAt ?? this.approvedAt,
    );
  }
}
