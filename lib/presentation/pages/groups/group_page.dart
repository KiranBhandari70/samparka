import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/models/group_model.dart';
import '../../widgets/group_tile.dart';
import 'group_chat_page.dart';
import 'group_detail_page.dart';
import 'create_group_page.dart';

class GroupPage extends StatelessWidget {
  final List<GroupModel> groups; // Groups from backend
  final String currentUserId; // Pass current user id here

  const GroupPage({
    super.key,
    required this.groups,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    // Separate joined and suggested groups
    final myGroups =
    groups.where((group) => group.isMember(currentUserId)).toList();
    final suggestedGroups =
    groups.where((group) => !group.isMember(currentUserId)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ListView(
            children: [
              const SizedBox(height: 16),

              /// HEADER
              Row(
                children: [
                  Text(
                    AppStrings.groupsHeading.toUpperCase(),
                    style: AppTextStyles.heading2,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(CreateGroupPage.routeName);
                    },
                    icon: const Icon(
                      Icons.add_circle_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Text(
                'Stay connected with your communities',
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: 24),

              /// MY GROUPS
              if (myGroups.isNotEmpty) ...[
                const _SectionTitle(
                  title: 'My Groups',
                  icon: Icons.star_rounded,
                ),
                const SizedBox(height: 16),
                ...myGroups.map(
                      (group) => GroupTile(
                    group: group,
                    isMember: true,
                    onTap: () => _openDetails(context, group),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              /// SUGGESTED GROUPS
              if (suggestedGroups.isNotEmpty) ...[
                const _SectionTitle(
                  title: 'Suggested Groups',
                  icon: Icons.recommend_rounded,
                ),
                const SizedBox(height: 16),
                ...suggestedGroups.map(
                      (group) => GroupTile(
                    group: group,
                    isMember: false,
                    onTap: () => _openDetails(context, group),
                  ),
                ),
                const SizedBox(height: 32),
              ],
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

  void _openDetails(BuildContext context, GroupModel group) {
    Navigator.of(context).pushNamed(
      GroupDetailPage.routeName,
      arguments: {'group': group},
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
