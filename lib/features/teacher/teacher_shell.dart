import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/state/academix_provider.dart';
import '../../core/widgets/academi_x_bottom_nav.dart';
import 'assignments/teacher_assignments_screens.dart';
import 'dashboard/teacher_dashboard_screen.dart';
import 'notifications/teacher_notifications_screen.dart';
import 'profile/teacher_profile_screen.dart';
import 'submissions/teacher_submissions_screens.dart';

class TeacherShell extends StatefulWidget {
  const TeacherShell({super.key});

  @override
  State<TeacherShell> createState() => _TeacherShellState();
}

class _TeacherShellState extends State<TeacherShell> {
  int _selectedIndex = 0;

  void _switchTab(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = context.watch<AcademiXProvider>().unreadNotificationCount;

    final screens = [
      TeacherDashboardScreen(
        onNavigateToAssignments: () => _switchTab(1),
        onNavigateToSubmissions: () => _switchTab(2),
      ),
      const TeacherManageAssignmentsScreen(),
      const TeacherSubmissionsScreen(),
      const TeacherNotificationsScreen(),
      const TeacherProfileScreen(),
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
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard_rounded,
            label: 'Home',
          ),
          const AcademiXNavItem(
            icon: Icons.assignment_outlined,
            selectedIcon: Icons.assignment_rounded,
            label: 'Assignments',
          ),
          const AcademiXNavItem(
            icon: Icons.inbox_outlined,
            selectedIcon: Icons.inbox_rounded,
            label: 'Submissions',
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
