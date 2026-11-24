import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/state/academix_provider.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../models/class_model.dart';
import '../../../models/submission_model.dart';
import '../assignments/student_assignments_screens.dart';

/// Student Screen 1: My Classes (Enrolled Classes)
class StudentClassesScreen extends StatefulWidget {
  const StudentClassesScreen({super.key});

  @override
  State<StudentClassesScreen> createState() => _StudentClassesScreenState();
}

class _StudentClassesScreenState extends State<StudentClassesScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademiXProvider>();
    final studentClasses = provider.getStudentClasses();
    final query = _searchCtrl.text.trim().toLowerCase();

    final filtered = studentClasses.where((c) {
      return query.isEmpty ||
          c.name.toLowerCase().contains(query) ||
          c.subject.toLowerCase().contains(query) ||
          c.teacherName.toLowerCase().contains(query) ||
          c.courseCode.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Classes'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: () => _openJoinClassDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Join Class'),
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
                hintText: 'Search my enrolled classes...',
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
                    icon: Icons.meeting_room_outlined,
                    title: 'No enrolled classes yet',
                    description: 'Ask your university instructor for a class code and tap "Join Class" to enroll.',
                    actionLabel: 'Join a Class',
                    onAction: () => _openJoinClassDialog(context),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, i) {
                      final cls = filtered[i];
                      return _StudentClassCard(classModel: cls);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _openJoinClassDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _JoinClassDialog(),
    );
  }
}

/// Student Class Card
class _StudentClassCard extends StatelessWidget {
  final ClassModel classModel;

  const _StudentClassCard({required this.classModel});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademiXProvider>();
    final assignments = provider.getClassAssignments(classModel.id);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => StudentClassDetailScreen(classModel: classModel),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
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
                      Text(
                        classModel.semester ?? '6th Semester',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11.5,
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
                  const SizedBox(height: 2),
                  Text(
                    'Instructor: ${classModel.teacherName}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.assignment_outlined, size: 16, color: Color(0xFF2563EB)),
                  const SizedBox(width: 6),
                  Text(
                    '${assignments.length} Coursework assignments',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'View Classroom',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF2563EB)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Screen 2: Student Class Details (Information & Assignments)
class StudentClassDetailScreen extends StatelessWidget {
  final ClassModel classModel;

  const StudentClassDetailScreen({super.key, required this.classModel});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademiXProvider>();
    final assignments = provider.getClassAssignments(classModel.id);
    final user = provider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(classModel.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (action) async {
              if (action == 'leave') {
                final confirm = await showAcademiXConfirmDialog(
                  context: context,
                  title: 'Leave Class',
                  message: 'Are you sure you want to unenroll from "${classModel.name}"?',
                  confirmLabel: 'Leave',
                  isDestructive: true,
                );
                if (confirm && context.mounted) {
                  provider.leaveClass(classModel.id);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Unenrolled from class.')),
                  );
                }
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'leave',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app_rounded, color: Color(0xFFEF4444), size: 18),
                    SizedBox(width: 8),
                    Text('Leave Class', style: TextStyle(color: Color(0xFFEF4444))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  classModel.courseCode,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  classModel.name,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.school_outlined, size: 16, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(
                      'Teacher: ${classModel.teacherName}',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
                if (classModel.description != null && classModel.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    classModel.description!,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Coursework header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Class Coursework (${assignments.length})',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (assignments.isEmpty)
            const EmptyStateView(
              icon: Icons.assignment_outlined,
              title: 'No coursework announced yet',
              description: 'Your teacher has not published any assignments in this classroom yet.',
            )
          else
            ...assignments.map((asg) {
              final sub = user != null ? provider.getStudentSubmission(asg.id, user.id) : null;
              final hasSubmitted = sub != null;
              final isEvaluated = sub?.status == SubmissionStatus.evaluated;

              Color statusColor;
              String statusText;

              if (isEvaluated && sub != null) {
                statusColor = const Color(0xFF10B981);
                statusText = 'Graded: ${sub.evaluation.finalMarks.toInt()}/${asg.totalMarks}';
              } else if (hasSubmitted) {
                statusColor = const Color(0xFF2563EB);
                statusText = 'Submitted';
              } else if (asg.isOverdue) {
                statusColor = const Color(0xFFEF4444);
                statusText = 'Overdue';
              } else {
                statusColor = const Color(0xFFF59E0B);
                statusText = 'Pending Submission';
              }

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  title: Text(
                    asg.title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Due: ${asg.deadline.day}/${asg.deadline.month}/${asg.deadline.year} · ${asg.totalMarks} Marks',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StudentAssignmentDetailScreen(assignmentId: asg.id),
                      ),
                    );
                  },
                ),
              );
            }),
        ],
      ),
    );
  }
}

/// Dialog: Join Class by Code
class _JoinClassDialog extends StatefulWidget {
  const _JoinClassDialog();

  @override
  State<_JoinClassDialog> createState() => _JoinClassDialogState();
}

class _JoinClassDialogState extends State<_JoinClassDialog> {
  final _codeCtrl = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  void _handleJoin() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final provider = context.read<AcademiXProvider>();
    final error = provider.joinClass(_codeCtrl.text);

    setState(() => _isLoading = false);

    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Joined class successfully!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.school_rounded, color: Color(0xFF2563EB), size: 22),
          ),
          const SizedBox(width: 10),
          Text(
            'Join Class',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter the 6-8 character class code provided by your teacher (e.g. HCI-7824).',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _codeCtrl,
            textCapitalization: TextCapitalization.characters,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              letterSpacing: 1.5,
              color: const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              labelText: 'Class Code',
              hintText: 'e.g. HCI-7824',
              prefixIcon: const Icon(Icons.vpn_key_outlined, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleJoin,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Join'),
        ),
      ],
    );
  }
}
