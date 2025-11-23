import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/models/group_model.dart';
import '../../widgets/group_tile.dart';
import 'group_detail_page.dart';
import 'group_chat_page.dart';

class GroupsListPage extends StatefulWidget {
  final List<GroupModel> groups; // <-- real groups from backend/API

  const GroupsListPage({
    super.key,
    required this.groups,
  });

  static const String routeName = '/groups';

  @override
  State<GroupsListPage> createState() => _GroupsListPageState();
}

class _GroupsListPageState extends State<GroupsListPage> {
  String _searchQuery = '';

  List<GroupModel> get _filteredGroups {
    List<GroupModel> list = [...widget.groups];

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((group) {
        return group.name.toLowerCase().contains(q) ||
            group.description.toLowerCase().contains(q) ||
            group.keyword.toLowerCase().contains(q);
      }).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed('/create-group');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 🔍 Search Field
            Padding(
              padding: const EdgeInsets.all(24),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search groups...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // 📌 Group List Section
            Expanded(
              child: _filteredGroups.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.groups_outlined,
                        size: 64, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text(
                      'No groups found',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _filteredGroups.length,
                itemBuilder: (context, index) {
                  final group = _filteredGroups[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GroupTile(
                      group: group,

                      // ➤ Open Group Details
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          GroupDetailPage.routeName,
                          arguments: {'group': group},
                        );
                      },

                      // ➤ Join Group and Open Chat
                      onPrimaryAction: () {
                        // Replace with your actual join API
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Joined ${group.name}!'),
                            backgroundColor: AppColors.accentGreen,
                          ),
                        );

                        Navigator.of(context).pushNamed(
                          GroupChatPage.routeName,
                          arguments: GroupChatArgs(group: group),
                        );
                      },

                      // ➤ Open Chat Page
                      onChatTap: () {
                        Navigator.of(context).pushNamed(
                          GroupChatPage.routeName,
                          arguments: GroupChatArgs(group: group),
                        );
                      },
                    ),
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
