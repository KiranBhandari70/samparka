import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/models/user_model.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/event_provider.dart';
import '../settings/settings_page.dart';
import 'business_dashboard_page.dart';

class BusinessProfilePage extends StatefulWidget {
  final UserModel user;

  const BusinessProfilePage({super.key, required this.user});

  @override
  State<BusinessProfilePage> createState() => _BusinessProfilePageState();
}

class _BusinessProfilePageState extends State<BusinessProfilePage> with SingleTickerProviderStateMixin {
  UserModel? _currentUser;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
      _loadUserEvents();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.refreshUser();
      if (mounted) {
        setState(() {
          _currentUser = authProvider.userModel ?? widget.user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentUser = widget.user;
          _isLoading = false;
        });
      }
    }
  }

  void _loadUserEvents() {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userModel?.id ?? widget.user.id;
    eventProvider.loadUserEvents(userId);
  }

  UserModel get displayUser => _currentUser ?? widget.user;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadUserData,
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 100,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFB347), Color(0xFFFF7A00)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        'Business Profile',
                        style: AppTextStyles.heading3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.settings_rounded, color: Colors.white),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SettingsPage(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  titlePadding: const EdgeInsets.only(left: 14, bottom: 14, right: 14),
                ),
              ),
              
              // Content
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          _buildProfileCard(context),
                          const SizedBox(height: 24),
                          _buildStatsCard(),
                          const SizedBox(height: 32),
                          _MenuTile(
                            icon: Icons.dashboard_rounded,
                            title: 'Business Dashboard',
                            subtitle: 'Manage your business offers and events',
                            gradient: [Color(0xFFFFB347), Color(0xFFFF7A00)],
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                BusinessDashboardPage.routeName,
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          _MenuTile(
                            icon: Icons.stars_rounded,
                            title: 'Rewards Dashboard',
                            subtitle: 'View your points and redeem',
                            gradient: AppColors.successGradient,
                            onTap: () {
                              Navigator.of(context).pushNamed('/rewards-dashboard');
                            },
                          ),
                          const SizedBox(height: 16),
                          _MenuTile(
                            icon: Icons.history_rounded,
                            title: 'My Events',
                            subtitle: 'View and manage your created events',
                            gradient: AppColors.infoGradient,
                            onTap: () {
                              Navigator.of(context).pushNamed('/my-events');
                            },
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFB347), Color(0xFFFF7A00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFFB347).withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: 0,
          ),
          const BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 3,
                    ),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: CircleAvatar(
                    radius: 52,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    backgroundImage: displayUser.avatarUrlResolved != null
                        ? NetworkImage(displayUser.avatarUrlResolved!)
                        : null,
                    child: displayUser.avatarUrlResolved == null
                        ? const Icon(Icons.business_rounded, size: 52, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  displayUser.name,
                  style: AppTextStyles.heading2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.business_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Business Account',
                        style: AppTextStyles.bodyBold.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.email_rounded,
                      size: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        displayUser.email,
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            final result = await Navigator.of(context).pushNamed('/edit-profile');
                            if (result == true) {
                              _loadUserData();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Color(0xFFFFB347),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.edit_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Edit Profile',
                                style: AppTextStyles.button.copyWith(
                                  color: Color(0xFFFFB347),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        final userEvents = eventProvider.userEvents;
        final hostedCount = userEvents.length;
        
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _ProfileStat(
                  label: 'Events',
                  value: '$hostedCount',
                  icon: Icons.event_rounded,
                  gradient: [Color(0xFFFFB347), Color(0xFFFF7A00)],
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: AppColors.border,
              ),
              Expanded(
                child: _ProfileStat(
                  label: 'Points',
                  value: '${displayUser.rewardBalance.toInt()}',
                  icon: Icons.stars_rounded,
                  gradient: AppColors.successGradient,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MenuTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_MenuTile> createState() => _MenuTileState();
}

class _MenuTileState extends State<_MenuTile> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.gradient[0].withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(widget.icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: AppTextStyles.bodyBold.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final List<Color> gradient;

  const _ProfileStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: gradient[0].withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

