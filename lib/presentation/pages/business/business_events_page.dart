import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/models/event_model.dart';
import '../../widgets/event_card.dart';
import '../home/event_detail_page.dart';

class BusinessEventsPage extends StatelessWidget {
  const BusinessEventsPage({super.key});

  static const String routeName = '/business-events';

  // TODO: Replace with real events from backend / provider / bloc
  List<EventModel> get _allEvents => [];

  @override
  Widget build(BuildContext context) {
    // Filter sponsored events (currently none)
    final sponsoredEvents =
    _allEvents.where((event) => event.isSponsored).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Sponsored Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed('/create-sponsored-event');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: sponsoredEvents.isEmpty
            ? Center(
          child: Text(
            'No sponsored events found',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: sponsoredEvents.length,
          itemBuilder: (context, index) {
            final event = sponsoredEvents[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Stack(
                children: [
                  EventCard(
                    event: event,
                    onDetails: () {
                      Navigator.of(context).pushNamed(
                        EventDetailPage.routeName,
                        arguments: EventDetailPage(event: event),
                      );
                    },
                    onJoin: () {},
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'SPONSORED',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
