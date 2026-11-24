import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/state/academix_provider.dart';
import '../../../core/widgets/charts.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../models/assignment_model.dart';
import '../../../models/class_model.dart';
import '../../../models/submission_model.dart';
import '../evaluation/teacher_evaluation_screens.dart';

// Teacher Screen 3: Manage Assignments
class TeacherManageAssignmentsScreen extends StatefulWidget {
  const TeacherManageAssignmentsScreen({super.key});

  @override
  State<TeacherManageAssignmentsScreen> createState() =>
      _TeacherManageAssignmentsScreenState();
}

class _TeacherManageAssignmentsScreenState
    extends State<TeacherManageAssignmentsScreen> {
  final _searchCtrl = TextEditingController();
  String _subjectFilter = 'All';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademiXProvider>();
    final subjects = [
      'All',
      ...{for (final a in provider.assignments) a.subject}
    ];
    final q = _searchCtrl.text.trim().toLowerCase();

    final filtered = provider.assignments.where((a) {
      final matchesSubject =
          _subjectFilter == 'All' || a.subject == _subjectFilter;
      final matchesQuery = q.isEmpty ||
          a.title.toLowerCase().contains(q) ||
          a.subject.toLowerCase().contains(q) ||
          a.courseCode.toLowerCase().contains(q);
      return matchesSubject && matchesQuery;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Coursework'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CreateAssignmentScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Create'),
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
                    hintText: 'Search coursework, courses, or rubrics...',
                    prefixIcon: Icon(Icons.search_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: subjects.map((subj) {
                      final active = _subjectFilter == subj;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(subj),
                          selected: active,
                          onSelected: (_) =>
                              setState(() => _subjectFilter = subj),
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
                ? EmptyStateView(
                    icon: Icons.assignment_outlined,
                    title: 'No coursework found',
                    description:
                        'Create a new coursework announcement with rubric & timeline.',
                    actionLabel: 'Create Coursework',
                    onAction: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CreateAssignmentScreen(),
                        ),
                      );
                    },
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final asg = filtered[index];
                      final subs =
                          provider.getSubmissionsForAssignment(asg.id);
                      final pct = asg.totalStudentsEnrolled == 0
                          ? 0.0
                          : (subs.length / asg.totalStudentsEnrolled) * 100;

                      final evalDate = asg.evaluationTimeline ??
                          asg.deadline.add(const Duration(days: 2));

                      return Material(
                        color: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TeacherAssignmentDetailScreen(
                                  assignmentId: asg.id,
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
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppColors.lightBlue,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '${asg.courseCode} · ${asg.subject}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.primaryBlue,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          if (asg.rubricType != null)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF1F5F9),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'Rubric: ${asg.rubricType}',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.secondaryText,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert_rounded,
                                          size: 18),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onSelected: (action) async {
                                        if (action == 'edit') {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  CreateAssignmentScreen(
                                                existing: asg,
                                              ),
                                            ),
                                          );
                                        } else if (action == 'delete') {
                                          final ok =
                                              await showAcademiXConfirmDialog(
                                            context: context,
                                            title: 'Delete Coursework',
                                            message:
                                                'Delete "${asg.title}" and associated student submissions?',
                                            confirmLabel: 'Delete',
                                            isDestructive: true,
                                          );
                                          if (ok && context.mounted) {
                                            provider.deleteAssignment(asg.id);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Coursework deleted.'),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      itemBuilder: (_) => const [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Edit Coursework'),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Text(
                                            'Delete Coursework',
                                            style: TextStyle(
                                                color: AppColors.error),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  asg.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryText,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Due ${formatShortDate(asg.deadline)} · Eval: ${formatShortDate(evalDate)} · ${asg.totalMarks} marks',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                MetricBarRow(
                                  label: 'Submission Rate',
                                  value: pct,
                                  displayValue:
                                      '${subs.length}/${asg.totalStudentsEnrolled}',
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CreateAssignmentScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Coursework'),
      ),
    );
  }
}

// Teacher Screen: Create / Announce Assignment (With Rubric Attachment & Evaluation Timeline)
class CreateAssignmentScreen extends StatefulWidget {
  final AssignmentModel? existing;
  final ClassModel? defaultClass;

  const CreateAssignmentScreen({super.key, this.existing, this.defaultClass});

  @override
  State<CreateAssignmentScreen> createState() => _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _subjectCtrl;
  late final TextEditingController _courseCodeCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _instructionsCtrl;
  late final TextEditingController _marksCtrl;
  late final TextEditingController _rubricContentCtrl;

  late DateTime _deadline;
  late DateTime _evaluationTimeline;
  late Set<String> _formats;

  String? _selectedClassId;
  String? _selectedClassName;

  String _rubricType = 'PDF'; // 'PDF', 'Word', 'Image', 'Text'
  String? _rubricFileName;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _selectedClassId = e?.classId ?? widget.defaultClass?.id;
    _selectedClassName = e?.className ?? widget.defaultClass?.name;

    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _subjectCtrl = TextEditingController(text: e?.subject ?? widget.defaultClass?.subject ?? '');
    _courseCodeCtrl = TextEditingController(text: e?.courseCode ?? widget.defaultClass?.courseCode ?? 'SE-315');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _instructionsCtrl = TextEditingController(
      text: e != null ? e.instructions.join('\n') : '',
    );
    _marksCtrl = TextEditingController(text: '${e?.totalMarks ?? 100}');

    _deadline = e?.deadline ?? DateTime.now().add(const Duration(days: 7));
    _evaluationTimeline = e?.evaluationTimeline ??
        _deadline.add(const Duration(days: 2));

    _formats = Set<String>.from(e?.allowedFormats ?? ['PDF', 'DOCX', 'PNG']);

    _rubricType = e?.rubricType ?? 'PDF';
    _rubricFileName = e?.rubricFileName ?? 'Coursework_Grading_Rubric.pdf';
    _rubricContentCtrl = TextEditingController(
      text: e?.rubricContent ??
          '40% Core Technical Implementation\n30% Methodology & Design Verification\n30% Documentation & Referencing',
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subjectCtrl.dispose();
    _courseCodeCtrl.dispose();
    _descCtrl.dispose();
    _instructionsCtrl.dispose();
    _marksCtrl.dispose();
    _rubricContentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _deadline = DateTime(picked.year, picked.month, picked.day, 23, 59);
        // Keep evaluation timeline after or on deadline
        if (_evaluationTimeline.isBefore(_deadline)) {
          _evaluationTimeline = _deadline.add(const Duration(days: 2));
        }
      });
    }
  }

  Future<void> _pickEvaluationTimeline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _evaluationTimeline.isBefore(_deadline)
          ? _deadline.add(const Duration(days: 1))
          : _evaluationTimeline,
      firstDate: _deadline,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _evaluationTimeline =
            DateTime(picked.year, picked.month, picked.day, 23, 59);
      });
    }
  }

  Future<void> _pickRubricFile() async {
    List<String> allowedExts = ['pdf', 'docx', 'doc', 'png', 'jpg', 'jpeg'];
    if (_rubricType == 'PDF') allowedExts = ['pdf'];
    if (_rubricType == 'Word') allowedExts = ['docx', 'doc'];
    if (_rubricType == 'Image') allowedExts = ['png', 'jpg', 'jpeg'];

    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExts,
      );
      if (res != null && res.files.isNotEmpty) {
        setState(() {
          _rubricFileName = res.files.first.name;
        });
      }
    } catch (_) {
      // Fallback sample
      _useSampleRubric(_rubricType);
    }
  }

  void _useSampleRubric(String type) {
    setState(() {
      _rubricType = type;
      if (type == 'PDF') {
        _rubricFileName = 'Faculty_Rubric_Specifications.pdf';
      } else if (type == 'Word') {
        _rubricFileName = 'Grading_Criteria_Standards.docx';
      } else if (type == 'Image') {
        _rubricFileName = 'Handwritten_Rubric_Matrix_Scan.jpg';
      } else {
        _rubricFileName = 'Custom Text Rubric';
      }
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_formats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Select at least one allowed student file format.')),
      );
      return;
    }

    final instructionsList = _instructionsCtrl.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final marks = int.tryParse(_marksCtrl.text.trim()) ?? 100;
    final provider = context.read<AcademiXProvider>();

    if (widget.existing != null) {
      provider.updateAssignment(
        widget.existing!.copyWith(
          classId: _selectedClassId,
          className: _selectedClassName,
          title: _titleCtrl.text.trim(),
          subject: _subjectCtrl.text.trim(),
          courseCode: _courseCodeCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          instructions: instructionsList,
          totalMarks: marks,
          deadline: _deadline,
          allowedFormats: _formats.toList(),
          evaluationTimeline: _evaluationTimeline,
          rubricType: _rubricType,
          rubricFileName: _rubricFileName ?? 'Coursework_Rubric.pdf',
          rubricContent: _rubricContentCtrl.text.trim(),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coursework updated successfully.')),
      );
    } else {
      provider.createAssignment(
        classId: _selectedClassId,
        className: _selectedClassName,
        title: _titleCtrl.text,
        subject: _subjectCtrl.text,
        courseCode: _courseCodeCtrl.text,
        description: _descCtrl.text,
        instructions: instructionsList,
        totalMarks: marks,
        deadline: _deadline,
        allowedFormats: _formats.toList(),
        evaluationTimeline: _evaluationTimeline,
        rubricType: _rubricType,
        rubricFileName: _rubricFileName ?? 'Coursework_Rubric.pdf',
        rubricContent: _rubricContentCtrl.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Coursework announced! Rubric & evaluation timeline published to students.'),
        ),
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final teacherClasses = context.watch<AcademiXProvider>().getTeacherClasses();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Coursework' : 'Announce Coursework'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Associated Class dropdown
            DropdownButtonFormField<String?>(
              initialValue: _selectedClassId,
              decoration: const InputDecoration(
                labelText: 'Associated Classroom (Google Classroom style)',
                hintText: 'Select one of your classes',
                prefixIcon: Icon(Icons.school_outlined, size: 20),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All Enrolled Students (General Coursework)'),
                ),
                ...teacherClasses.map((cls) {
                  return DropdownMenuItem<String?>(
                    value: cls.id,
                    child: Text(
                      '${cls.courseCode} · ${cls.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }),
              ],
              onChanged: (val) {
                setState(() {
                  _selectedClassId = val;
                  if (val != null) {
                    final matched = teacherClasses.firstWhere((c) => c.id == val);
                    _selectedClassName = matched.name;
                    if (_subjectCtrl.text.isEmpty) {
                      _subjectCtrl.text = matched.subject;
                    }
                    if (_courseCodeCtrl.text.isEmpty || _courseCodeCtrl.text == 'SE-315') {
                      _courseCodeCtrl.text = matched.courseCode;
                    }
                  } else {
                    _selectedClassName = null;
                  }
                });
              },
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Coursework Title *'),
              validator: (v) =>
                  (v == null || v.trim().length < 4) ? 'Enter a title' : null,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _subjectCtrl,
                    decoration: const InputDecoration(labelText: 'Subject *'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Enter subject'
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _courseCodeCtrl,
                    decoration: const InputDecoration(labelText: 'Code'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description *'),
              validator: (v) => (v == null || v.trim().length < 10)
                  ? 'Provide a description'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _instructionsCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Submission Instructions (one per line)',
                hintText: 'Include references\nUpload handwritten scans clearly',
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _marksCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Total Marks *'),
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null || n <= 0 || n > 500) {
                  return 'Enter 1–500';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            // Deadlines & Evaluation Timeline Section
            const SectionHeader(title: 'Deadlines & Evaluation Timeline'),
            const SizedBox(height: 4),
            const Text(
              'Set when student submissions close, and the timeline when automated OCR & AI grading will be executed and released.',
              style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDeadline,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Submission Deadline',
                        suffixIcon:
                            Icon(Icons.calendar_today_outlined, size: 18),
                      ),
                      child: Text(
                        formatShortDate(_deadline),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _pickEvaluationTimeline,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Evaluation Timeline',
                        suffixIcon: Icon(Icons.schedule_rounded, size: 18),
                      ),
                      child: Text(
                        formatShortDate(_evaluationTimeline),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Rubric Attachment Section
            const SectionHeader(title: 'Assignment Rubric Attachment'),
            const SizedBox(height: 4),
            const Text(
              'Attach rubric as Word doc, PDF, image scan, or text criteria for AI grading evaluation.',
              style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
            ),
            const SizedBox(height: 10),

            // Rubric Type Selector Chips
            Wrap(
              spacing: 8,
              children: [
                _RubricTypeChip(
                  label: 'PDF Document',
                  icon: Icons.picture_as_pdf_outlined,
                  selected: _rubricType == 'PDF',
                  onTap: () => _useSampleRubric('PDF'),
                ),
                _RubricTypeChip(
                  label: 'Word (.docx)',
                  icon: Icons.article_outlined,
                  selected: _rubricType == 'Word',
                  onTap: () => _useSampleRubric('Word'),
                ),
                _RubricTypeChip(
                  label: 'Picture Scan',
                  icon: Icons.image_outlined,
                  selected: _rubricType == 'Image',
                  onTap: () => _useSampleRubric('Image'),
                ),
                _RubricTypeChip(
                  label: 'Text Criteria',
                  icon: Icons.rule_rounded,
                  selected: _rubricType == 'Text',
                  onTap: () => _useSampleRubric('Text'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Attached Rubric Card
            if (_rubricType != 'Text') ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _rubricType == 'PDF'
                            ? Icons.picture_as_pdf_outlined
                            : _rubricType == 'Word'
                                ? Icons.article_outlined
                                : Icons.image_outlined,
                        color: AppColors.primaryBlue,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _rubricFileName ?? 'Rubric_Attachment',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Format: $_rubricType · Attached as evaluation guide',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _pickRubricFile,
                      child: const Text('Change'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            TextFormField(
              controller: _rubricContentCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Rubric Criteria Breakdown',
                hintText: '40% Content Accuracy\n30% Proof & Calculation\n30% Formatting',
              ),
            ),
            const SizedBox(height: 18),

            const Text(
              'Allowed Student Formats',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['PDF', 'DOCX', 'PNG', 'JPG'].map((fmt) {
                final selected = _formats.contains(fmt);
                return FilterChip(
                  label: Text(fmt),
                  selected: selected,
                  selectedColor: AppColors.lightBlue,
                  checkmarkColor: AppColors.primaryBlue,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _formats.add(fmt);
                      } else {
                        _formats.remove(fmt);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _save,
              child: Text(isEdit ? 'Save Changes' : 'Announce Coursework'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RubricTypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RubricTypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBlue : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primaryBlue : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? AppColors.white : AppColors.primaryText,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? AppColors.white : AppColors.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Teacher Screen 4: Coursework Details (With Attached Rubric & Batch OCR Evaluation)
class TeacherAssignmentDetailScreen extends StatelessWidget {
  final String assignmentId;

  const TeacherAssignmentDetailScreen({super.key, required this.assignmentId});

  void _triggerBatchEvaluation(
      BuildContext context, AssignmentModel assignment, int pendingCount) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomContext) => _BatchEvaluationModal(
        assignment: assignment,
        pendingCount: pendingCount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademiXProvider>();
    final assignment = provider.getAssignmentById(assignmentId);
    if (assignment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Coursework Details')),
        body: const EmptyStateView(
          icon: Icons.assignment_late_outlined,
          title: 'Coursework not found',
          description: 'This coursework no longer exists.',
        ),
      );
    }

    final subs = provider.getSubmissionsForAssignment(assignment.id);
    final evaluated =
        subs.where((s) => s.status == SubmissionStatus.evaluated).length;
    final pendingCount = subs.length - evaluated;
    final submissionRate = assignment.totalStudentsEnrolled == 0
        ? 0.0
        : (subs.length / assignment.totalStudentsEnrolled) * 100;

    final evalTimeline = assignment.evaluationTimeline ??
        assignment.deadline.add(const Duration(days: 2));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coursework Details'),
        actions: [
          IconButton(
            tooltip: 'Edit Coursework',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CreateAssignmentScreen(existing: assignment),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Coursework Overview Card
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
                    Text(
                      '${assignment.courseCode} · ${assignment.subject}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    if (assignment.isEvaluationCompleted)
                      const SemanticStatusLabel(
                        label: 'Evaluated',
                        color: AppColors.success,
                        icon: Icons.check_circle_rounded,
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  assignment.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  assignment.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText,
                    height: 1.5,
                  ),
                ),
                const Divider(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Due ${formatShortDate(assignment.deadline)}',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Eval Timeline: ${formatShortDate(evalTimeline)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                MetricBarRow(
                  label: 'Submissions Received ($evaluated evaluated)',
                  value: submissionRate,
                  displayValue:
                      '${subs.length}/${assignment.totalStudentsEnrolled}',
                  color: AppColors.primaryBlue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Attached Rubric Card
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
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        assignment.rubricType == 'PDF'
                            ? Icons.picture_as_pdf_outlined
                            : assignment.rubricType == 'Word'
                                ? Icons.article_outlined
                                : assignment.rubricType == 'Image'
                                    ? Icons.image_outlined
                                    : Icons.rule_rounded,
                        size: 20,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Evaluation Rubric (${assignment.rubricType ?? 'PDF'})',
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            assignment.rubricFileName ?? 'Scoring Rubric Document',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                if (assignment.rubricContent != null &&
                    assignment.rubricContent!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      assignment.rubricContent!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryText,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Automated Evaluation & OCR Trigger Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.lightBlue,
                  AppColors.lightBlue.withValues(alpha: 0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryBlue.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: AppColors.primaryBlue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Automated OCR & AI Rubric Evaluation',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Students cannot evaluate assignments directly. When the deadline passes or according to your evaluation timeline, run the batch process to scan handwritten papers using OCR and grade submissions using the attached ${assignment.rubricType} rubric.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryText,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _triggerBatchEvaluation(
                      context, assignment, pendingCount),
                  icon: const Icon(Icons.document_scanner_rounded, size: 18),
                  label: Text(pendingCount > 0
                      ? 'Run Batch OCR & AI Evaluation ($pendingCount pending)'
                      : 'Re-run Batch OCR Evaluation'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SectionHeader(title: 'Student Submissions (${subs.length})'),
          const SizedBox(height: 8),
          if (subs.isEmpty)
            const EmptyStateView(
              icon: Icons.inbox_outlined,
              title: 'No submissions yet',
              description:
                  'Coursework uploaded by students will appear here for review and evaluation.',
            )
          else
            ...subs.map((sub) {
              final isFlagged = sub.status == SubmissionStatus.flagged;
              final isEval = sub.status == SubmissionStatus.evaluated;
              final isHandwritten =
                  ['PNG', 'JPG', 'JPEG'].contains(sub.fileFormat.toUpperCase());

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            TeacherSubmissionReviewScreen(submissionId: sub.id),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${sub.studentName} (${sub.studentRollNo})',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (isHandwritten) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Handwritten',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFB45309),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${sub.fileName} · ${formatShortDate(sub.submittedAt)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SemanticStatusLabel(
                          label: isFlagged
                              ? 'Flagged'
                              : isEval
                                  ? '${sub.evaluation.finalMarks.toInt()}/${assignment.totalMarks}'
                                  : 'Awaiting OCR',
                          color: isFlagged
                              ? AppColors.error
                              : isEval
                                  ? AppColors.success
                                  : AppColors.warning,
                          icon: isFlagged
                              ? Icons.flag_rounded
                              : isEval
                                  ? Icons.verified_rounded
                                  : Icons.hourglass_empty_rounded,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

// Interactive Batch Evaluation Modal for Teacher
class _BatchEvaluationModal extends StatefulWidget {
  final AssignmentModel assignment;
  final int pendingCount;

  const _BatchEvaluationModal({
    required this.assignment,
    required this.pendingCount,
  });

  @override
  State<_BatchEvaluationModal> createState() => _BatchEvaluationModalState();
}

class _BatchEvaluationModalState extends State<_BatchEvaluationModal> {
  bool _isRunning = false;
  double _progress = 0.0;
  String _currentStep = 'Ready to start batch evaluation';

  Future<void> _startBatchRun() async {
    setState(() {
      _isRunning = true;
      _progress = 0.2;
      _currentStep = '1. Scanning handwritten submissions via OCR engine...';
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _progress = 0.5;
      _currentStep =
          '2. Applying attached ${widget.assignment.rubricType} rubric (${widget.assignment.rubricFileName ?? 'Rubric'})...';
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _progress = 0.85;
      _currentStep =
          '3. Calculating content accuracy, grammar & similarity metrics...';
    });

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    // Execute provider update
    context
        .read<AcademiXProvider>()
        .runBatchEvaluation(assignmentId: widget.assignment.id);

    setState(() {
      _progress = 1.0;
      _currentStep =
          '4. Evaluation complete! Results & OCR analysis released to students.';
    });

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Batch OCR & AI Rubric Evaluation completed! Grades released to student portal.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.lightBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.primaryBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Batch OCR & Rubric Evaluation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      widget.assignment.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
          const SizedBox(height: 16),
          Text(
            _isRunning ? _currentStep : 'This process will:\n'
                '• Automatically scan all handwritten submissions using OCR\n'
                '• Evaluate coursework according to the attached ${widget.assignment.rubricType} rubric\n'
                '• Release marks, grammar, similarity, and feedback to student portals',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.primaryText,
              height: 1.5,
            ),
          ),
          if (_isRunning) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 8,
                backgroundColor: AppColors.border,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              if (!_isRunning) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isRunning ? null : _startBatchRun,
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: Text(_isRunning ? 'Processing...' : 'Run Evaluation Now'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
