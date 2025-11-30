import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/event_model.dart';
import '../../../data/models/user_model.dart';
import '../../../provider/event_provider.dart';
import '../../../provider/user_provider.dart';
import '../../widgets/event_card.dart';
import '../events/event_detail_page.dart';
import '../events/ticket_purchase_page.dart';
import 'AllUsersPage.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  EventCategory? _selectedCategory;
  String _searchQuery = '';

  final List<EventCategory> _categories = EventCategory.values;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEvents();
      _loadRegisteredUsers();
    });
  }


  Future<void> _loadEvents() async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    await eventProvider.loadUpcomingEvents();
  }

  Future<void> _loadRegisteredUsers() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadRegisteredUsers();
  }

  List<EventModel> _getFilteredEvents(EventProvider eventProvider) {
    // If there's a search query, use filtered events from provider
    if (_searchQuery.isNotEmpty) {
      final searchResults = eventProvider.filteredEvents;
      return searchResults.where((event) {
        final matchesCategory = _selectedCategory == null
            ? true
            : event.categoryString?.toLowerCase() ==
            _selectedCategory!.label.toLowerCase();
        return matchesCategory;
      }).toList();
    }
    
    // Otherwise filter provider events
    return eventProvider.upcomingEvents.where((event) {
      final matchesCategory = _selectedCategory == null
          ? true
          : event.categoryString?.toLowerCase() ==
          _selectedCategory!.label.toLowerCase();
      return matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 5),
              Text(
                AppStrings.exploreSubtitle,
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: 20),

              // SEARCH FIELD
              _SearchField(
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                  if (value.isNotEmpty) {
                    final eventProvider = Provider.of<EventProvider>(context, listen: false);
                    eventProvider.searchEvents(value);
                  } else {
                    _loadEvents();
                  }
                },
              ),

              const SizedBox(height: 24),
              Text('Categories', style: AppTextStyles.heading3),
              const SizedBox(height: 16),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _categories
                    .map(
                      (category) => _CategoryCard(
                    category: category,
                    isSelected: _selectedCategory == category,
                    onTap: () {
                      setState(() {
                        _selectedCategory = _selectedCategory == category
                            ? null
                            : category;
                      });
                    },
                  ),
                )
                    .toList(),
              ),

              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Registered Users', style: AppTextStyles.heading3),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AllUsersPage.routeName);
                    },
                    child: Text(
                      'See All',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                ],
              ),
              const SizedBox(height: 16),

              SizedBox(
                height: 140,
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, _) {
                    if (userProvider.registeredUsersLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (userProvider.registeredUsersError != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Failed to load users',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.red,
                              ),
                            ),
                            TextButton(
                              onPressed: _loadRegisteredUsers,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    final users = userProvider.registeredUsers;
                    if (users.isEmpty) {
                      return Center(
                        child: Text(
                          'No registered users',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        return _UserCard(user: users[index]);
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 28),
              Text('Nearby Events', style: AppTextStyles.heading3),
              const SizedBox(height: 16),

              Consumer<EventProvider>(
                builder: (context, eventProvider, child) {
                  if (eventProvider.isLoading && eventProvider.upcomingEvents.isEmpty && _searchQuery.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (eventProvider.error != null && eventProvider.upcomingEvents.isEmpty && _searchQuery.isEmpty) {
                    return Center(
                      child: Column(
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
                    );
                  }

                  final filteredEvents = _getFilteredEvents(eventProvider);
                  if (filteredEvents.isEmpty) {
                    return Center(
                      child: Text(
                        'No events found',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: filteredEvents.map(
                      (event) => EventCard(
                        event: event,
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
                        onDetails: () {
                          Navigator.of(context).pushNamed(
                            EventDetailPage.routeName,
                            arguments: {'event': event},
                          );
                        },
                      ),
                    ).toList(),
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
}

/// SEARCH FIELD
class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search events...',
        prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
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

/// CATEGORY CARD
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          category.label,
          style: AppTextStyles.body.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// USER CARD
class _UserCard extends StatelessWidget {
  final UserModel user;

  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundImage: user.avatarUrlResolved != null
                ? NetworkImage(user.avatarUrlResolved!)
                : null,
            backgroundColor: AppColors.border,
            child: user.avatarUrlResolved == null
                ? const Icon(Icons.person, color: AppColors.textSecondary)
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            user.name,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
