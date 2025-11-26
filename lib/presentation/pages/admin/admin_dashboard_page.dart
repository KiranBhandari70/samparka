import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/text_styles.dart';
import 'admin_users_page.dart';
import 'admin_events_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  static const String routeName = '/admin-dashboard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Controls',
                style: AppTextStyles.heading2,
              ),
              const SizedBox(height: 8),
              Text(
                'Manage users, events, and platform content',
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _AdminCard(
                      icon: Icons.people,
                      title: 'Users',
                      subtitle: 'Manage users',
                      color: AppColors.accentBlue,
                      onTap: () {
                        Navigator.of(context).pushNamed(AdminUsersPage.routeName);
                      },
                    ),
                    _AdminCard(
                      icon: Icons.event,
                      title: 'Events',
                      subtitle: 'View all events',
                      color: AppColors.primary,
                      onTap: () {
                        Navigator.of(context).pushNamed(AdminEventsPage.routeName);
                      },
                    ),

                  ],
                ),
              ),





            ],
          ),
        ),
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AdminCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}

