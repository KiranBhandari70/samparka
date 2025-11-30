import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/models/group_model.dart';
import '../../../provider/group_provider.dart';
import '../../../provider/auth_provider.dart';
import '../../widgets/primary_button.dart';
import 'group_chat_page.dart';

class GroupDetailPage extends StatelessWidget {
  final GroupModel group;

  const GroupDetailPage({super.key, required this.group});

  static const String routeName = '/group-detail';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.userModel?.id ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Group Details')),
      body: Consumer<GroupProvider>(
        builder: (context, groupProvider, _) {
          // Always use updated group if selectedGroup matches ID
          final currentGroup = groupProvider.selectedGroup?.id == group.id
              ? groupProvider.selectedGroup!
              : group;

          final isMember = currentGroup.isMember(currentUserId);

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              /// GROUP IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  currentGroup.imageUrlOrPlaceholder,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholderImage(),
                ),
              ),
              const SizedBox(height: 24),

              /// TITLE
              Text(currentGroup.name, style: AppTextStyles.heading2),
              const SizedBox(height: 8),
              Text(
                'Created ${_formatDate(currentGroup.createdAt)}',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),

              /// DESCRIPTION
              if (currentGroup.description.isNotEmpty) ...[
                Text('About', style: AppTextStyles.heading3),
                const SizedBox(height: 8),
                Text(currentGroup.description,
                    style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 24),
              ],

              /// KEYWORDS
              Text('Keywords', style: AppTextStyles.heading3),
              const SizedBox(height: 12),
              if (currentGroup.keywords.isEmpty)
                Text('No keywords added.',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textMuted))
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: currentGroup.keywords
                      .map((k) => Chip(
                    label: Text('#$k'),
                    backgroundColor: AppColors.primary.withOpacity(0.08),
                    labelStyle: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ))
                      .toList(),
                ),
              const SizedBox(height: 24),

              /// ADMIN
              Text('Admin', style: AppTextStyles.heading3),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundImage: currentGroup.createdByPhotoUrl != null
                        ? NetworkImage(currentGroup.createdByPhotoUrl!)
                        : null,
                    child: currentGroup.createdByPhotoUrl == null
                        ? const Icon(Icons.person, size: 28)
                        : null,
                  ),
                  title: Text(currentGroup.createdByName ?? 'Unknown Admin',
                      style: AppTextStyles.heading3),
                  subtitle: const Text('Group Creator'),
                ),
              ),
              const SizedBox(height: 24),

              /// MEMBERS SECTION
              Text('Members (${currentGroup.memberCount})',
                  style: AppTextStyles.heading3),
              const SizedBox(height: 12),
              Column(
                children: currentGroup.membersData.map((member) {
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundImage: member.fullAvatarUrl != null
                            ? NetworkImage(member.fullAvatarUrl!)
                            : null,
                        child: member.fullAvatarUrl == null
                            ? const Icon(Icons.person, size: 24)
                            : null,
                      ),
                      title: Text(member.name, style: AppTextStyles.body),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              /// JOIN / CHAT BUTTON
              PrimaryButton(
                label: isMember ? 'Chat' : 'Join Group',
                onPressed: () async {
                  if (!isMember) {
                    final joined = await groupProvider.joinGroup(currentGroup.id);

                    if (joined) {
                      // Fetch updated group data with correct member list
                      await groupProvider.loadGroupDetails(currentGroup.id);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Joined ${currentGroup.name}!'),
                            backgroundColor: Colors.green),
                      );
                    }
                  }

                  // Navigate to chat ONLY if user is now a member
                  final updatedGroup = groupProvider.selectedGroup ?? currentGroup;

                  if (updatedGroup.isMember(currentUserId)) {
                    Navigator.pushNamed(
                      context,
                      GroupChatPage.routeName,
                      arguments: GroupChatArgs(group: updatedGroup),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      height: 220,
      color: AppColors.border,
      child: const Icon(Icons.groups_rounded, size: 60, color: AppColors.textMuted),
    );
  }

  String _formatDate(DateTime dateTime) {
    final months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }
}
