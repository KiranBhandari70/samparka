import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/event_model.dart';
import '../../widgets/event_card.dart';
import '../home/event_detail_page.dart';
import '../events/ticket_purchase_page.dart';

class CategoryExplorePage extends StatefulWidget {
  final EventCategory category;

  const CategoryExplorePage({
    super.key,
    required this.category,
  });

  static const String routeName = '/category-explore';

  @override
  State<CategoryExplorePage> createState() => _CategoryExplorePageState();
}

class _CategoryExplorePageState extends State<CategoryExplorePage> {
  // TODO: Replace with real events from backend / provider / BLoC
  final List<EventModel> _allEvents = [];

  // Filter events by selected category
  List<EventModel> get _categoryEvents {
    return _allEvents
        .where((event) => event.category == widget.category.label)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.category.label,
                    style: AppTextStyles.heading1.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_categoryEvents.length} events found',
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Event list
            Expanded(
              child: _categoryEvents.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 64,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No events in this category',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: _categoryEvents.length,
                itemBuilder: (context, index) {
                  final event = _categoryEvents[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: EventCard(
                      event: event,
                      onDetails: () {
                        Navigator.of(context).pushNamed(
                          EventDetailPage.routeName,
                          arguments: EventDetailPage(event: event),
                        );
                      },
                      onJoin: () {
                        Navigator.of(context).pushNamed(
                          TicketPurchasePage.routeName,
                          arguments: {
                            'event': event,
                            'ticketPrice': event.ticketTiers.isNotEmpty
                                ? event.ticketTiers.first.price
                                : 25.00,
                          },
                        );
                      },
                    ),
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
