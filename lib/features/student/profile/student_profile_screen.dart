import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/state/academix_provider.dart';
import '../../../core/widgets/common_widgets.dart';

// Student Screen 14: Student Profile and Settings
class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademiXProvider>();
    final user = provider.currentUser!;
    final prefs = user.notificationPreferences;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
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
                  backgroundColor: AppColors.primaryBlue,
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
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${user.academicId} · ${user.department} · ${user.semesterOrDesignation}',
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

          // Account Actions
          Material(
            color: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_outlined,
                      color: AppColors.primaryBlue),
                  title: const Text('Edit Profile Information',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showEditProfileSheet(context),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.lock_outline_rounded,
                      color: AppColors.primaryBlue),
                  title: const Text('Change Password',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showChangePasswordSheet(context),
                ),
              ],
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
                  title: const Text('Deadline Reminders',
                      style: TextStyle(fontSize: 14)),
                  subtitle: const Text(
                      'Alerts before assignment submission due dates',
                      style: TextStyle(fontSize: 12)),
                  value: prefs.deadlineReminders,
                  activeThumbColor: AppColors.primaryBlue,
                  onChanged: (v) => provider.updateNotificationPreferences(
                    prefs.copyWith(deadlineReminders: v),
                  ),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Evaluation Updates',
                      style: TextStyle(fontSize: 14)),
                  subtitle: const Text(
                      'Notify when grades and reports are published',
                      style: TextStyle(fontSize: 12)),
                  value: prefs.evaluationUpdates,
                  activeThumbColor: AppColors.primaryBlue,
                  onChanged: (v) => provider.updateNotificationPreferences(
                    prefs.copyWith(evaluationUpdates: v),
                  ),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Teacher Feedback Alerts',
                      style: TextStyle(fontSize: 14)),
                  subtitle: const Text(
                      'Notify when instructors post approved feedback',
                      style: TextStyle(fontSize: 12)),
                  value: prefs.feedbackAlerts,
                  activeThumbColor: AppColors.primaryBlue,
                  onChanged: (v) => provider.updateNotificationPreferences(
                    prefs.copyWith(feedbackAlerts: v),
                  ),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Course Announcements',
                      style: TextStyle(fontSize: 14)),
                  subtitle: const Text('New assignments and course notices',
                      style: TextStyle(fontSize: 12)),
                  value: prefs.announcements,
                  activeThumbColor: AppColors.primaryBlue,
                  onChanged: (v) => provider.updateNotificationPreferences(
                    prefs.copyWith(announcements: v),
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
                message: 'Are you sure you want to log out of the Student Portal?',
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

  void _showEditProfileSheet(BuildContext context) {
    final provider = context.read<AcademiXProvider>();
    final user = provider.currentUser!;
    final nameCtrl = TextEditingController(text: user.fullName);
    final deptCtrl = TextEditingController(text: user.department);
    final semCtrl = TextEditingController(text: user.semesterOrDesignation);
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
              Text('Edit Student Profile',
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
                controller: semCtrl,
                decoration: const InputDecoration(labelText: 'Semester'),
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
                    semesterOrDesignation: semCtrl.text,
                    phone: phoneCtrl.text,
                  );
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated.')),
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

  void _showChangePasswordSheet(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? errorMsg;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
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
                Text('Change Password',
                    style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 14),
                if (errorMsg != null) ...[
                  Text(errorMsg!,
                      style:
                          const TextStyle(color: AppColors.error, fontSize: 13)),
                  const SizedBox(height: 10),
                ],
                TextFormField(
                  controller: currentCtrl,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: 'Current Password'),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: newCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New Password'),
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Minimum 6 characters'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmCtrl,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: 'Confirm New Password'),
                  validator: (v) =>
                      v != newCtrl.text ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    final err = context.read<AcademiXProvider>().changePassword(
                          currentPassword: currentCtrl.text,
                          newPassword: newCtrl.text,
                        );
                    if (err != null) {
                      setModalState(() => errorMsg = err);
                      return;
                    }
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Password changed successfully.')),
                    );
                  },
                  child: const Text('Update Password'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
