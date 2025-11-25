import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../data/models/group_model.dart';
import '../../provider/group_provider.dart';
import '../pages/groups/group_chat_page.dart';
import '../pages/groups/group_detail_page.dart';

class GroupTile extends StatelessWidget {
  final GroupModel group;
  final bool isMember;
  final VoidCallback onTap;

  const GroupTile({
    super.key,
    required this.group,
    required this.isMember,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
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
            /// Group Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  group.imageUrlOrPlaceholder,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholderImage(),
                ),
              ),
            ),

            /// Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title
                  Text(group.name, style: AppTextStyles.heading3),

                  const SizedBox(height: 8),

                  /// Description
                  if (group.description.isNotEmpty)
                    Text(
                      group.description,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                  const SizedBox(height: 12),

                  /// Keywords
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: group.keywords
                        .map(
                          (k) => Chip(
                        label: Text('#$k'),
                        backgroundColor:
                        AppColors.primary.withOpacity(0.08),
                        labelStyle: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                        .toList(),
                  ),

                  const SizedBox(height: 16),

                  /// Member Count & Buttons
                  Row(
                    children: [
                      const Icon(Icons.people_alt_rounded,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),

                      /// MEMBER COUNT (kept as you requested!)
                      Text(
                        "${group.memberCount} members",
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const Spacer(),

                      /// CHAT / JOIN BUTTON
                      ElevatedButton(
                        onPressed: () async {
                          if (isMember) {
                            Navigator.of(context).pushNamed(
                              GroupChatPage.routeName,
                              arguments: GroupChatArgs(group: group),
                            );
                          } else {
                            final success =
                            await groupProvider.joinGroup(group.id);
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Joined ${group.name}!"),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              Navigator.of(context).pushNamed(
                                GroupDetailPage.routeName,
                                arguments: group,
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          isMember ? AppColors.primary : Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(isMember ? "Chat" : "Join"),
                      ),

                      const SizedBox(width: 8),

                      /// DETAILS BUTTON
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            GroupDetailPage.routeName,
                            arguments: group,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text("Details"),
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

  Widget _placeholderImage() {
    return Container(
      color: AppColors.border,
      child: const Icon(
        Icons.groups_rounded,
        size: 60,
        color: AppColors.textMuted,
      ),
    );
  }
}
