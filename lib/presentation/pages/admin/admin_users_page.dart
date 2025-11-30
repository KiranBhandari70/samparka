import 'package:flutter/material.dart';
import 'package:samparka/config/environment.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/services/admin_service.dart';

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
      final users = await AdminService.instance.getAllUsers();

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
      await AdminService.instance.setUserBlocked(userId, true);

      setState(() {
        final user = _users.firstWhere((u) => u['id'] == userId || u['_id'] == userId);
        user['blocked'] = true;
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
      await AdminService.instance.setUserBlocked(userId, false);

      setState(() {
        final user = _users.firstWhere((u) => u['id'] == userId || u['_id'] == userId);
        user['blocked'] = false;
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
      appBar: AppBar(
        title: const Text('All Users'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 64, color: AppColors.textMuted),
                              const SizedBox(height: 16),
                              Text(
                                _error!,
                                style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: fetchUsers,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _filteredUsers.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.people_outline, size: 64, color: AppColors.textMuted),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No users found',
                                    style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: fetchUsers,
                              child: GridView.builder(
                                padding: const EdgeInsets.all(18),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.70,
                                ),
                                itemCount: _filteredUsers.length,
                                itemBuilder: (context, index) {
                                  final user = _filteredUsers[index];
                                  return _UserCard(
                                    user: user,
                                    onBlock: user['blocked'] == true
                                        ? null
                                        : () => _blockUser(user['id'] ?? user['_id']),
                                    onUnblock: user['blocked'] == true
                                        ? () => _unblockUser(user['id'] ?? user['_id'])
                                        : null,
                                  );
                                },
                              ),
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

  ImageProvider? _resolveAvatar(dynamic url) {
    if (url is! String || url.isEmpty) return null;
    final resolved = url.startsWith('http')
        ? url
        : '${Environment.apiBaseUrl}$url';
    return NetworkImage(resolved);
  }

  @override
  Widget build(BuildContext context) {
    final isBlocked = user['blocked'] as bool? ?? false;
    final isVerified = user['verified'] as bool? ?? false;
    final role = user['role'] as String? ?? 'member';
    final avatarImage = _resolveAvatar(user['avatarUrl']);
    final name = user['name'] ?? 'Unknown';
    final email = user['email'] ?? '';

    return GestureDetector(
      onTap: () {
        // Show user details bottom sheet
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _UserDetailsSheet(
            user: user,
            onBlock: onBlock,
            onUnblock: onUnblock,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isBlocked
              ? Border.all(color: AppColors.accentRed, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar Section
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  gradient: LinearGradient(
                    colors: isBlocked
                        ? [AppColors.accentRed.withOpacity(0.1), AppColors.accentRed.withOpacity(0.05)]
                        : role == 'admin'
                            ? AppColors.secondaryGradient
                            : role == 'business'
                                ? [const Color(0xFFFFB347), const Color(0xFFFF7A00)]
                                : AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 37,
                          backgroundColor: Colors.white,
                          backgroundImage: avatarImage,
                          child: avatarImage == null
                              ? Icon(
                                  Icons.person,
                                  size: 40,
                                  color: AppColors.textMuted,
                                )
                              : null,
                        ),
                      ),
                    ),
                    // Verified Badge
                    if (isVerified)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.accentGreen,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentGreen.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.verified,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    // Role Badge
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          role.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            color: role == 'admin'
                                ? AppColors.secondaryGradient[0]
                                : role == 'business'
                                    ? const Color(0xFFFFB347)
                                    : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Info Section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.bodyBold.copyWith(
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    if (isBlocked) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'BLOCKED',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.accentRed,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback? onBlock;
  final VoidCallback? onUnblock;

  const _UserDetailsSheet({
    required this.user,
    this.onBlock,
    this.onUnblock,
  });

  ImageProvider? _resolveAvatar(dynamic url) {
    if (url is! String || url.isEmpty) return null;
    final resolved = url.startsWith('http')
        ? url
        : '${Environment.apiBaseUrl}$url';
    return NetworkImage(resolved);
  }

  @override
  Widget build(BuildContext context) {
    final isBlocked = user['blocked'] as bool? ?? false;
    final isVerified = user['verified'] as bool? ?? false;
    final role = user['role'] as String? ?? 'member';
    final avatarImage = _resolveAvatar(user['avatarUrl']);
    final name = user['name'] ?? 'Unknown';
    final email = user['email'] ?? '';
    final bio = user['bio'] as String?;
    final interests = user['interests'] as List<dynamic>? ?? [];

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar and Name
                  Center(
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 3,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            backgroundImage: avatarImage,
                            child: avatarImage == null
                                ? const Icon(Icons.person, size: 50)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              name,
                              style: AppTextStyles.heading2,
                            ),
                            if (isVerified) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.verified,
                                color: AppColors.accentGreen,
                                size: 24,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          email,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: role == 'admin'
                                ? AppColors.secondaryGradient[0].withOpacity(0.1)
                                : role == 'business'
                                    ? const Color(0xFFFFB347).withOpacity(0.1)
                                    : AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            role.toUpperCase(),
                            style: AppTextStyles.bodyBold.copyWith(
                              color: role == 'admin'
                                  ? AppColors.secondaryGradient[0]
                                  : role == 'business'
                                      ? const Color(0xFFFFB347)
                                      : AppColors.primary,
                            ),
                          ),
                        ),
                        if (isBlocked) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.accentRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'BLOCKED',
                              style: AppTextStyles.bodyBold.copyWith(
                                color: AppColors.accentRed,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (bio != null && bio.isNotEmpty) ...[
                    Text(
                      'Bio',
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bio,
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (interests.isNotEmpty) ...[
                    Text(
                      'Interests',
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: interests.map((interest) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            interest.toString(),
                            style: AppTextStyles.caption,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Action Buttons
                  if (onBlock != null || onUnblock != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          if (onBlock != null) {
                            onBlock!();
                          } else if (onUnblock != null) {
                            onUnblock!();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: onBlock != null
                              ? AppColors.accentRed
                              : AppColors.accentGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          onBlock != null ? 'Block User' : 'Unblock User',
                          style: AppTextStyles.button.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
