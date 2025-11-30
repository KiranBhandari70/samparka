import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:samparka/config/environment.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/models/user_model.dart';
import '../../../provider/user_provider.dart';

class AllUsersPage extends StatefulWidget {
  const AllUsersPage({super.key});

  static const String routeName = '/all-users';

  @override
  State<AllUsersPage> createState() => _AllUsersPageState();
}

class _AllUsersPageState extends State<AllUsersPage> {
  String _searchQuery = '';
  bool _loading = true;
  String? _error;

  List<UserModel> _users = [];

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
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      // Fetch all users (backend allows up to 1000)
      // TODO: Implement pagination if more than 1000 users are needed
      await userProvider.loadRegisteredUsers(limit: 1000);
      
      setState(() {
        _users = userProvider.registeredUsers;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load users: ${e.toString()}';
        _loading = false;
      });
    }
  }

  List<UserModel> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;

    return _users.where((user) {
      final name = user.name.toLowerCase();
      final email = user.email?.toLowerCase() ?? '';
      final search = _searchQuery.toLowerCase();
      return name.contains(search) || email.contains(search);
    }).toList();
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
                  decoration: const InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ),
            ),

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
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.70,
                  ),
                  itemCount: _filteredUsers.length,
                  itemBuilder: (context, index) {
                    return _UserCard(user: _filteredUsers[index]);
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
  final UserModel user;

  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final avatarImage = user.avatarUrlResolved != null
        ? NetworkImage(user.avatarUrlResolved!)
        : null;
    final isVerified = user.verified ?? false;
    final name = user.name;
    final email = user.email ?? '';

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _UserDetailsSheet(user: user),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            CircleAvatar(
              radius: 40,
              backgroundImage: avatarImage,
              backgroundColor: AppColors.border,
              child: avatarImage == null
                  ? const Icon(Icons.person, size: 40, color: AppColors.textSecondary)
                  : null,
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: AppTextStyles.bodyBold.copyWith(fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (isVerified)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(Icons.verified, color: AppColors.accentGreen, size: 16),
              ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _UserDetailsSheet extends StatelessWidget {
  final UserModel user;

  const _UserDetailsSheet({required this.user});

  @override
  Widget build(BuildContext context) {
    final avatarImage = user.avatarUrlResolved != null
        ? NetworkImage(user.avatarUrlResolved!)
        : null;
    final name = user.name;
    final email = user.email ?? '';
    final bio = user.bio ?? '';
    final isVerified = user.verified ?? false;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
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
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: avatarImage,
                    backgroundColor: AppColors.border,
                    child: avatarImage == null
                        ? const Icon(Icons.person, size: 50, color: AppColors.textSecondary)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(name, style: AppTextStyles.heading2),
                      if (isVerified)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(Icons.verified, color: AppColors.accentGreen),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(email),
                  if (bio.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Bio', style: AppTextStyles.heading3),
                    ),
                    const SizedBox(height: 8),
                    Text(bio, style: AppTextStyles.body),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
