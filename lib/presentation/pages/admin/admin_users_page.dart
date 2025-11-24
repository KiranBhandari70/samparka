import 'package:flutter/material.dart';
import 'package:samparka/config/environment.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/text_styles.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  static const String routeName = '/admin-users';

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  String _searchQuery = '';
  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // TODO: Connect with your backend API
      // Example usage:
      // final users = await AdminService().getAllUsers();

      // For now users list is EMPTY until backend is connected
      final users = <Map<String, dynamic>>[];

      setState(() {
        _users = users;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load users';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;

    return _users.where((user) {
      final name = user['name'].toString().toLowerCase();
      final email = user['email'].toString().toLowerCase();
      final search = _searchQuery.toLowerCase();

      return name.contains(search) || email.contains(search);
    }).toList();
  }

  Future<void> _blockUser(String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: const Text('Are you sure you want to block this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentRed,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Block'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // TODO call backend
      // await AdminService().blockUser(userId);

      setState(() {
        final user = _users.firstWhere((u) => u['id'] == userId);
        user['isBlocked'] = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User blocked successfully'),
          backgroundColor: AppColors.accentRed,
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to block user')),
      );
    }
  }

  Future<void> _unblockUser(String userId) async {
    try {
      // TODO call backend
      // await AdminService().unblockUser(userId);

      setState(() {
        final user = _users.firstWhere((u) => u['id'] == userId);
        user['isBlocked'] = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User unblocked successfully'),
          backgroundColor: AppColors.accentGreen,
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to unblock user')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Manage Users')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),

            // LOADING
            if (_loading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )

            // ERROR
            else if (_error != null)
              Expanded(
                child: Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: AppColors.accentRed),
                  ),
                ),
              )

            // EMPTY
            else if (_users.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      'No users found',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                )

              // USER LIST
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return _UserCard(
                        user: user,
                        onBlock:
                        user['isBlocked'] ? null : () => _blockUser(user['id']),
                        onUnblock:
                        user['isBlocked'] ? () => _unblockUser(user['id']) : null,
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

class _UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback? onBlock;
  final VoidCallback? onUnblock;

  const _UserCard({
    required this.user,
    this.onBlock,
    this.onUnblock,
  });

  @override
  Widget build(BuildContext context) {
    final isBlocked = user['isBlocked'] as bool? ?? false;
    final isVerified = user['isVerified'] as bool? ?? false;
    final avatarImage = _resolveAvatar(user['avatarUrl']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border:
        isBlocked ? Border.all(color: AppColors.accentRed, width: 2) : null,
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: avatarImage,
            child: avatarImage == null ? const Icon(Icons.person) : null,
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user['name'] ?? 'Unknown',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isVerified) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.verified, size: 16, color: AppColors.accentGreen),
                    ],
                    if (isBlocked) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'BLOCKED',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.accentRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user['email'] ?? '',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),

          // BLOCK / UNBLOCK
          if (onBlock != null)
            IconButton(
              icon: const Icon(Icons.block, color: AppColors.accentRed),
              onPressed: onBlock,
            ),
          if (onUnblock != null)
            IconButton(
              icon:
              const Icon(Icons.check_circle, color: AppColors.accentGreen),
              onPressed: onUnblock,
            ),
        ],
      ),
    );
  }
}

ImageProvider? _resolveAvatar(dynamic url) {
  if (url is! String || url.isEmpty) return null;
  final resolved = url.startsWith('http')
      ? url
      : '${Environment.apiBaseUrl}$url';
  return NetworkImage(resolved);
}
