import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/event_model.dart';
import '../../../provider/event_provider.dart';
import '../../widgets/event_card.dart';
import '../home/event_detail_page.dart';
import '../events/ticket_purchase_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  EventCategory? _selectedCategory;

  // REAL data must come from backend
  List<CategoryModel> _categories = [];

  List<EventModel> _filteredEvents(List<EventModel> events) {
    if (_selectedCategory == null) return events;
    return events
        .where((event) => event.category == _selectedCategory)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadEvents();
  }

  Future<void> _loadCategories() async {
    // TODO: Replace with API call
    // _categories = await apiService.getCategories();
    setState(() {});
  }

  Future<void> _loadEvents() async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    await eventProvider.loadUpcomingEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.discoverHeading,
                      style: AppTextStyles.heading2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.discoverSubtitle,
                      style: AppTextStyles.subtitle,
                    ),
                    const SizedBox(height: 24),
                    const _SearchField(),
                    const SizedBox(height: 24),
                    _CategoryFilter(
                      categories: _categories,
                      selected: _selectedCategory,
                      onSelected: (category) {
                        setState(() => _selectedCategory = category);
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              Consumer<EventProvider>(
                builder: (context, eventProvider, child) {
                  if (eventProvider.isLoading && eventProvider.upcomingEvents.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (eventProvider.error != null && eventProvider.upcomingEvents.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error loading events: ${eventProvider.error}',
                              style: AppTextStyles.body.copyWith(
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadEvents,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final events = _filteredEvents(eventProvider.upcomingEvents);
                  if (events.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'No events found',
                          style: AppTextStyles.body,
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final event = events[index];
                        return EventCard(
                          event: event,
                          onDetails: () => Navigator.of(context).pushNamed(
                            EventDetailPage.routeName,
                            arguments: {'event': event},
                          ),
                          onJoin: () {
                            Navigator.of(context).pushNamed(
                              TicketPurchasePage.routeName,
                              arguments: {
                                'event': event,
                                'ticketPrice': event.ticketTiers.isNotEmpty
                                    ? event.ticketTiers.first.price
                                    : 0.0,
                              },
                            );
                          },
                        );
                      },
                      childCount: events.length,
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search events',
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  final List<CategoryModel> categories;
  final EventCategory? selected;
  final ValueChanged<EventCategory?> onSelected;

  const _CategoryFilter({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'All Events',
            isActive: selected == null,
            onTap: () => onSelected(null),
          ),
          ...categories.map(
                (category) => _FilterChip(
              label: category.name,
              isActive: selected?.label.toLowerCase() == category.name.toLowerCase(),
              onTap: () => onSelected(EventCategoryX.fromString(category.name)),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.chip.copyWith(
              color: isActive ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
