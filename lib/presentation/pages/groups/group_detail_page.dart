import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/models/group_model.dart';
import '../../widgets/primary_button.dart';
import 'group_chat_page.dart';

class GroupDetailPage extends StatelessWidget {
  const GroupDetailPage({super.key});

  static const String routeName = '/group-detail';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final group = args['group'] as GroupModel;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 200,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: group.imageUrl.isNotEmpty
                          ? Image.network(
                              group.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.border,
                                  child: const Icon(
                                    Icons.groups_rounded,
                                    size: 60,
                                    color: AppColors.textMuted,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: AppColors.border,
                              child: const Icon(
                                Icons.groups_rounded,
                                size: 60,
                                color: AppColors.textMuted,
                              ),
                            ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      group.name,
                                      style: AppTextStyles.heading2,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.people, size: 16, color: AppColors.textMuted),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${group.memberCount} members',
                                          style: AppTextStyles.caption,
                                        ),
                                        const SizedBox(width: 16),
                                        Icon(Icons.circle, size: 8, color: AppColors.accentGreen),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${group.onlineCount} online',
                                          style: AppTextStyles.caption,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (group.isJoined)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentGreen.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.check_circle, size: 16, color: AppColors.accentGreen),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Joined',
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.accentGreen,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'About',
                            style: AppTextStyles.heading3,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            group.description,
                            style: AppTextStyles.body,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Recent Activity',
                            style: AppTextStyles.heading3,
                          ),
                          const SizedBox(height: 16),
                          _ActivityItem(
                            icon: Icons.chat_bubble_outline,
                            title: 'New message in chat',
                            time: '2 hours ago',
                          ),
                          const SizedBox(height: 12),
                          _ActivityItem(
                            icon: Icons.event,
                            title: 'Upcoming event announced',
                            time: '1 day ago',
                          ),
                          const SizedBox(height: 12),
                          _ActivityItem(
                            icon: Icons.person_add,
                            title: '5 new members joined',
                            time: '2 days ago',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: group.isJoined
                  ? PrimaryButton(
                      label: 'Open Chat',
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          GroupChatPage.routeName,
                          arguments: GroupChatArgs(group: group),
                        );
                      },
                    )
                  : PrimaryButton(
                      label: 'Join Group',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('You joined ${group.name}!'),
                            backgroundColor: AppColors.accentGreen,
                          ),
                        );
                        // Navigate to chat after joining
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamed(
                          GroupChatPage.routeName,
                          arguments: GroupChatArgs(group: group),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

