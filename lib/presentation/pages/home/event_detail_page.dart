import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/models/event_comment_model.dart';
import '../../../data/models/event_model.dart';
import '../../../data/models/user_model.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/event_provider.dart';
import '../events/ticket_purchase_page.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailPage extends StatefulWidget {
  final EventModel event;

  const EventDetailPage({super.key, required this.event});

  static const String routeName = '/event-detail';

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  EventModel? _fullEvent;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFullEvent();
  }

  Future<void> _loadFullEvent() async {
    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final fullEvent = await eventProvider.getEventById(widget.event.id);
      if (mounted) {
        setState(() {
          _fullEvent = fullEvent;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  EventModel get event => _fullEvent ?? widget.event;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final eventProvider = context.watch<EventProvider>();
    final UserModel? host = event.host;
    final commentCount = eventProvider.commentCountFor(event.id) ?? event.commentCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 260,
                    pinned: true,
                    leading: Padding(
                      padding: const EdgeInsets.all(8),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                        child: Image.network(
                          event.imageUrlOrPlaceholder,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(event.title, style: AppTextStyles.heading2),

                          const SizedBox(height: 16),

                          // Date/time
                          _InfoRow(
                            icon: Icons.calendar_month_rounded,
                            label: '${_formatDate(event.dateTime)} • ${event.timeLabel}',
                          ),

                          const SizedBox(height: 12),

                          // Location
                          _InfoRow(
                            icon: Icons.place_rounded,
                            label: event.locationName.isNotEmpty
                                ? event.locationName
                                : 'Location TBA',
                          ),

                          const SizedBox(height: 12),

                          // Capacity
                          _InfoRow(
                            icon: Icons.people_alt_rounded,
                            label: '${event.attendeeCount}/${event.capacity} attendees',
                          ),

                          if (event.tags.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: event.tags
                                  .map(
                                    (tag) => Chip(
                                  label: Text(tag),
                                  backgroundColor: AppColors.primary.withOpacity(0.1),
                                  labelStyle: AppTextStyles.caption.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                                  .toList(),
                            ),
                          ],

                          if (event.rewardBoost > 0) ...[
                            const SizedBox(height: 12),
                            _InfoRow(
                              icon: Icons.stars_rounded,
                              label: '${event.rewardBoost}% Reward Boost',
                            ),
                          ],

                          const SizedBox(height: 24),

                          // About
                          Text('About this event', style: AppTextStyles.heading3),
                          const SizedBox(height: 12),
                          Text(
                            event.description ?? 'No description available.',
                            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                          ),

                          const SizedBox(height: 28),

                          // Organizer
                          Text('Organizer', style: AppTextStyles.heading3),
                          const SizedBox(height: 16),
                          _OrganizerCard(host: host),

                          const SizedBox(height: 32),

                          // Location Map
                          Text('Location', style: AppTextStyles.heading3),
                          const SizedBox(height: 16),
                          _MapSection(location: event.location),

                          const SizedBox(height: 32),

                          // Attendees Section
                          if (event.attendeeCount > 0) ...[
                            Text('Attendees', style: AppTextStyles.heading3),
                            const SizedBox(height: 12),
                            Text(
                              '${event.attendeeCount} people are attending this event',
                              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Ticket Tiers
                          if (event.ticketTiers.isNotEmpty) ...[
                            Text('Ticket Options', style: AppTextStyles.heading3),
                            const SizedBox(height: 12),
                            ...event.ticketTiers.map(
                                  (tier) => Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tier.label,
                                          style: AppTextStyles.body.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (tier.rewardPoints != null && tier.rewardPoints! > 0)
                                          Text(
                                            '${tier.rewardPoints} reward points',
                                            style: AppTextStyles.caption.copyWith(
                                              color: AppColors.primary,
                                            ),
                                          ),
                                      ],
                                    ),
                                    Text(
                                      '${tier.price} ${tier.currency}',
                                      style: AppTextStyles.heading3.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Comments Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Comments', style: AppTextStyles.heading3),
                              Text(
                                '$commentCount',
                                style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Comments Section
                          CommentsSection(eventId: event.id),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom button (Buy Tickets only)
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      TicketPurchasePage.routeName,
                      arguments: {'event': event},
                    );
                  },
                  child: const Text('Buy Tickets'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];
    final day = date.day;
    final suffix = _daySuffix(day);
    return '${months[date.month - 1]} $day$suffix, ${date.year}';
  }

  String _daySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white,
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _OrganizerCard extends StatelessWidget {
  final UserModel? host;

  const _OrganizerCard({required this.host});

  @override
  Widget build(BuildContext context) {
    if (host == null) {
      return Text('Organizer information not available',
          style: AppTextStyles.body.copyWith(color: AppColors.textMuted));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 18)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: host!.avatarUrlResolved != null
                ? NetworkImage(host!.avatarUrlResolved!)
                : null,
            child: host!.avatarUrlResolved == null
                ? const Icon(Icons.person)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(host!.name, style: AppTextStyles.heading3.copyWith(fontSize: 18)),
                const SizedBox(height: 4),
                Text('Event Host', style: AppTextStyles.caption),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            child: const Text('Follow'),
          ),
        ],
      ),
    );
  }
}

class _MapSection extends StatelessWidget {
  final EventLocation? location;

  const _MapSection({this.location});

  Future<void> _openGoogleMaps(double lat, double lng) async {
    final Uri googleMapUri = Uri.parse(
      "geo:$lat,$lng?q=$lat,$lng",
    );

    if (await canLaunchUrl(googleMapUri)) {
      await launchUrl(googleMapUri, mode: LaunchMode.externalApplication);
    } else {
      // fallback: open in browser google maps
      final Uri browserUrl = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
      );
      await launchUrl(browserUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double? lat = location?.latitude;
    final double? lng = location?.longitude;
    final placeName = location?.placeName ?? 'Location';

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 18)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Container(
              color: AppColors.border,
              child: Center(
                child: Text(
                  '$placeName\n(${lat ?? "--"}, ${lng ?? "--"})',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ),

            // 👉 ONLY THIS BUTTON UPDATED
            Positioned(
              bottom: 16,
              right: 16,
              child: ElevatedButton.icon(
                onPressed: (lat != null && lng != null)
                    ? () => _openGoogleMaps(lat, lng)
                    : null,
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Open in Maps'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class CommentsSection extends StatefulWidget {
  final String eventId;

  const CommentsSection({required this.eventId});

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final TextEditingController _controller = TextEditingController();
  bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadComments();
    });
  }

  Future<void> _loadComments() async {
    await context.read<EventProvider>().loadEventComments(widget.eventId);
    if (mounted && !_hasLoadedOnce) {
      setState(() {
        _hasLoadedOnce = true;
      });
    }
  }

  Future<void> _addComment() async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login to add a comment')),
      );
      return;
    }

    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final success =
    await context.read<EventProvider>().addEventComment(widget.eventId, text);

    if (!mounted) return;
    if (success) {
      _controller.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add comment')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final authProvider = context.watch<AuthProvider>();

    final comments = eventProvider.commentsFor(widget.eventId);
    final isLoading = eventProvider.isCommentsLoading(widget.eventId) && !_hasLoadedOnce;
    final isPosting = eventProvider.isPostingComment(widget.eventId);
    final canComment = authProvider.isAuthenticated && !isPosting;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: authProvider.isAuthenticated && !isPosting,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: authProvider.isAuthenticated
                        ? 'Add a comment...'
                        : 'Login to comment',
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                onPressed: canComment ? _addComment : null,
                icon: isPosting
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.send_rounded),
                color: AppColors.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (comments.isEmpty)
          Text(
            'No comments yet.',
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
          )
        else
          ...comments.map((comment) => CommentCard(comment: comment)),
      ],
    );
  }
}

class CommentCard extends StatelessWidget {
  final EventCommentModel comment;

  const CommentCard({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(comment.avatarUrlResolved),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        comment.userName,
                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      comment.timeAgo,
                      style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}