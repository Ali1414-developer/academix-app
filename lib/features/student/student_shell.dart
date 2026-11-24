import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/state/academix_provider.dart';
import '../../core/widgets/academi_x_bottom_nav.dart';
import 'assignments/student_assignments_screens.dart';
import 'dashboard/student_dashboard_screen.dart';
import 'evaluation/student_evaluation_screens.dart';
import 'notifications/student_notifications_screen.dart';
import 'profile/student_profile_screen.dart';

class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _selectedIndex = 0;

  void _switchTab(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = context.watch<AcademiXProvider>().unreadNotificationCount;

    final screens = [
      StudentDashboardScreen(
        onNavigateToAssignments: () => _switchTab(1),
        onNavigateToResults: () => _switchTab(2),
      ),
      const StudentAssignmentsScreen(),
      const StudentResultsTabScreen(),
      const StudentNotificationsScreen(),
      const StudentProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: AcademiXBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _switchTab,
        items: [
          const AcademiXNavItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
            label: 'Home',
          ),
          const AcademiXNavItem(
            icon: Icons.assignment_outlined,
            selectedIcon: Icons.assignment_rounded,
            label: 'Assignments',
          ),
          const AcademiXNavItem(
            icon: Icons.bar_chart_outlined,
            selectedIcon: Icons.bar_chart_rounded,
            label: 'Results',
          ),
          AcademiXNavItem(
            icon: Icons.notifications_outlined,
            selectedIcon: Icons.notifications_rounded,
            label: 'Notifications',
            badgeCount: unreadCount,
          ),
          const AcademiXNavItem(
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
