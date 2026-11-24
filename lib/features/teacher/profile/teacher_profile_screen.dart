import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/state/academix_provider.dart';
import '../../../core/widgets/common_widgets.dart';

// Teacher Screen 15: Teacher Profile and Settings
class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademiXProvider>();
    final user = provider.currentUser!;
    final prefs = user.notificationPreferences;

    return Scaffold(
      appBar: AppBar(title: const Text('Faculty Profile & Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.darkBlue,
                  child: Text(
                    user.initials,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${user.academicId} · ${user.semesterOrDesignation} · ${user.department}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
            ),
            child: ListTile(
              leading:
                  const Icon(Icons.edit_outlined, color: AppColors.primaryBlue),
              title: const Text('Edit Faculty Profile',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showEditTeacherSheet(context),
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Notification Preferences'),
          const SizedBox(height: 8),
          Material(
            color: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('New Submission Alerts',
                      style: TextStyle(fontSize: 14)),
                  subtitle: const Text(
                      'Instant alert when students upload coursework',
                      style: TextStyle(fontSize: 12)),
                  value: prefs.newSubmissionAlerts,
                  activeThumbColor: AppColors.primaryBlue,
                  onChanged: (v) => provider.updateNotificationPreferences(
                    prefs.copyWith(newSubmissionAlerts: v),
                  ),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Pending Review Reminders',
                      style: TextStyle(fontSize: 14)),
                  subtitle: const Text(
                      'Daily reminder for ungraded and flagged submissions',
                      style: TextStyle(fontSize: 12)),
                  value: prefs.evaluationUpdates,
                  activeThumbColor: AppColors.primaryBlue,
                  onChanged: (v) => provider.updateNotificationPreferences(
                    prefs.copyWith(evaluationUpdates: v),
                  ),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Assignment Deadline Alerts',
                      style: TextStyle(fontSize: 14)),
                  subtitle: const Text('Notify when assignment windows close',
                      style: TextStyle(fontSize: 12)),
                  value: prefs.deadlineReminders,
                  activeThumbColor: AppColors.primaryBlue,
                  onChanged: (v) => provider.updateNotificationPreferences(
                    prefs.copyWith(deadlineReminders: v),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () async {
              final confirmed = await showAcademiXConfirmDialog(
                context: context,
                title: 'Sign Out',
                message:
                    'Are you sure you want to log out of the Teacher Portal?',
                confirmLabel: 'Logout',
                isDestructive: true,
              );
              if (confirmed && context.mounted) {
                context.read<AcademiXProvider>().logout();
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              minimumSize: const Size(double.infinity, 48),
            ),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showEditTeacherSheet(BuildContext context) {
    final provider = context.read<AcademiXProvider>();
    final user = provider.currentUser!;
    final nameCtrl = TextEditingController(text: user.fullName);
    final deptCtrl = TextEditingController(text: user.department);
    final desigCtrl = TextEditingController(text: user.semesterOrDesignation);
    final phoneCtrl = TextEditingController(text: user.phone);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Faculty Profile',
                  style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: deptCtrl,
                decoration: const InputDecoration(labelText: 'Department'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: desigCtrl,
                decoration: const InputDecoration(labelText: 'Designation'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  provider.updateProfile(
                    fullName: nameCtrl.text,
                    department: deptCtrl.text,
                    semesterOrDesignation: desigCtrl.text,
                    phone: phoneCtrl.text,
                  );
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Faculty profile updated.')),
                  );
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
