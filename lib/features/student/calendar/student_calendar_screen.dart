import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/state/academix_provider.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../models/assignment_model.dart';
import '../assignments/student_assignments_screens.dart';

// Student Screen 12: Deadlines and Calendar
class StudentCalendarScreen extends StatefulWidget {
  const StudentCalendarScreen({super.key});

  @override
  State<StudentCalendarScreen> createState() => _StudentCalendarScreenState();
}

class _StudentCalendarScreenState extends State<StudentCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _taskFilter = 'All';

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademiXProvider>();
    final assignments = provider.assignments;

    List<AssignmentModel> eventsForDay(DateTime day) =>
        assignments.where((a) => _isSameDay(a.deadline, day)).toList();

    final visibleTasks = assignments.where((a) {
      if (_selectedDay != null && !_isSameDay(a.deadline, _selectedDay!)) {
        return false;
      }
      final sub = provider.getStudentSubmissionForAssignment(a.id);
      if (_taskFilter == 'Completed') return sub != null;
      if (_taskFilter == 'Pending') return sub == null;
      return true;
    }).toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deadlines & Calendar'),
        actions: [
          if (_selectedDay != null)
            TextButton(
              onPressed: () => setState(() => _selectedDay = null),
              child: const Text('Show Month'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: TableCalendar<AssignmentModel>(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2028, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) =>
                  _selectedDay != null && _isSameDay(_selectedDay!, day),
              eventLoader: eventsForDay,
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColors.lightBlue,
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w700,
                ),
                selectedDecoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: AppColors.warning,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedDay == null
                    ? 'All Scheduled Deadlines'
                    : 'Deadlines on ${formatShortDate(_selectedDay!)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: ['All', 'Pending', 'Completed'].map((filter) {
              final active = _taskFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(filter),
                  selected: active,
                  onSelected: (_) => setState(() => _taskFilter = filter),
                  selectedColor: AppColors.primaryBlue,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: active ? AppColors.white : AppColors.primaryText,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          if (visibleTasks.isEmpty)
            const EmptyStateView(
              icon: Icons.event_note_outlined,
              title: 'No deadlines scheduled',
              description:
                  'Select another date or switch to "Show Month" to inspect all upcoming tasks.',
            )
          else
            ...visibleTasks.map((asg) {
              final sub = provider.getStudentSubmissionForAssignment(asg.id);
              final isDone = sub != null;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StudentAssignmentDetailScreen(
                          assignmentId: asg.id,
                        ),
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
                        Icon(
                          isDone
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: isDone ? AppColors.success : AppColors.warning,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                asg.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${asg.subject} · ${formatDateTime(asg.deadline)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          isDone ? 'Completed' : 'Pending',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                isDone ? AppColors.success : AppColors.warning,
                          ),
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
