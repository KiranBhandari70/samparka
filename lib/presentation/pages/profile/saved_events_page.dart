import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/models/event_model.dart';
import '../../../data/models/ticket_model.dart';
import '../../../provider/ticket_provider.dart';
import '../../../provider/auth_provider.dart';
import '../../widgets/event_card.dart';
import '../events/event_detail_page.dart';

class SavedEventsPage extends StatefulWidget {
  const SavedEventsPage({super.key});

  static const String routeName = '/saved-events';

  @override
  State<SavedEventsPage> createState() => _SavedEventsPageState();
}

class _SavedEventsPageState extends State<SavedEventsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserTickets();
    });
  }

  void _loadUserTickets() {
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userModel?.id ?? '';
    if (userId.isNotEmpty) {
      if (kDebugMode) {
        print('Loading tickets for user: $userId');
      }
      ticketProvider.loadUserTickets(userId).then((_) {
        if (kDebugMode) {
          print('Tickets loaded: ${ticketProvider.userTickets.length}');
        }
      }).catchError((e) {
        if (kDebugMode) {
          print('Error loading tickets: $e');
        }
      });
    } else {
      if (kDebugMode) {
        print('Cannot load tickets: userId is empty');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Tickets'),
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _loadUserTickets();
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: Consumer<TicketProvider>(
            builder: (context, ticketProvider, child) {
              if (ticketProvider.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final tickets = ticketProvider.userTickets;
              
              if (kDebugMode) {
                print('Displaying ${tickets.length} tickets');
                if (tickets.isNotEmpty) {
                  print('First ticket event: ${tickets.first.event?.title ?? 'null'}');
                }
              }

              if (tickets.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: AppColors.primaryGradient,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.confirmation_number_outlined,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No Tickets Yet',
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Purchase tickets for events to see them here',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  final event = ticket.event;
                  
                  if (event == null) {
                    return const SizedBox.shrink();
                  }

                  return _TicketCard(
                    ticket: ticket,
                    event: event,
                    onCancel: () => _showCancelDialog(context, ticket, ticketProvider),
                    onDetails: () {
                      Navigator.of(context).pushNamed(
                        EventDetailPage.routeName,
                        arguments: {'event': event},
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, TicketModel ticket, TicketProvider ticketProvider) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userModel?.id ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text('Cancel Ticket'),
        content: Text(
          'Are you sure you want to cancel this ticket? This action cannot be undone.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'No',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await ticketProvider.cancelTicket(ticket.id, userId);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Ticket cancelled successfully'),
                    backgroundColor: AppColors.accentGreen,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ticketProvider.error ?? 'Failed to cancel ticket'),
                    backgroundColor: AppColors.accentRed,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancel Ticket'),
          ),
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final TicketModel ticket;
  final EventModel event;
  final VoidCallback onCancel;
  final VoidCallback onDetails;

  const _TicketCard({
    required this.ticket,
    required this.event,
    required this.onCancel,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (ticket.status) {
      case 'active':
        statusColor = AppColors.accentGreen;
        statusIcon = Icons.check_circle;
        statusText = 'Active';
        break;
      case 'used':
        statusColor = AppColors.textMuted;
        statusIcon = Icons.done_all;
        statusText = 'Used';
        break;
      case 'cancelled':
        statusColor = AppColors.accentRed;
        statusIcon = Icons.cancel;
        statusText = 'Cancelled';
        break;
      default:
        statusColor = AppColors.textMuted;
        statusIcon = Icons.help;
        statusText = 'Unknown';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Event Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    event.imageUrlOrPlaceholder,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        color: AppColors.border,
                        child: const Icon(Icons.event, size: 50, color: AppColors.textMuted),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Event Name and Price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Event Name
                      Text(
                        event.title,
                        style: AppTextStyles.heading3.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Price
                      Row(
                        children: [
                          Icon(Icons.attach_money, size: 20, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            'NPR ${ticket.amountPaid.toStringAsFixed(2)}',
                            style: AppTextStyles.heading3.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 14, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              statusText,
                              style: AppTextStyles.caption.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Cancel button for active tickets
                if (ticket.isActive)
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.accentRed),
                    onPressed: onCancel,
                    tooltip: 'Cancel Ticket',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


