import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/models/event_model.dart';
import '../../widgets/primary_button.dart';

class TicketPurchasePage extends StatefulWidget {
  final EventModel event;

  const TicketPurchasePage({super.key, required this.event});

  static const String routeName = '/ticket-purchase';

  @override
  State<TicketPurchasePage> createState() => _TicketPurchasePageState();
}

class _TicketPurchasePageState extends State<TicketPurchasePage> {
  int _ticketCount = 1;
  late TicketTier _selectedTier;

  @override
  void initState() {
    super.initState();
    // Default to first ticket tier
    _selectedTier = widget.event.ticketTiers.isNotEmpty
        ? widget.event.ticketTiers[0]
        : const TicketTier(label: "Standard", price: 0.0);
  }

  double get _totalPrice => _selectedTier.price * _ticketCount;

  void _payWithESewa() {
    final amount = _totalPrice.toStringAsFixed(2);
    final esewaUrl =
        "https://uat.esewa.com.np/epay/main?amt=$amount&pid=${widget.event.id}&scd=EPAYTEST&su=https://your-success-url.com&fu=https://your-failure-url.com";

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ESewaWebViewPage(paymentUrl: esewaUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Purchase Tickets")),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _EventSummaryCard(event: widget.event),
                    const SizedBox(height: 24),
                    Text("Select Ticket Tier", style: AppTextStyles.heading3),
                    const SizedBox(height: 16),
                    DropdownButton<TicketTier>(
                      value: _selectedTier,
                      isExpanded: true,
                      items: widget.event.ticketTiers.map((tier) {
                        return DropdownMenuItem(
                          value: tier,
                          child: Text(
                            "${tier.label} - ${tier.price.toStringAsFixed(2)} ${tier.currency}",
                          ),
                        );
                      }).toList(),
                      onChanged: (tier) {
                        setState(() => _selectedTier = tier!);
                      },
                    ),
                    const SizedBox(height: 24),
                    Text("Ticket Quantity", style: AppTextStyles.heading3),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: _ticketCount > 1
                              ? () => setState(() => _ticketCount--)
                              : null,
                          color: AppColors.primary,
                        ),
                        Text("$_ticketCount", style: AppTextStyles.heading3),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => setState(() => _ticketCount++),
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _PriceBreakdown(
                      ticketPrice: _selectedTier.price,
                      ticketCount: _ticketCount,
                      totalPrice: _totalPrice,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: PrimaryButton(
                label: "Pay with eSewa",
                onPressed: _payWithESewa,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------- Event Summary Card ----------------------
class _EventSummaryCard extends StatelessWidget {
  final EventModel event;

  const _EventSummaryCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 18),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              event.imageUrlOrPlaceholder,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          Text(event.title, style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_month, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Text("${_formatDate(event.dateTime)} • ${event.timeLabel}",
                  style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.place, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(event.locationName, style: AppTextStyles.caption),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return "${months[date.month-1]} ${date.day}, ${date.year}";
  }
}

// ---------------------- Price Breakdown ----------------------
class _PriceBreakdown extends StatelessWidget {
  final double ticketPrice;
  final int ticketCount;
  final double totalPrice;

  const _PriceBreakdown({
    required this.ticketPrice,
    required this.ticketCount,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Ticket Price"),
              Text("\$${ticketPrice.toStringAsFixed(2)}"),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Quantity"),
              Text("x$ticketCount"),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                "\$${totalPrice.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------- eSewa WebView ----------------------
class ESewaWebViewPage extends StatefulWidget {
  final String paymentUrl;

  const ESewaWebViewPage({super.key, required this.paymentUrl});

  @override
  State<ESewaWebViewPage> createState() => _ESewaWebViewPageState();
}

class _ESewaWebViewPageState extends State<ESewaWebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (nav) {
            if (nav.url.contains("success")) {
              Navigator.pop(context); // Payment success
            } else if (nav.url.contains("failure")) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Payment failed")),
              );
              Navigator.pop(context);
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("eSewa Payment")),
      body: WebViewWidget(controller: _controller),
    );
  }
}
