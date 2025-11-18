import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/models/group_model.dart';
import '../../../data/services/mock_data.dart';
import '../../widgets/group_tile.dart';
import 'group_chat_page.dart';

class GroupPage extends StatelessWidget {
  const GroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final myGroups =
    MockData.groups.where((group) => group.isJoined).toList();
    final suggestedGroups =
    MockData.groups.where((group) => !group.isJoined).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ListView(
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    AppStrings.groupsHeading.toUpperCase(),
                    style: AppTextStyles.heading2,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.add_circle_rounded,
                        color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Stay connected with your communities',
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: 24),
              if (myGroups.isNotEmpty) ...[
                _SectionTitle(
                  title: 'My Groups',
                  icon: Icons.star_rounded,
                ),
                const SizedBox(height: 16),
                ...myGroups.map(
                      (group) => GroupTile(
                    group: group,
                    onTap: () => _openChat(context, group),
                    onPrimaryAction: () => _openChat(context, group),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              _SectionTitle(
                title: 'Suggested Groups',
                icon: Icons.recommend_rounded,
              ),
              const SizedBox(height: 16),
              ...suggestedGroups.map(
                    (group) => GroupTile(
                  group: group,
                  onPrimaryAction: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Joined ${group.name}!')),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _openChat(BuildContext context, GroupModel group) {
    Navigator.of(context).pushNamed(
      GroupChatPage.routeName,
      arguments: GroupChatArgs(group: group),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTextStyles.heading3,
        ),
      ],
    );
  }
}

