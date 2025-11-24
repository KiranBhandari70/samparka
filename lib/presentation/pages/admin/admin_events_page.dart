import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../data/models/event_model.dart';
import '../../widgets/event_card.dart';
import '../home/event_detail_page.dart';

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
      // TODO: Replace with your real API call
      // Example:
      // final events = await EventService().getAllEvents();

      final List<EventModel> events = []; // EMPTY initially

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
                          child: EventCard(
                            event: event,
                            onDetails: () {
                              Navigator.of(context).pushNamed(
                                EventDetailPage.routeName,
                                arguments: {'event': event},
                              );
                            },
                            onJoin: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Joined ${event.title}!')),
                              );
                            },
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
}
