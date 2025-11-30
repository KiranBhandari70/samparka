import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/models/event_model.dart';
import '../../../data/services/admin_service.dart';
import '../../../data/services/event_service.dart';
import '../../widgets/event_card.dart';
import '../events/event_detail_page.dart';

class AdminEventsPage extends StatefulWidget {
  const AdminEventsPage({super.key});

  static const String routeName = '/admin-events';

  @override
  State<AdminEventsPage> createState() => _AdminEventsPageState();
}

class _AdminEventsPageState extends State<AdminEventsPage> {
  List<EventModel> _allEvents = [];
  String _searchQuery = '';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final events = await AdminService.instance.getAllEvents();

      setState(() {
        _allEvents = events;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load events';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  List<EventModel> get _filteredEvents {
    if (_searchQuery.isEmpty) return _allEvents;

    return _allEvents
        .where((event) =>
    event.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (event.description ?? '')
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('All Events'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 🔍 SEARCH FIELD
            Padding(
              padding: const EdgeInsets.all(24),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search events...',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // 🔄 LOADING
            if (_loading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )

            // ❌ ERROR
            else if (_error != null)
              Expanded(
                child: Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              )

            // 📭 EMPTY DATA
            else if (_allEvents.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      'No events found',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                )

              // 📋 EVENTS LIST
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: fetchEvents,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _filteredEvents.length,
                      itemBuilder: (context, index) {
                        final EventModel event = _filteredEvents[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _AdminEventCard(
                            event: event,
                            onDetails: () {
                              Navigator.of(context).pushNamed(
                                EventDetailPage.routeName,
                                arguments: {'event': event},
                              );
                            },
                            onDelete: () => _deleteEvent(event),
                          ),
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

  Future<void> _deleteEvent(EventModel event) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Delete Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this event?',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.event, size: 20, color: AppColors.accentRed),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event.title,
                      style: AppTextStyles.bodyBold.copyWith(
                        color: AppColors.accentRed,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This action cannot be undone.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Show loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await EventService.instance.deleteEvent(event.id);
      
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog
      
      setState(() {
        _allEvents.removeWhere((e) => e.id == event.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event deleted successfully'),
            backgroundColor: AppColors.accentGreen,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete event: ${e.toString()}'),
            backgroundColor: AppColors.accentRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

class _AdminEventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onDetails;
  final VoidCallback onDelete;

  const _AdminEventCard({
    required this.event,
    required this.onDetails,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onDetails,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Event Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    event.imageUrlOrPlaceholder,
                    width: 70,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: AppColors.border,
                        child: const Icon(Icons.event, size: 40),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Event Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: AppTextStyles.heading3,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_month, size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            '${_formatDate(event.dateTime)} • ${event.timeLabel}',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.place, size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.locationName,
                              style: AppTextStyles.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Delete Button
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.accentRed),
                  onPressed: onDelete,
                  tooltip: 'Delete Event',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }
}
