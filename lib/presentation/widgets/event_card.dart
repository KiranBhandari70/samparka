import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../data/models/category_model.dart';
import '../../data/models/event_model.dart';
import '../../data/services/mock_data.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onJoin;
  final VoidCallback? onDetails;
  final bool showActions;

  const EventCard({
    super.key,
    required this.event,
    this.onJoin,
    this.onDetails,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = MockData.categoryColors(event.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Image.network(
                    event.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 16,
                top: 16,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: colors),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    event.category.label,
                    style: AppTextStyles.caption.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 24).copyWith(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 12),
                _EventInfoRow(
                  icon: Icons.calendar_month_rounded,
                  label:
                  '${_formatDate(event.dateTime)}, ${event.timeLabel}',
                ),
                const SizedBox(height: 8),
                _EventInfoRow(
                  icon: Icons.place_rounded,
                  label: event.locationName,
                ),
                const SizedBox(height: 8),
                _EventInfoRow(
                  icon: Icons.people_alt_rounded,
                  label:
                  '${event.attendeeCount}/${event.capacity} going',
                ),
                const SizedBox(height: 20),
                if (showActions)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onJoin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text('Join Event'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onDetails,
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text('Details'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final weekday = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ][date.weekday - 1];
    return '$weekday, ${months[date.month - 1]} ${date.day}';
  }
}

class _EventInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _EventInfoRow({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

