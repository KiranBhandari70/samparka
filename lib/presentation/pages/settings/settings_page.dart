import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/text_styles.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const String routeName = '/settings';

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
        children: const [
          _SettingsSection(
            title: 'Account',
            items: [
              SettingsItem(
                icon: Icons.edit_rounded,
                title: 'Edit Profile',
              ),
              SettingsItem(
                icon: Icons.lock_rounded,
                title: 'Privacy and Security',
              ),
            ],
          ),
          SizedBox(height: 24),
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
          SizedBox(height: 24),
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
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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


