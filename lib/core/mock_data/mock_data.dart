// ignore_for_file: prefer_const_constructors
import '../../models/assignment_model.dart';
import '../../models/class_model.dart';
import '../../models/evaluation_model.dart';
import '../../models/feedback_model.dart';
import '../../models/notification_model.dart';
import '../../models/submission_model.dart';
import '../../models/user_model.dart';

class MockData {
  MockData._();

  static final DateTime _now = DateTime.now();

  static List<UserModel> initialUsers() => [
        const UserModel(
          id: 'stu-01',
          fullName: 'Ayesha Khan',
          email: 'ayesha.khan@academix.edu',
          password: 'password123',
          role: UserRole.student,
          academicId: 'BSSE-2023-041',
          department: 'Software Engineering',
          semesterOrDesignation: '6th Semester',
          phone: '+92 301 5521094',
        ),
        const UserModel(
          id: 'stu-02',
          fullName: 'Bilal Ahmed',
          email: 'bilal.ahmed@academix.edu',
          password: 'password123',
          role: UserRole.student,
          academicId: 'BSSE-2023-018',
          department: 'Software Engineering',
          semesterOrDesignation: '6th Semester',
          phone: '+92 302 4410982',
        ),
        const UserModel(
          id: 'stu-03',
          fullName: 'Fatima Noor',
          email: 'fatima.noor@academix.edu',
          password: 'password123',
          role: UserRole.student,
          academicId: 'BSSE-2023-055',
          department: 'Software Engineering',
          semesterOrDesignation: '6th Semester',
          phone: '+92 303 6678129',
        ),
        const UserModel(
          id: 'tch-01',
          fullName: 'Dr. Usman Tariq',
          email: 'dr.usman@academix.edu',
          password: 'password123',
          role: UserRole.teacher,
          academicId: 'FAC-SE-108',
          department: 'Software Engineering',
          semesterOrDesignation: 'Associate Professor',
          phone: '+92 321 8840219',
        ),
      ];

  static List<ClassModel> initialClasses() => [
        ClassModel(
          id: 'cls-01',
          name: 'Human-Computer Interaction - Sec A',
          subject: 'Human-Computer Interaction',
          courseCode: 'SE-312',
          section: 'Section A',
          semester: '6th Semester',
          academicYear: '2026-2027',
          description:
              'Advanced UI/UX engineering, user-centered prototyping, cognitive walkthroughs, and quantitative usability evaluation.',
          teacherId: 'tch-01',
          teacherName: 'Dr. Usman Tariq',
          classCode: 'HCI-7824',
          enrolledStudentIds: ['stu-01', 'stu-02', 'stu-03'],
          createdAt: _now.subtract(const Duration(days: 30)),
          status: ClassStatus.active,
        ),
        ClassModel(
          id: 'cls-02',
          name: 'Operating Systems - Sec B',
          subject: 'Operating Systems',
          courseCode: 'CS-304',
          section: 'Section B',
          semester: '6th Semester',
          academicYear: '2026-2027',
          description:
              'Concurrency primitives, multi-core CPU scheduling, virtual memory paging, and Linux kernel process management.',
          teacherId: 'tch-01',
          teacherName: 'Dr. Usman Tariq',
          classCode: 'OPS-4912',
          enrolledStudentIds: ['stu-01', 'stu-02'],
          createdAt: _now.subtract(const Duration(days: 28)),
          status: ClassStatus.active,
        ),
        ClassModel(
          id: 'cls-03',
          name: 'Software Engineering Architecture',
          subject: 'Software Engineering',
          courseCode: 'SE-301',
          section: 'Section A',
          semester: '6th Semester',
          academicYear: '2026-2027',
          description:
              'Architectural design patterns, clean code principles, microservices modeling, and IEEE-standard documentation.',
          teacherId: 'tch-01',
          teacherName: 'Dr. Usman Tariq',
          classCode: 'SWE-6301',
          enrolledStudentIds: ['stu-01', 'stu-03'],
          createdAt: _now.subtract(const Duration(days: 25)),
          status: ClassStatus.active,
        ),
        ClassModel(
          id: 'cls-04',
          name: 'Database Systems - Archived Fall 2025',
          subject: 'Database Systems',
          courseCode: 'CS-220',
          section: 'Section C',
          semester: '5th Semester',
          academicYear: '2025-2026',
          description:
              'Relational algebra, BCNF decomposition, transactional ACID guarantees, and distributed query execution.',
          teacherId: 'tch-01',
          teacherName: 'Dr. Usman Tariq',
          classCode: 'DBS-9901',
          enrolledStudentIds: ['stu-01'],
          createdAt: _now.subtract(const Duration(days: 120)),
          status: ClassStatus.archived,
        ),
      ];

  static List<AssignmentModel> initialAssignments() => [
        AssignmentModel(
          id: 'asg-01',
          classId: 'cls-01',
          className: 'Human-Computer Interaction - Sec A',
          title: 'Heuristic Usability Evaluation Report',
          subject: 'Human-Computer Interaction',
          courseCode: 'SE-312',
          description:
              'Conduct a structured usability inspection of an academic learning management mobile app using Nielsen\'s ten usability heuristics and document severity ratings with redesign proposals.',
          instructions: [
            'Evaluate at least 6 core screens using Nielsen\'s 10 heuristics.',
            'Assign severity scores (0–4) with concrete visual evidence.',
            'Propose actionable wireframe improvements for every major issue.',
            'Submit a clean typed PDF or DOCX document (maximum 10 MB).',
          ],
          totalMarks: 100,
          deadline: _now.subtract(const Duration(days: 3)),
          allowedFormats: ['PDF', 'DOCX'],
          teacherName: 'Dr. Usman Tariq',
          totalStudentsEnrolled: 3,
          createdAt: _now.subtract(const Duration(days: 14)),
          evaluationTimeline: _now.subtract(const Duration(days: 1)),
          rubricType: 'PDF',
          rubricFileName: 'HCI_Usability_Nielsen_Rubric.pdf',
          rubricContent: '40% Heuristic Coverage, 30% Severity Ratings & Evidence, 30% Redesign Recommendations.',
          isEvaluationCompleted: true,
        ),
        AssignmentModel(
          id: 'asg-02',
          classId: 'cls-02',
          className: 'Operating Systems - Sec B',
          title: 'CPU Scheduling & Deadlock Analysis',
          subject: 'Operating Systems',
          courseCode: 'CS-304',
          description:
              'Compare Round Robin, Shortest Remaining Time First, and Priority Scheduling across three workload traces and prove deadlock avoidance with Banker\'s Algorithm.',
          instructions: [
            'Include Gantt charts and average turnaround / waiting time tables.',
            'Show step-by-step safe sequence derivation for Banker\'s Algorithm.',
            'Handwritten calculations may be scanned clearly as PNG/JPG or PDF.',
          ],
          totalMarks: 50,
          deadline: _now.add(const Duration(days: 2)),
          allowedFormats: ['PDF', 'DOCX', 'PNG', 'JPG'],
          teacherName: 'Dr. Usman Tariq',
          totalStudentsEnrolled: 2,
          createdAt: _now.subtract(const Duration(days: 9)),
          evaluationTimeline: _now.add(const Duration(days: 4)),
          rubricType: 'Word',
          rubricFileName: 'OS_Scheduling_Bankers_Rubric.docx',
          rubricContent: '40% Scheduling Calculations, 30% Deadlock Safe Sequence, 30% Handwritten Clarity & OCR Parsing.',
          isEvaluationCompleted: false,
        ),
        AssignmentModel(
          id: 'asg-03',
          classId: 'cls-03',
          className: 'Software Engineering Architecture',
          title: 'SRS Architecture & Sequence Modeling',
          subject: 'Software Engineering',
          courseCode: 'SE-301',
          description:
              'Author an IEEE-830 aligned Software Requirements Specification covering functional decomposition, non-functional quality attributes, and UML sequence diagrams.',
          instructions: [
            'Document at least 12 traceable functional requirements.',
            'Provide high-resolution UML use case and sequence diagrams.',
            'Ensure consistent terminology and requirement IDs throughout.',
          ],
          totalMarks: 100,
          deadline: _now.add(const Duration(days: 5)),
          allowedFormats: ['PDF', 'DOCX'],
          teacherName: 'Dr. Usman Tariq',
          totalStudentsEnrolled: 2,
          createdAt: _now.subtract(const Duration(days: 6)),
          evaluationTimeline: _now.add(const Duration(days: 7)),
          rubricType: 'Image',
          rubricFileName: 'SRS_Sequence_Rubric_Scan.png',
          rubricContent: '40% IEEE-830 Compliance, 30% UML Sequence Diagrams, 30% Requirement Traceability.',
          isEvaluationCompleted: false,
        ),
        AssignmentModel(
          id: 'asg-04',
          classId: 'cls-04',
          className: 'Database Systems - Archived Fall 2025',
          title: 'Relational Normalization & Indexing Case Study',
          subject: 'Database Systems',
          courseCode: 'CS-220',
          description:
              'Transform a legacy university registration schema from unnormalized form to BCNF and benchmark B+ tree vs. hash indexing trade-offs on range queries.',
          instructions: [
            'Clearly state functional dependencies at each normalization step.',
            'Explain lossless join and dependency preservation.',
            'Submit ER diagram alongside SQL DDL verification notes.',
          ],
          totalMarks: 100,
          deadline: _now.subtract(const Duration(days: 7)),
          allowedFormats: ['PDF', 'DOCX', 'PNG'],
          teacherName: 'Dr. Usman Tariq',
          totalStudentsEnrolled: 1,
          createdAt: _now.subtract(const Duration(days: 20)),
          evaluationTimeline: _now.subtract(const Duration(days: 5)),
          rubricType: 'Text',
          rubricFileName: 'Text Rubric Criteria',
          rubricContent: '40% Normalization to BCNF, 30% Indexing Benchmark analysis, 30% ER Diagram notation and lossless join proof.',
          isEvaluationCompleted: true,
        ),
        AssignmentModel(
          id: 'asg-05',
          title: 'Informed Search & A* Heuristic Admissibility',
          subject: 'Artificial Intelligence',
          courseCode: 'CS-341',
          description:
              'Analyze Manhattan vs. Euclidean distance heuristics on grid pathfinding graphs and formally prove admissibility and consistency conditions.',
          instructions: [
            'Show trace tables for open and closed priority queues.',
            'Compare node expansion counts across 3 obstacle densities.',
            'Discuss memory limitations of A* vs. IDA*.',
          ],
          totalMarks: 50,
          deadline: _now.add(const Duration(days: 9)),
          allowedFormats: ['PDF', 'PNG', 'JPG'],
          teacherName: 'Dr. Usman Tariq',
          totalStudentsEnrolled: 32,
          createdAt: _now.subtract(const Duration(days: 2)),
          evaluationTimeline: _now.add(const Duration(days: 11)),
          rubricType: 'PDF',
          rubricFileName: 'AI_Search_Admissibility_Rubric.pdf',
          rubricContent: '40% Formal Admissibility Proof, 30% Grid Pathfinding Traces, 30% Comparative Complexity Table.',
          isEvaluationCompleted: false,
        ),
      ];

  static List<SubmissionModel> initialSubmissions() => [
        SubmissionModel(
          id: 'sub-01',
          assignmentId: 'asg-01',
          studentId: 'stu-01',
          studentName: 'Ayesha Khan',
          studentRollNo: 'BSSE-2023-041',
          fileName: 'Ayesha_HCI_Heuristic_Report.pdf',
          fileFormat: 'PDF',
          fileSizeKb: 1840,
          submittedAt: _now.subtract(const Duration(days: 4, hours: 3)),
          referenceNumber: 'ACX-2026-4108',
          status: SubmissionStatus.evaluated,
          extractedText:
              'This heuristic usability evaluation examines the mobile student portal across six primary workflows: login, dashboard overview, assignment upload, rubric inspection, calendar tracking, and notification triage. '
              'Applying Nielsen\'s visibility of system status heuristic revealed that file upload validation lacked explicit progress feedback when processing multi-page scans. '
              'Furthermore, error prevention can be significantly improved by verifying allowed file extensions before upload initiation and displaying inline guidance. '
              'Across all evaluated views, consistent Material Design 3 typography and 48dp minimum touch targets reduced navigation errors in formative testing.',
          evaluation: EvaluationModel(
            aiSuggestedMarks: 86,
            finalMarks: 89,
            contentQualityScore: 91,
            grammarScore: 88,
            organizationScore: 90,
            readabilityScore: 87,
            similarityPercentage: 11,
            confidenceScore: 94,
            readabilityLevel: 'Undergraduate Academic (Grade 14)',
            wordCount: 1480,
            isTeacherApproved: true,
            plagiarismReviewed: true,
            isFlagged: false,
            teacherFinalComment:
                'Strong analytical depth and well-justified severity ratings. Your redesign recommendations directly address touch-zone ergonomics.',
            approvedAt: _now.subtract(const Duration(days: 2)),
            plagiarismMatches: const [
              PlagiarismMatch(
                matchedExcerpt:
                    'visibility of system status heuristic revealed that file upload validation lacked explicit progress feedback',
                sourceTitle: 'Nielsen Norman Group – 10 Usability Heuristics',
                sourceDomain: 'nngroup.com',
                matchPercent: 6.5,
              ),
              PlagiarismMatch(
                matchedExcerpt:
                    'consistent Material Design 3 typography and 48dp minimum touch targets',
                sourceTitle: 'Material Design 3 Accessibility Guidelines',
                sourceDomain: 'm3.material.io',
                matchPercent: 4.5,
              ),
            ],
            grammarIssues: const [
              GrammarIssue(
                type: 'Sentence Structure',
                originalText:
                    'error prevention can be significantly improved by verifying allowed file extensions before upload initiation',
                suggestion:
                    'Verifying allowed file extensions prior to upload significantly improves error prevention.',
                explanation:
                    'Using active voice sharpens technical clarity in usability recommendations.',
              ),
              GrammarIssue(
                type: 'Spelling',
                originalText: 'heurisitc severity matrix',
                suggestion: 'heuristic severity matrix',
                explanation: 'Transposed characters in "heuristic" on page 3.',
              ),
              GrammarIssue(
                type: 'Clarity',
                originalText: 'users might possibly get confused by the label',
                suggestion: 'the ambiguous label may confuse first-time users',
                explanation:
                    'Eliminate redundant hedging words ("might possibly") for concise academic tone.',
              ),
            ],
            structureFeedback: const [
              'Clear executive summary with well-scoped evaluation boundaries.',
              'Logical progression from heuristic audit findings to severity-ranked redesigns.',
              'Consider adding a concise comparison table summarizing before/after task completion steps.',
            ],
            aiSuggestions: const [
              'Add quantitative benchmark metrics (e.g., expected tap reduction) next to each redesign wireframe.',
              'Cross-reference WCAG 2.1 AA contrast ratios in the typography and color audit section.',
              'Tighten passive voice phrasing in Section 3 to strengthen technical persuasiveness.',
            ],
            rubric: const [
              RubricBreakdown(
                  criterion: 'Heuristic Coverage', earned: 28, maxScore: 30),
              RubricBreakdown(
                  criterion: 'Severity Justification', earned: 22, maxScore: 25),
              RubricBreakdown(
                  criterion: 'Redesign Quality', earned: 23, maxScore: 25),
              RubricBreakdown(
                  criterion: 'Writing & Citations', earned: 16, maxScore: 20),
            ],
          ),
          feedbackList: [
            FeedbackModel(
              id: 'fb-01',
              submissionId: 'sub-01',
              teacherName: 'Dr. Usman Tariq',
              message:
                  'Excellent heuristic breakdown, Ayesha. Your severity justifications are grounded in concrete mobile interaction workflows. For your capstone, pair each redesign with a short usability test script.',
              status: FeedbackStatus.published,
              createdAt: _now.subtract(const Duration(days: 2)),
              updatedAt: _now.subtract(const Duration(days: 2)),
            ),
          ],
        ),
        SubmissionModel(
          id: 'sub-02',
          assignmentId: 'asg-04',
          studentId: 'stu-01',
          studentName: 'Ayesha Khan',
          studentRollNo: 'BSSE-2023-041',
          fileName: 'Normalization_BCNF_CaseStudy.docx',
          fileFormat: 'DOCX',
          fileSizeKb: 960,
          submittedAt: _now.subtract(const Duration(days: 8)),
          referenceNumber: 'ACX-2026-3912',
          status: SubmissionStatus.evaluated,
          extractedText:
              'The legacy registration relation exhibits partial dependencies on composite key (StudentID, CourseID) and transitive dependencies from InstructorID to DepartmentOffice. '
              'Decomposing into 2NF removes repeating course attributes, while 3NF isolates department metadata into a dedicated table. '
              'Finally, verifying Boyce-Codd Normal Form ensures every non-trivial functional dependency has a superkey determinant. '
              'For range queries over enrollment dates, B+ tree indexing outperforms hash indexing due to sequential leaf-node pointer traversal.',
          evaluation: EvaluationModel(
            aiSuggestedMarks: 82,
            finalMarks: 84,
            contentQualityScore: 86,
            grammarScore: 84,
            organizationScore: 85,
            readabilityScore: 83,
            similarityPercentage: 14,
            confidenceScore: 91,
            readabilityLevel: 'Undergraduate Technical (Grade 13)',
            wordCount: 1210,
            isTeacherApproved: true,
            plagiarismReviewed: true,
            isFlagged: false,
            teacherFinalComment:
                'Accurate BCNF decomposition and clear indexing comparison. Expand on write amplification overhead in B+ trees next time.',
            approvedAt: _now.subtract(const Duration(days: 5)),
            plagiarismMatches: const [
              PlagiarismMatch(
                matchedExcerpt:
                    'ensures every non-trivial functional dependency has a superkey determinant',
                sourceTitle: 'Database System Concepts – 7th Edition Summary',
                sourceDomain: 'db-book.com',
                matchPercent: 8.2,
              ),
              PlagiarismMatch(
                matchedExcerpt:
                    'B+ tree indexing outperforms hash indexing due to sequential leaf-node pointer traversal',
                sourceTitle: 'CS-220 Lecture Notes on Storage & Indexing',
                sourceDomain: 'academix.edu/notes',
                matchPercent: 5.8,
              ),
            ],
            grammarIssues: const [
              GrammarIssue(
                type: 'Punctuation',
                originalText:
                    'Decomposing into 2NF removes repeating course attributes however transitive dependencies remain',
                suggestion:
                    'Decomposing into 2NF removes repeating course attributes; however, transitive dependencies remain.',
                explanation:
                    'Use a semicolon before the conjunctive adverb "however".',
              ),
              GrammarIssue(
                type: 'Spelling',
                originalText: 'dependancy preservation proof',
                suggestion: 'dependency preservation proof',
                explanation: 'Standard spelling is "dependency".',
              ),
            ],
            structureFeedback: const [
              'Strong step-by-step schema progression from 1NF through BCNF.',
              'Indexing benchmark section would benefit from a small latency comparison chart.',
            ],
            aiSuggestions: const [
              'Include SQL EXPLAIN query plan snippets to substantiate the B+ tree range scan discussion.',
              'Verify dependency preservation explicitly after the final BCNF split.',
            ],
            rubric: const [
              RubricBreakdown(
                  criterion: 'Functional Dependencies', earned: 22, maxScore: 25),
              RubricBreakdown(
                  criterion: 'BCNF Decomposition', earned: 26, maxScore: 30),
              RubricBreakdown(
                  criterion: 'Indexing Analysis', earned: 20, maxScore: 25),
              RubricBreakdown(
                  criterion: 'Clarity & Formatting', earned: 16, maxScore: 20),
            ],
          ),
          feedbackList: [
            FeedbackModel(
              id: 'fb-02',
              submissionId: 'sub-02',
              teacherName: 'Dr. Usman Tariq',
              message:
                  'Well-structured normalization walkthrough. Your explanation of leaf-node pointers in B+ trees is concise and accurate.',
              status: FeedbackStatus.published,
              createdAt: _now.subtract(const Duration(days: 5)),
              updatedAt: _now.subtract(const Duration(days: 5)),
            ),
          ],
        ),
        SubmissionModel(
          id: 'sub-03',
          assignmentId: 'asg-02',
          studentId: 'stu-02',
          studentName: 'Bilal Ahmed',
          studentRollNo: 'BSSE-2023-018',
          fileName: 'Bilal_OS_Scheduling_Lab.pdf',
          fileFormat: 'PDF',
          fileSizeKb: 2420,
          submittedAt: _now.subtract(const Duration(hours: 7)),
          referenceNumber: 'ACX-2026-4291',
          status: SubmissionStatus.flagged,
          extractedText:
              'Round Robin scheduling assigns a fixed time quantum to every process in the ready queue to maintain fairness in time-sharing operating systems. '
              'Banker\'s Algorithm checks whether allocating requested resources leaves the operating system in a safe state by simulating Need <= Work across available process vectors. '
              'In workload trace B, a quantum of 4ms achieved lower response time than First-Come First-Served while slightly increasing context-switch overhead.',
          evaluation: EvaluationModel(
            aiSuggestedMarks: 34,
            finalMarks: 34,
            contentQualityScore: 71,
            grammarScore: 79,
            organizationScore: 72,
            readabilityScore: 76,
            similarityPercentage: 44,
            confidenceScore: 78,
            readabilityLevel: 'Undergraduate Technical (Grade 12)',
            wordCount: 840,
            isTeacherApproved: false,
            plagiarismReviewed: false,
            isFlagged: true,
            flagReasons: const [
              'High Similarity Alert (44% matched content)',
            ],
            plagiarismMatches: const [
              PlagiarismMatch(
                matchedExcerpt:
                    'Round Robin scheduling assigns a fixed time quantum to every process in the ready queue to maintain fairness in time-sharing operating systems.',
                sourceTitle: 'Operating System Concepts – Process Scheduling',
                sourceDomain: 'os-book.org',
                matchPercent: 26.0,
              ),
              PlagiarismMatch(
                matchedExcerpt:
                    'checks whether allocating requested resources leaves the operating system in a safe state by simulating Need <= Work',
                sourceTitle: 'GeeksforGeeks – Banker\'s Algorithm Guide',
                sourceDomain: 'geeksforgeeks.org',
                matchPercent: 18.0,
              ),
            ],
            grammarIssues: const [
              GrammarIssue(
                type: 'Sentence Structure',
                originalText:
                    'context switch overhead increases because quantum is small and CPU spends more time switching',
                suggestion:
                    'A smaller time quantum increases context-switch overhead because the CPU switches processes more frequently.',
                explanation:
                    'Tighten causal phrasing for concise academic writing.',
              ),
            ],
            structureFeedback: const [
              'Gantt chart calculations are present, though workload trace C is abbreviated.',
              'Several conceptual definitions mirror external textbook paragraphs without citation.',
            ],
            aiSuggestions: const [
              'Paraphrase textbook definitions in your own words and cite references explicitly.',
              'Complete the third workload trace table to satisfy full rubric criteria.',
            ],
            rubric: const [
              RubricBreakdown(
                  criterion: 'Scheduling Calculations', earned: 14, maxScore: 20),
              RubricBreakdown(
                  criterion: 'Banker\'s Algorithm Proof', earned: 11, maxScore: 15),
              RubricBreakdown(
                  criterion: 'Originality & Analysis', earned: 9, maxScore: 15),
            ],
          ),
        ),
        SubmissionModel(
          id: 'sub-04',
          assignmentId: 'asg-02',
          studentId: 'stu-03',
          studentName: 'Hina Siddiqui',
          studentRollNo: 'BSSE-2023-052',
          fileName: 'Hina_OS_Handwritten_Scan.png',
          fileFormat: 'PNG',
          fileSizeKb: 3180,
          submittedAt: _now.subtract(const Duration(hours: 11)),
          referenceNumber: 'ACX-2026-4284',
          status: SubmissionStatus.flagged,
          extractedText:
              '[Simulated OCR Extract — Low Contrast Region on Page 2] '
              'Process P1 arrives at t=0 with burst 8ms, P2 arrives at t=1 with burst 4ms. '
              'SRTF preempts P1 at t=1... [partially illegible matrix values in Banker\'s safety table]. '
              'Safe sequence concluded as P2 -> P4 -> P1 -> P3.',
          evaluation: EvaluationModel(
            aiSuggestedMarks: 37,
            finalMarks: 37,
            contentQualityScore: 76,
            grammarScore: 81,
            organizationScore: 70,
            readabilityScore: 68,
            similarityPercentage: 8,
            confidenceScore: 61,
            readabilityLevel: 'Mixed Handwritten OCR Extract',
            wordCount: 620,
            isTeacherApproved: false,
            plagiarismReviewed: true,
            isFlagged: true,
            flagReasons: const [
              'Low-Confidence Evaluation (61% OCR confidence)',
              'Incomplete/Partially Illegible Matrix Section',
            ],
            plagiarismMatches: const [
              PlagiarismMatch(
                matchedExcerpt: 'SRTF preempts P1 at t=1',
                sourceTitle: 'Course Lab Sheet Reference',
                sourceDomain: 'academix.edu/labs',
                matchPercent: 8.0,
              ),
            ],
            grammarIssues: const [
              GrammarIssue(
                type: 'Clarity',
                originalText: 'Safe sequence concluded as P2 -> P4 -> P1 -> P3',
                suggestion:
                    'Therefore, the derived safe execution sequence is <P2, P4, P1, P3>.',
                explanation:
                    'Use standard angle-bracket sequence notation and explain remaining Need checks.',
              ),
            ],
            structureFeedback: const [
              'Handwritten OCR capture had reduced contrast on the allocation matrix.',
              'Teacher manual verification recommended before finalizing marks.',
            ],
            aiSuggestions: const [
              'Upload a higher-contrast scan or typed summary table for the Banker\'s matrix.',
            ],
            rubric: const [
              RubricBreakdown(
                  criterion: 'Scheduling Calculations', earned: 16, maxScore: 20),
              RubricBreakdown(
                  criterion: 'Banker\'s Algorithm Proof', earned: 10, maxScore: 15),
              RubricBreakdown(
                  criterion: 'Originality & Analysis', earned: 11, maxScore: 15),
            ],
          ),
        ),
        SubmissionModel(
          id: 'sub-05',
          assignmentId: 'asg-03',
          studentId: 'stu-04',
          studentName: 'Hamza Raza',
          studentRollNo: 'BSSE-2023-029',
          fileName: 'Hamza_SRS_Architecture.pdf',
          fileFormat: 'PDF',
          fileSizeKb: 2150,
          submittedAt: _now.subtract(const Duration(hours: 4)),
          referenceNumber: 'ACX-2026-4302',
          status: SubmissionStatus.submitted,
          extractedText:
              'Section 1 defines the system scope for a distributed campus examination scheduler with role-based access for students and faculty. '
              'Functional requirements FR-01 through FR-14 specify authentication, conflict detection, room allocation, and schedule export. '
              'Non-functional requirements establish 99.5% availability during exam windows, sub-300ms query latency, and WCAG AA accessibility compliance.',
          evaluation: EvaluationModel(
            aiSuggestedMarks: 85,
            finalMarks: 85,
            contentQualityScore: 88,
            grammarScore: 86,
            organizationScore: 89,
            readabilityScore: 85,
            similarityPercentage: 12,
            confidenceScore: 92,
            readabilityLevel: 'Undergraduate Technical (Grade 14)',
            wordCount: 1690,
            isTeacherApproved: false,
            plagiarismReviewed: false,
            isFlagged: false,
            plagiarismMatches: const [
              PlagiarismMatch(
                matchedExcerpt:
                    'Non-functional requirements establish 99.5% availability during exam windows',
                sourceTitle: 'IEEE 830 SRS Template Reference',
                sourceDomain: 'ieee.org',
                matchPercent: 12.0,
              ),
            ],
            grammarIssues: const [
              GrammarIssue(
                type: 'Sentence Structure',
                originalText:
                    'The system shall be able to allow users to export schedules',
                suggestion:
                    'The system shall allow authenticated users to export schedules.',
                explanation:
                    'Avoid verbose phrasing ("be able to allow") in formal SRS specifications.',
              ),
            ],
            structureFeedback: const [
              'Strong IEEE-830 section numbering and requirement traceability.',
              'Sequence diagrams clearly capture error recovery branches.',
            ],
            aiSuggestions: const [
              'Specify exact encryption standards (e.g., TLS 1.3, bcrypt) under security NFRs.',
            ],
            rubric: const [
              RubricBreakdown(
                  criterion: 'Functional Traceability', earned: 27, maxScore: 30),
              RubricBreakdown(
                  criterion: 'UML Sequence Diagrams', earned: 25, maxScore: 30),
              RubricBreakdown(
                  criterion: 'Non-Functional Spec', earned: 17, maxScore: 20),
              RubricBreakdown(
                  criterion: 'IEEE-830 Formatting', earned: 16, maxScore: 20),
            ],
          ),
        ),
        SubmissionModel(
          id: 'sub-06',
          assignmentId: 'asg-01',
          studentId: 'stu-05',
          studentName: 'Zainab Malik',
          studentRollNo: 'BSSE-2023-064',
          fileName: 'Zainab_HCI_Audit_Final.pdf',
          fileFormat: 'PDF',
          fileSizeKb: 1620,
          submittedAt: _now.subtract(const Duration(days: 3, hours: 6)),
          referenceNumber: 'ACX-2026-4119',
          status: SubmissionStatus.evaluated,
          extractedText:
              'This usability study evaluates navigation hierarchy, form feedback, and accessibility contrast across the mobile coursework assistant. '
              'Key findings highlight strong recognition-over-recall patterns in bottom navigation and recommend simplifying multi-step file upload confirmations.',
          evaluation: EvaluationModel(
            aiSuggestedMarks: 90,
            finalMarks: 92,
            contentQualityScore: 94,
            grammarScore: 91,
            organizationScore: 93,
            readabilityScore: 90,
            similarityPercentage: 7,
            confidenceScore: 96,
            readabilityLevel: 'Advanced Academic (Grade 15)',
            wordCount: 1610,
            isTeacherApproved: true,
            plagiarismReviewed: true,
            isFlagged: false,
            teacherFinalComment:
                'Outstanding clarity, original wireframes, and rigorous heuristic mapping.',
            approvedAt: _now.subtract(const Duration(days: 1)),
            plagiarismMatches: const [
              PlagiarismMatch(
                matchedExcerpt: 'recognition-over-recall patterns',
                sourceTitle: 'HCI Design Principles Compendium',
                sourceDomain: 'interaction-design.org',
                matchPercent: 7.0,
              ),
            ],
            grammarIssues: const [],
            structureFeedback: const [
              'Exemplary organization with concise visual callouts and severity matrix.',
            ],
            aiSuggestions: const [
              'Consider archiving your severity matrix template as a reusable team rubric.',
            ],
            rubric: const [
              RubricBreakdown(
                  criterion: 'Heuristic Coverage', earned: 29, maxScore: 30),
              RubricBreakdown(
                  criterion: 'Severity Justification', earned: 23, maxScore: 25),
              RubricBreakdown(
                  criterion: 'Redesign Quality', earned: 23, maxScore: 25),
              RubricBreakdown(
                  criterion: 'Writing & Citations', earned: 17, maxScore: 20),
            ],
          ),
          feedbackList: [
            FeedbackModel(
              id: 'fb-03',
              submissionId: 'sub-06',
              teacherName: 'Dr. Usman Tariq',
              message:
                  'Top-tier submission, Zainab. Clear rationale and clean visual evidence.',
              status: FeedbackStatus.published,
              createdAt: _now.subtract(const Duration(days: 1)),
              updatedAt: _now.subtract(const Duration(days: 1)),
            ),
          ],
        ),
      ];

  static List<NotificationModel> initialNotifications() => [
        NotificationModel(
          id: 'not-01',
          targetRole: UserRole.student,
          title: 'Evaluation Published: HCI Report',
          message:
              'Dr. Usman Tariq approved your final grade (89/100) for Heuristic Usability Evaluation Report.',
          category: NotificationCategory.evaluation,
          createdAt: _now.subtract(const Duration(hours: 3)),
          isRead: false,
          relatedAssignmentId: 'asg-01',
          relatedSubmissionId: 'sub-01',
        ),
        NotificationModel(
          id: 'not-02',
          targetRole: UserRole.student,
          title: 'Deadline Reminder: Operating Systems',
          message:
              'CPU Scheduling & Deadlock Analysis is due in 2 days. Allowed formats: PDF, DOCX, PNG, JPG.',
          category: NotificationCategory.deadline,
          createdAt: _now.subtract(const Duration(hours: 6)),
          isRead: false,
          relatedAssignmentId: 'asg-02',
        ),
        NotificationModel(
          id: 'not-03',
          targetRole: UserRole.student,
          title: 'New Teacher Feedback Available',
          message:
              'Dr. Usman Tariq left approved feedback on your Heuristic Usability Evaluation Report.',
          category: NotificationCategory.feedback,
          createdAt: _now.subtract(const Duration(days: 1)),
          isRead: true,
          relatedAssignmentId: 'asg-01',
          relatedSubmissionId: 'sub-01',
        ),
        NotificationModel(
          id: 'not-04',
          targetRole: UserRole.student,
          title: 'New Assignment Announced',
          message:
              'Informed Search & A* Heuristic Admissibility has been posted in Artificial Intelligence (CS-341).',
          category: NotificationCategory.announcement,
          createdAt: _now.subtract(const Duration(days: 2)),
          isRead: true,
          relatedAssignmentId: 'asg-05',
        ),
        NotificationModel(
          id: 'not-05',
          targetRole: UserRole.teacher,
          title: 'Flagged Submission Requires Review',
          message:
              'Bilal Ahmed\'s CPU Scheduling submission triggered a 44% similarity alert.',
          category: NotificationCategory.submission,
          createdAt: _now.subtract(const Duration(hours: 2)),
          isRead: false,
          relatedAssignmentId: 'asg-02',
          relatedSubmissionId: 'sub-03',
        ),
        NotificationModel(
          id: 'not-06',
          targetRole: UserRole.teacher,
          title: 'New Student Submission Received',
          message:
              'Hamza Raza submitted SRS Architecture & Sequence Modeling (Ref: ACX-2026-4302).',
          category: NotificationCategory.submission,
          createdAt: _now.subtract(const Duration(hours: 4)),
          isRead: false,
          relatedAssignmentId: 'asg-03',
          relatedSubmissionId: 'sub-05',
        ),
        NotificationModel(
          id: 'not-07',
          targetRole: UserRole.teacher,
          title: 'Low-Confidence OCR Review Needed',
          message:
              'Hina Siddiqui\'s scanned PNG submission has 61% simulated OCR confidence and needs manual verification.',
          category: NotificationCategory.evaluation,
          createdAt: _now.subtract(const Duration(hours: 11)),
          isRead: false,
          relatedAssignmentId: 'asg-02',
          relatedSubmissionId: 'sub-04',
        ),
        NotificationModel(
          id: 'not-08',
          targetRole: UserRole.teacher,
          title: 'Upcoming Assignment Deadline',
          message:
              'CPU Scheduling & Deadlock Analysis closes in 2 days. 2 submissions currently pending review.',
          category: NotificationCategory.deadline,
          createdAt: _now.subtract(const Duration(days: 1)),
          isRead: true,
          relatedAssignmentId: 'asg-02',
        ),
      ];
}
