import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../provider/auth_provider.dart';
import '../profile/edit_profile_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static const String routeName = '/settings';

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          // Account Section
          _SettingsSection(
            title: 'Account',
            items: [
              SettingsItem(
                icon: Icons.edit_rounded,
                title: 'Edit Profile',
                onTap: () {
                  Navigator.of(context).pushNamed(EditProfilePage.routeName);
                },
              ),
              SettingsItem(
                icon: Icons.lock_rounded,
                title: 'Privacy and Security',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Notifications Section
          _SettingsSection(
            title: 'Notifications',
            items: [
              SettingsItem(
                icon: Icons.notifications_active_rounded,
                title: 'Push Notifications',
              ),
              SettingsItem(
                icon: Icons.email_rounded,
                title: 'Email Notifications',
              ),
              SettingsItem(
                icon: Icons.event_available_rounded,
                title: 'Event Notifications',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Support Section
          _SettingsSection(
            title: 'Support',
            items: [
              SettingsItem(
                icon: Icons.help_center_rounded,
                title: 'Help Center',
              ),
              SettingsItem(
                icon: Icons.info_rounded,
                title: 'About Samparka',
              ),
              SettingsItem(
                icon: Icons.description_rounded,
                title: 'Terms of Service and Privacy',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Logout Button
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout'),
                        content:
                        const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && mounted) {
                      await authProvider.logout();
                      if (mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/',
                              (route) => false,
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<SettingsItem> items;

  const _SettingsSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              title,
              style: AppTextStyles.heading3,
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          ...items.map(
                (item) => Column(
              children: [
                _SettingsTile(item: item),
                if (item != items.last)
                  const Divider(height: 1, color: AppColors.border),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final SettingsItem item;

  const _SettingsTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: item.onTap,
      leading: Icon(item.icon, color: AppColors.primary),
      title: Text(
        item.title,
        style: AppTextStyles.body.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
    );
  }
}

class SettingsItem {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const SettingsItem({
    required this.icon,
    required this.title,
    this.onTap,
  });
}
