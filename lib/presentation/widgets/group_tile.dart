import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../data/models/group_model.dart';
import '../../provider/group_provider.dart';
import '../../provider/auth_provider.dart';
import '../pages/groups/group_chat_page.dart';
import '../pages/groups/group_detail_page.dart';

class GroupTile extends StatelessWidget {
  final GroupModel group;
  final bool isMember;
  final VoidCallback? onTap;

  const GroupTile({
    super.key,
    required this.group,
    required this.isMember,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final currentUserId =
        Provider.of<AuthProvider>(context, listen: false).currentUserId;

    return GestureDetector(
      onTap: onTap ??
              () {
            Navigator.of(context).pushNamed(
              GroupDetailPage.routeName,
              arguments: group,
            );
          },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 22,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: group.imageUrlOrPlaceholder.isNotEmpty
                    ? Image.network(
                  group.imageUrlOrPlaceholder,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.border,
                    child: const Icon(
                      Icons.groups_rounded,
                      size: 60,
                      color: AppColors.textMuted,
                    ),
                  ),
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
            // Info
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Online count
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      '${group.onlineCount} online',
                      style: AppTextStyles.caption,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(group.name, style: AppTextStyles.heading3),
                  const SizedBox(height: 8),
                  if (group.description.isNotEmpty)
                    Text(
                      group.description,
                      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                    ),
                  if (group.keywords.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: group.keywords
                          .map(
                            (keyword) => Chip(
                          label: Text('#$keyword'),
                          backgroundColor: AppColors.primary.withOpacity(0.08),
                          labelStyle: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Members and button
                  Row(
                    children: [
                      const Icon(Icons.people_alt_rounded,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${group.memberCount} members',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () async {
                          if (isMember) {
                            // Navigate to chat if already a member
                            Navigator.of(context).pushNamed(
                              GroupChatPage.routeName,
                              arguments: GroupChatArgs(group: group),
                            );
                          } else {
                            // Join group and then navigate to detail page
                            final success = await groupProvider.joinGroup(group.id);
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Joined ${group.name}!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.of(context).pushNamed(
                                GroupDetailPage.routeName,
                                arguments: group,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to join ${group.name}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isMember ? AppColors.primary : Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(isMember ? 'Chat' : 'Join Group'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
