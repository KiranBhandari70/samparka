import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/event_model.dart';
import '../../../data/services/mock_data.dart';
import '../../widgets/event_card.dart';
import '../home/event_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  EventCategory? _selectedCategory;

  List<EventModel> get _filteredEvents {
    if (_selectedCategory == null) {
      return MockData.featuredEvents;
    }
    return MockData.featuredEvents
        .where((event) => event.category == _selectedCategory)
        .toList();
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
                    _SearchField(),
                    const SizedBox(height: 24),
                    _CategoryFilter(
                      selected: _selectedCategory,
                      onSelected: (category) {
                        setState(() => _selectedCategory = category);
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final event = _filteredEvents[index];
                    return EventCard(
                      event: event,
                      onDetails: () => Navigator.of(context).pushNamed(
                        EventDetailPage.routeName,
                        arguments: EventDetailArgs(event: event),
                      ),
                      onJoin: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('You joined ${event.title}!'),
                          ),
                        );
                      },
                    );
                  },
                  childCount: _filteredEvents.length,
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search events',
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  final EventCategory? selected;
  final ValueChanged<EventCategory?> onSelected;

  const _CategoryFilter({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final categories = MockData.categories;
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
              label: category.label,
              isActive: selected == category,
              onTap: () => onSelected(category),
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

