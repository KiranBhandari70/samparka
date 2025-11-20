import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/models/category_model.dart';
import '../../../data/services/mock_data.dart';
import '../../widgets/event_card.dart';
import '../home/event_detail_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  EventCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final categories = MockData.categories;
    final nearbyEvents = MockData.upcomingEvents.where((event) {
      if (_selectedCategory == null) return true;
      return event.category == _selectedCategory;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ListView(
            children: [
              const SizedBox(height: 16),
              Text(
                AppStrings.exploreHeading,
                style: AppTextStyles.heading2,
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.exploreSubtitle,
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: 20),
              _SearchField(),
              const SizedBox(height: 24),
              Text(
                'Categories',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: categories
                    .map(
                      (category) => _CategoryCard(
                    category: category,
                    isSelected: _selectedCategory == category,
                    onTap: () {
                      setState(() {
                        _selectedCategory = category == _selectedCategory
                            ? null
                            : category;
                      });
                    },
                  ),
                )
                    .toList(),
              ),
              const SizedBox(height: 28),
              Text(
                'Nearby Events',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 16),
              ...nearbyEvents.map(
                    (event) => EventCard(
                  event: event,
                  onJoin: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('You joined ${event.title}!')),
                    );
                  },
                  onDetails: () => Navigator.of(context).pushNamed(
                    EventDetailPage.routeName,
                    arguments: EventDetailArgs(event: event),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final EventCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = MockData.categoryColors(category);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors.last.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
          border: isSelected
              ? Border.all(color: Colors.white, width: 2)
              : Border.all(color: Colors.transparent),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_iconForCategory(category), color: Colors.white, size: 32),
            const SizedBox(height: 12),
            Text(
              category.label,
              style: AppTextStyles.button.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _iconForCategory(EventCategory category) {
  switch (category) {
    case EventCategory.music:
      return Icons.music_note_rounded;
    case EventCategory.art:
      return Icons.palette_rounded;
    case EventCategory.sports:
      return Icons.fitness_center_rounded;
    case EventCategory.tech:
      return Icons.memory_rounded;
    case EventCategory.social:
      return Icons.people_alt_rounded;
    case EventCategory.food:
      return Icons.restaurant_rounded;
    case EventCategory.wellness:
      return Icons.self_improvement_rounded;
    case EventCategory.others:
      return Icons.event_rounded;
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
