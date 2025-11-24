import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/event_model.dart';
import '../../../provider/event_provider.dart';
import '../../../provider/auth_provider.dart';
import '../../widgets/event_card.dart';
import '../home/event_detail_page.dart';
import '../edit_event/edit_event_page.dart';
import '../settings/settings_page.dart';

class ProfilePage extends StatefulWidget {
  final UserModel user;

  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserEvents();
    });
  }

  void _loadUserEvents() {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    eventProvider.loadUserEvents(widget.user.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
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
            Text('My Events', style: AppTextStyles.heading3),
            const SizedBox(height: 12),
            _buildMyEvents(context),
            const SizedBox(height: 24),
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
            backgroundImage: (widget.user.avatarUrl?.isNotEmpty ?? false)
                ? NetworkImage(widget.user.avatarUrl!)
                : null,
            child: (widget.user.avatarUrl == null || widget.user.avatarUrl!.isEmpty)
                ? const Icon(Icons.person, size: 48, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            widget.user.name,
            style: AppTextStyles.heading2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            widget.user.email,
            style: AppTextStyles.body.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            widget.user.locationLabel ?? 'No location',
            style: AppTextStyles.caption.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Text(
            widget.user.bio ?? 'No bio available',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 160,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/edit-profile');
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          _ProfileStat(label: 'Events', value: '24'),
          _ProfileStat(label: 'Hosted', value: '3'),
          _ProfileStat(label: 'Badges', value: '3'),
          _ProfileStat(label: 'Followers', value: '156'),
        ],
      ),
    );
  }

  Widget _buildInterests() {
    final interests = widget.user.interests ?? [];
    if (interests.isEmpty) return const Text('No interests added');
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
