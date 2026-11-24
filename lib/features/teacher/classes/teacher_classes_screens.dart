import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/state/academix_provider.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../models/assignment_model.dart';
import '../../../models/class_model.dart';
import '../assignments/teacher_assignments_screens.dart';
import '../grading/teacher_grading_feedback_screens.dart';

/// Screen 1: Teacher Classes List ("My Classes")
class TeacherClassesScreen extends StatefulWidget {
  const TeacherClassesScreen({super.key});

  @override
  State<TeacherClassesScreen> createState() => _TeacherClassesScreenState();
}

class _TeacherClassesScreenState extends State<TeacherClassesScreen> {
  final _searchCtrl = TextEditingController();
  bool _showArchived = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademiXProvider>();
    final teacherClasses = provider.getTeacherClasses();
    final query = _searchCtrl.text.trim().toLowerCase();

    final filtered = teacherClasses.where((c) {
      final matchesArchive = _showArchived ? true : c.status == ClassStatus.active;
      final matchesQuery = query.isEmpty ||
          c.name.toLowerCase().contains(query) ||
          c.subject.toLowerCase().contains(query) ||
          c.courseCode.toLowerCase().contains(query) ||
          c.classCode.toLowerCase().contains(query);
      return matchesArchive && matchesQuery;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Classes'),
        actions: [
          IconButton(
            tooltip: _showArchived ? 'Hide Archived' : 'Show Archived',
            icon: Icon(
              _showArchived ? Icons.archive : Icons.archive_outlined,
              color: _showArchived ? AppColors.primaryBlue : null,
            ),
            onPressed: () => setState(() => _showArchived = !_showArchived),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () => _openCreateClassSheet(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('New Class'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search classes, subjects, codes...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: filtered.isEmpty
                ? EmptyStateView(
                    icon: Icons.school_outlined,
                    title: 'No classes found',
                    description: _showArchived
                        ? 'No active or archived classes match your search.'
                        : 'Tap "+ New Class" to create your first Google Classroom-style class.',
                    actionLabel: 'Create Class',
                    onAction: () => _openCreateClassSheet(context),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, i) {
                      final cls = filtered[i];
                      return _TeacherClassCard(classModel: cls);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _openCreateClassSheet(BuildContext context, [ClassModel? editClass]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateOrEditClassModal(existingClass: editClass),
    );
  }
}

/// Class Card Widget
class _TeacherClassCard extends StatelessWidget {
  final ClassModel classModel;

  const _TeacherClassCard({required this.classModel});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademiXProvider>();
    final assignments = provider.getClassAssignments(classModel.id);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: classModel.isArchived
              ? const Color(0xFFCBD5E1)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TeacherClassDetailScreen(classModel: classModel),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: classModel.isArchived
                      ? [const Color(0xFF64748B), const Color(0xFF475569)]
                      : [const Color(0xFF1D4ED8), const Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          classModel.courseCode,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (classModel.isArchived)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Archived',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: classModel.classCode));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Class code copied: ${classModel.classCode}'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.copy_rounded, size: 12, color: Color(0xFF1D4ED8)),
                                const SizedBox(width: 4),
                                Text(
                                  classModel.classCode,
                                  style: const TextStyle(
                                    color: Color(0xFF1D4ED8),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    classModel.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${classModel.subject} ${classModel.section != null ? '· ${classModel.section}' : ''}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            // Card Body Metrics
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  _MetricPill(
                    icon: Icons.people_alt_outlined,
                    label: '${classModel.enrolledCount} Students',
                  ),
                  const SizedBox(width: 12),
                  _MetricPill(
                    icon: Icons.assignment_outlined,
                    label: '${assignments.length} Coursework',
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetricPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF2563EB)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}

/// Screen 2: Teacher Class Detail Screen with 4 Tabs (Overview, Students, Assignments, Submissions)
class TeacherClassDetailScreen extends StatefulWidget {
  final ClassModel classModel;

  const TeacherClassDetailScreen({super.key, required this.classModel});

  @override
  State<TeacherClassDetailScreen> createState() => _TeacherClassDetailScreenState();
}

class _TeacherClassDetailScreenState extends State<TeacherClassDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademiXProvider>();
    // Refresh class model from provider
    final currentClass = provider.classes.firstWhere(
      (c) => c.id == widget.classModel.id,
      orElse: () => widget.classModel,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(currentClass.name),
        actions: [
          IconButton(
            tooltip: 'Share Code',
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: currentClass.classCode));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Class code copied: ${currentClass.classCode}'),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (action) {
              if (action == 'edit') {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => _CreateOrEditClassModal(existingClass: currentClass),
                );
              } else if (action == 'archive') {
                provider.toggleClassArchived(currentClass.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(currentClass.isArchived
                        ? 'Class unarchived!'
                        : 'Class archived successfully.'),
                  ),
                );
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Edit Class Info'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'archive',
                child: Row(
                  children: [
                    Icon(
                      currentClass.isArchived
                          ? Icons.unarchive_outlined
                          : Icons.archive_outlined,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(currentClass.isArchived ? 'Unarchive Class' : 'Archive Class'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.secondaryText,
          indicatorColor: AppColors.primaryBlue,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Students'),
            Tab(text: 'Assignments'),
            Tab(text: 'Submissions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _ClassOverviewTab(classModel: currentClass),
          _ClassStudentsTab(classModel: currentClass),
          _ClassAssignmentsTab(classModel: currentClass),
          _ClassSubmissionsTab(classModel: currentClass),
        ],
      ),
    );
  }
}

/// Tab 1: Overview
class _ClassOverviewTab extends StatelessWidget {
  final ClassModel classModel;

  const _ClassOverviewTab({required this.classModel});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademiXProvider>();
    final assignments = provider.getClassAssignments(classModel.id);
    final enrolledStudents = provider.getClassStudents(classModel.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prominent Class Code Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CLASS JOINING CODE',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      classModel.classCode,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: classModel.classCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Class code copied: ${classModel.classCode}'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1D4ED8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Copy Code', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Share this code with university students so they can enroll directly.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Quick KPI Cards
          Row(
            children: [
              Expanded(
                child: _KpiBox(
                  title: 'Enrolled',
                  value: '${enrolledStudents.length}',
                  icon: Icons.people_outline,
                  color: const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _KpiBox(
                  title: 'Assignments',
                  value: '${assignments.length}',
                  icon: Icons.assignment_outlined,
                  color: const Color(0xFF7C3AED),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Class Details Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Classroom Information',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(label: 'Course Subject', value: classModel.subject),
                  _DetailRow(label: 'Course Code', value: classModel.courseCode),
                  if (classModel.section != null)
                    _DetailRow(label: 'Section', value: classModel.section!),
                  if (classModel.semester != null)
                    _DetailRow(label: 'Semester', value: classModel.semester!),
                  if (classModel.academicYear != null)
                    _DetailRow(label: 'Academic Year', value: classModel.academicYear!),
                  _DetailRow(label: 'Lead Instructor', value: classModel.teacherName),
                  if (classModel.description != null && classModel.description!.isNotEmpty) ...[
                    const Divider(height: 20),
                    const Text(
                      'About Class',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      classModel.description!,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.4),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiBox({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab 2: Enrolled Students
class _ClassStudentsTab extends StatelessWidget {
  final ClassModel classModel;

  const _ClassStudentsTab({required this.classModel});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademiXProvider>();
    final students = provider.getClassStudents(classModel.id);

    if (students.isEmpty) {
      return EmptyStateView(
        icon: Icons.people_outline,
        title: 'No students enrolled yet',
        description: 'Share code "${classModel.classCode}" with your students so they can join.',
        actionLabel: 'Copy Class Code',
        onAction: () {
          Clipboard.setData(ClipboardData(text: classModel.classCode));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Class code copied: ${classModel.classCode}')),
          );
        },
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: students.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final stu = students[i];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFEFF6FF),
              child: Text(
                stu.initials,
                style: const TextStyle(
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            title: Text(
              stu.fullName,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
            ),
            subtitle: Text(
              '${stu.academicId} · ${stu.department}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.person_remove_outlined, color: Color(0xFFEF4444), size: 20),
              tooltip: 'Remove Student',
              onPressed: () async {
                final confirm = await showAcademiXConfirmDialog(
                  context: context,
                  title: 'Remove Student',
                  message: 'Are you sure you want to remove ${stu.fullName} from "${classModel.name}"?',
                  confirmLabel: 'Remove',
                  isDestructive: true,
                );
                if (confirm && context.mounted) {
                  provider.removeStudentFromClass(classModel.id, stu.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${stu.fullName} removed from class.')),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}

/// Tab 3: Assignments for this class
class _ClassAssignmentsTab extends StatelessWidget {
  final ClassModel classModel;

  const _ClassAssignmentsTab({required this.classModel});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademiXProvider>();
    final assignments = provider.getClassAssignments(classModel.id);

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${assignments.length} Coursework items',
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CreateAssignmentScreen(defaultClass: classModel),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add Assignment'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: assignments.isEmpty
              ? EmptyStateView(
                  icon: Icons.assignment_outlined,
                  title: 'No assignments in this class',
                  description: 'Publish your first coursework, attach rubric, and define evaluation timeline.',
                  actionLabel: 'Create Assignment',
                  onAction: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CreateAssignmentScreen(defaultClass: classModel),
                      ),
                    );
                  },
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: assignments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final asg = assignments[i];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(
                          asg.title,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Due ${asg.deadline.day}/${asg.deadline.month}/${asg.deadline.year} · Marks: ${asg.totalMarks}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TeacherAssignmentDetailScreen(assignmentId: asg.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Tab 4: Class Submissions tracking overview (across assignments)
class _ClassSubmissionsTab extends StatelessWidget {
  final ClassModel classModel;

  const _ClassSubmissionsTab({required this.classModel});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademiXProvider>();
    final assignments = provider.getClassAssignments(classModel.id);

    if (assignments.isEmpty) {
      return const EmptyStateView(
        icon: Icons.inbox_outlined,
        title: 'No coursework to track',
        description: 'Create an assignment first to view student submission statuses.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: assignments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, i) {
        final asg = assignments[i];
        final statuses = provider.getClassAssignmentSubmissions(asg.id);
        final submittedCount = statuses.where((s) => s.hasSubmitted).length;
        final evaluatedCount = statuses.where((s) => s.isEvaluated).length;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        asg.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ClassAssignmentSubmissionsScreen(assignment: asg),
                          ),
                        );
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _MiniBadge(
                      label: '$submittedCount/${statuses.length} Submitted',
                      color: const Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 8),
                    _MiniBadge(
                      label: '$evaluatedCount Evaluated',
                      color: const Color(0xFF10B981),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

/// Screen 3: Per-Assignment All-Student Submission Management
class ClassAssignmentSubmissionsScreen extends StatelessWidget {
  final AssignmentModel assignment;

  const ClassAssignmentSubmissionsScreen({super.key, required this.assignment});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademiXProvider>();
    final statuses = provider.getClassAssignmentSubmissions(assignment.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignment Submissions'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${assignment.courseCode} · ${assignment.subject} · Total: ${assignment.totalMarks} Marks',
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: statuses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final item = statuses[i];
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: item.hasSubmitted
                              ? const Color(0xFFEFF6FF)
                              : const Color(0xFFF1F5F9),
                          child: Text(
                            item.student.initials,
                            style: TextStyle(
                              color: item.hasSubmitted
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFF64748B),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.student.fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                item.student.academicId,
                                style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: item.statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.statusLabel,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: item.statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (item.submission != null)
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => TeacherGradeManagementScreen(
                                    submissionId: item.submission!.id,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(
                              item.isEvaluated
                                  ? '${item.submission!.evaluation.finalMarks.toInt()}/${assignment.totalMarks}'
                                  : 'Review',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Modal Bottom Sheet: Create or Edit Class
class _CreateOrEditClassModal extends StatefulWidget {
  final ClassModel? existingClass;

  const _CreateOrEditClassModal({this.existingClass});

  @override
  State<_CreateOrEditClassModal> createState() => _CreateOrEditClassModalState();
}

class _CreateOrEditClassModalState extends State<_CreateOrEditClassModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _subjectCtrl;
  late TextEditingController _codeCtrl;
  late TextEditingController _sectionCtrl;
  late TextEditingController _semCtrl;
  late TextEditingController _yearCtrl;
  late TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    final e = widget.existingClass;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _subjectCtrl = TextEditingController(text: e?.subject ?? '');
    _codeCtrl = TextEditingController(text: e?.courseCode ?? '');
    _sectionCtrl = TextEditingController(text: e?.section ?? 'Section A');
    _semCtrl = TextEditingController(text: e?.semester ?? '6th Semester');
    _yearCtrl = TextEditingController(text: e?.academicYear ?? '2026-2027');
    _descCtrl = TextEditingController(text: e?.description ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _subjectCtrl.dispose();
    _codeCtrl.dispose();
    _sectionCtrl.dispose();
    _semCtrl.dispose();
    _yearCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<AcademiXProvider>();

    if (widget.existingClass != null) {
      provider.updateClass(
        classId: widget.existingClass!.id,
        name: _nameCtrl.text,
        subject: _subjectCtrl.text,
        courseCode: _codeCtrl.text,
        section: _sectionCtrl.text,
        semester: _semCtrl.text,
        academicYear: _yearCtrl.text,
        description: _descCtrl.text,
      );
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Class updated successfully!')),
      );
    } else {
      final newCls = provider.createClass(
        name: _nameCtrl.text,
        subject: _subjectCtrl.text,
        courseCode: _codeCtrl.text,
        section: _sectionCtrl.text,
        semester: _semCtrl.text,
        academicYear: _yearCtrl.text,
        description: _descCtrl.text,
      );
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Class created! Class Code: ${newCls.classCode}'),
          action: SnackBarAction(
            label: 'Copy Code',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: newCls.classCode));
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingClass != null;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Edit Class' : 'Create New Class',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Class Name (Required) *',
                  hintText: 'e.g. Software Engineering - Sec A',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Please enter class name' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _subjectCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Subject *',
                        hintText: 'e.g. Operating Systems',
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Enter subject' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _codeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Course Code *',
                        hintText: 'e.g. CS-304',
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Enter code' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _sectionCtrl,
                      decoration: const InputDecoration(labelText: 'Section'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _semCtrl,
                      decoration: const InputDecoration(labelText: 'Semester'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _yearCtrl,
                decoration: const InputDecoration(
                  labelText: 'Academic Year',
                  hintText: '2026-2027',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description / Instructions',
                  hintText: 'Brief summary of coursework and grading criteria...',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    isEdit ? 'Save Changes' : 'Create Class & Generate Code',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
