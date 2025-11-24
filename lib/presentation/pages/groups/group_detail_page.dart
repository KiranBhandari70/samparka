import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/models/group_model.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/group_provider.dart';
import '../../widgets/primary_button.dart';
import 'group_chat_page.dart';

class GroupDetailPage extends StatefulWidget {
  final GroupModel group;

  const GroupDetailPage({super.key, required this.group});

  static const String routeName = '/group-detail';

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  GroupModel? _group;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDetails();
    });
  }

  Future<void> _loadDetails() async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    await groupProvider.loadGroupDetails(widget.group.id);
    if (!mounted) return;
    setState(() {
      _group = groupProvider.selectedGroup ?? widget.group;
      _isLoading = false;
    });
  }

  GroupModel get group => _group ?? widget.group;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.userModel?.id ?? '';
    final isMember = currentUserId.isNotEmpty && group.members.contains(currentUserId);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Group Details'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadDetails,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                group.imageUrlOrPlaceholder,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 220,
                    color: AppColors.border,
                    child: const Icon(
                      Icons.groups_rounded,
                      size: 60,
                      color: AppColors.textMuted,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(group.name, style: AppTextStyles.heading2),
            const SizedBox(height: 8),
            Text(
              'Created ${_formatDate(group.createdAt)}',
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            if (group.description.isNotEmpty) ...[
              Text('About', style: AppTextStyles.heading3),
              const SizedBox(height: 8),
              Text(
                group.description,
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
            ],
            Text('Keywords', style: AppTextStyles.heading3),
            const SizedBox(height: 12),
            if (group.keywords.isEmpty)
              Text(
                'No keywords added.',
                style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
              )
            else
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
            const SizedBox(height: 24),
            Text('Stats', style: AppTextStyles.heading3),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatBadge(
                  icon: Icons.people_alt_rounded,
                  label: 'Members',
                  value: '${group.memberCount}',
                ),
                const SizedBox(width: 12),
                _StatBadge(
                  icon: Icons.person,
                  label: 'Admin',
                  value: group.createdByName ?? 'Unknown',
                ),
              ],
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Chat',
              onPressed: () => _handleChatAction(isMember),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _loadDetails,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
              ),
              child: const Text('Refresh Details'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleChatAction(bool isMember) async {
    if (!isMember) {
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      final success = await groupProvider.joinGroup(group.id);
      if (!mounted) return;

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(groupProvider.error ?? 'Failed to join group'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await _loadDetails();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Joined ${group.name}!'),
          backgroundColor: Colors.green,
        ),
      );
    }

    if (!mounted) return;
    _openChat(group);
  }

  void _openChat(GroupModel group) {
    Navigator.of(context).pushNamed(
      GroupChatPage.routeName,
      arguments: GroupChatArgs(group: group),
    );
  }

  String _formatDate(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatBadge({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.heading3.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

