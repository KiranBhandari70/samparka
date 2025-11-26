import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/event_model.dart';
import '../../../provider/event_provider.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/user_provider.dart';
import '../../widgets/event_card.dart';
import '../home/event_detail_page.dart';
import '../edit_event/edit_event_page.dart';
import '../settings/settings_page.dart';
import '../admin/admin_dashboard_page.dart';

class ProfilePage extends StatefulWidget {
  final UserModel user;

  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
      _loadUserEvents();
    });
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
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    AppStrings.profileHeading,
                    style: AppTextStyles.heading2,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.settings_rounded),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildProfileCard(context),
            const SizedBox(height: 24),
            _buildStatsCard(),
            const SizedBox(height: 24),
            Text('Interests', style: AppTextStyles.heading3),
            const SizedBox(height: 12),
            _buildInterests(),
            const SizedBox(height: 24),
            if (displayUser.role == 'admin') ...[
              _MenuTile(
                icon: Icons.admin_panel_settings,
                title: 'Admin Dashboard',
                subtitle: 'Manage users and events',
                onTap: () {
                  Navigator.of(context).pushNamed(
                    AdminDashboardPage.routeName,
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
            Text('My Events', style: AppTextStyles.heading3),
            const SizedBox(height: 12),
            _buildMyEvents(context),
            const SizedBox(height: 24),
            if (displayUser.role != 'business') _buildBusinessUpgradeCard(),
            if (displayUser.role != 'business') const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.stars,
              title: 'Rewards Dashboard',
              subtitle: 'View your points and redeem',
              onTap: () {
                Navigator.of(context).pushNamed('/rewards-dashboard');
              },
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.history,
              title: 'My Events',
              subtitle: 'Events you\'re attending',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('My Events feature coming soon')),
                );
              },
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.favorite,
              title: 'Saved Events',
              subtitle: 'Events you\'ve saved',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Saved Events feature coming soon')),
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB347), Color(0xFFFF7A00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundImage: displayUser.avatarUrlResolved != null
                ? NetworkImage(displayUser.avatarUrlResolved!)
                : null,
            child: displayUser.avatarUrlResolved == null
                ? const Icon(Icons.person, size: 48, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            displayUser.name,
            style: AppTextStyles.heading2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            displayUser.email,
            style: AppTextStyles.body.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            displayUser.locationLabel ?? 'No location',
            style: AppTextStyles.caption.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Text(
            displayUser.bio ?? 'No bio available',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 160,
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.of(context).pushNamed('/edit-profile');
                if (result == true) {
                  // Refresh user data after editing
                  _loadUserData();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('Edit Profile'),
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
        // Calculate attended events (events where user is in attendees)
        // For now, we'll use hosted events count as a placeholder
        // In the future, you can add an API endpoint to get attended events
        
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ProfileStat(
                label: 'Hosted',
                value: '$hostedCount',
              ),
              _ProfileStat(
                label: 'Points',
                value: '${displayUser.rewardBalance.toInt()}',
              ),
              _ProfileStat(
                label: 'Interests',
                value: '${displayUser.interests.length}',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInterests() {
    final interests = displayUser.interests ?? [];
    if (interests.isEmpty) {
      return Text(
        'No interests added yet. Add interests in your profile settings.',
        style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
      );
    }
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: interests.map((interest) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(interest, style: AppTextStyles.chip),
        );
      }).toList(),
    );
  }

  Widget _buildMyEvents(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        if (eventProvider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final userEvents = eventProvider.userEvents;

        if (userEvents.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                'No events created yet',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
          );
        }

        return Column(
          children: userEvents.map((event) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Stack(
                children: [
                  EventCard(
                    event: event,
                    showActions: false,
                    onDetails: () {
                      Navigator.of(context).pushNamed(
                        EventDetailPage.routeName,
                        arguments: {'event': event},
                      );
                    },
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EditEventPage(event: event),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteDialog(context, event, eventProvider),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, EventModel event, EventProvider eventProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await eventProvider.deleteEvent(event.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Event deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Reload user events
                _loadUserEvents();
                // Also reload all events to update HomePage and ExplorePage
                await eventProvider.loadUpcomingEvents();
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(eventProvider.error ?? 'Failed to delete event'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessUpgradeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.business,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upgrade to Business',
                      style: AppTextStyles.heading3.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Create offers & manage rewards',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '• Create discount offers for users\n• Manage reward point redemptions\n• Access business analytics\n• Promote your business',
            style: AppTextStyles.body.copyWith(
              color: Colors.white,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showBusinessUpgradeDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Upgrade Now',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBusinessUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade to Business Account'),
        content: const Text(
          'Are you sure you want to upgrade to a business account? This will allow you to:\n\n'
          '• Create discount offers\n'
          '• Manage reward redemptions\n'
          '• Access business dashboard\n'
          '• Promote your business\n\n'
          'You can switch back to a regular account anytime.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _upgradeToBusinessAccount();
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  Future<void> _upgradeToBusinessAccount() async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      // Update user role to business
      await userProvider.updateProfile({
        'role': 'business',
      });

      // Refresh user data
      await authProvider.refreshUser();

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully upgraded to business account!'),
            backgroundColor: AppColors.accentGreen,
          ),
        );

        // Navigate to business dashboard
        Navigator.of(context).pushNamed('/business-dashboard');
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upgrade account: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    }
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.heading3.copyWith(color: AppColors.primary)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}
