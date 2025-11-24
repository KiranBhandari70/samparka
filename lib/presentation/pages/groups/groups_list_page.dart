import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/models/group_model.dart';
import '../../../provider/group_provider.dart';
import '../../../provider/auth_provider.dart';
import '../../widgets/group_tile.dart';
import '../groups/create_group_page.dart';
import '../groups/group_detail_page.dart';

class GroupsListPage extends StatefulWidget {
  const GroupsListPage({super.key});

  static const String routeName = '/groups';

  @override
  State<GroupsListPage> createState() => _GroupsListPageState();
}

class _GroupsListPageState extends State<GroupsListPage> {
  String _searchQuery = '';

  // Filter groups based on search query
  List<GroupModel> _filterGroups(List<GroupModel> groups) {
    if (_searchQuery.isEmpty) return groups;

    final q = _searchQuery.toLowerCase();
    return groups.where((group) {
      return group.name.toLowerCase().contains(q) ||
          group.description.toLowerCase().contains(q) ||
          group.keywords.any((k) => k.toLowerCase().contains(q));
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<GroupProvider>(context, listen: false);
    provider.loadGroups(); // Load groups when page opens
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        Provider.of<AuthProvider>(context, listen: false).currentUserId;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final created =
              await Navigator.of(context).pushNamed(CreateGroupPage.routeName);
              if (created == true) {
                Provider.of<GroupProvider>(context, listen: false).loadGroups();
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<GroupProvider>(
          builder: (context, groupProvider, child) {
            if (groupProvider.isLoading && groupProvider.groups.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final filteredGroups = _filterGroups(groupProvider.groups);

            if (filteredGroups.isEmpty) {
              return Center(
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
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Search groups...',
                      prefixIcon:
                      const Icon(Icons.search, color: AppColors.textMuted),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: filteredGroups.length,
                    itemBuilder: (context, index) {
                      final group = filteredGroups[index];
                      final isMember =
                          currentUserId != null && group.isMember(currentUserId);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GroupTile(
                          group: group,
                          isMember: isMember,
                          onTap: () {
                            // Open group detail page on tap
                            Navigator.of(context).pushNamed(
                              GroupDetailPage.routeName,
                              arguments: group,
                            );
                          },


                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
