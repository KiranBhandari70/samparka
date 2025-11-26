// lib/pages/ticket_purchase_page.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:esewa_flutter/esewa_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../core/constants/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/models/event_model.dart';
import '../../../config/environment.dart';
import '../../../data/services/reward_service.dart';

class TicketPurchasePage extends StatefulWidget {
  final EventModel event;
  final String userId; // Logged-in user ID

  const TicketPurchasePage({super.key, required this.event, required this.userId});

  static const String routeName = '/ticket-purchase';

  @override
  State<TicketPurchasePage> createState() => _TicketPurchasePageState();
}

class _TicketPurchasePageState extends State<TicketPurchasePage> {
  int _ticketCount = 1;
  late TicketTier _selectedTier;

  String paymentData = '';
  String paymentError = '';
  bool isSaving = false;
  late String _pid;

  @override
  void initState() {
    super.initState();
    _selectedTier = widget.event.ticketTiers.isNotEmpty
        ? widget.event.ticketTiers[0]
        : const TicketTier(label: "Standard", price: 0.0);
    _generatePid();
  }

  void _generatePid() {
    _pid = "PID${DateTime.now().millisecondsSinceEpoch}";
  }

  double get _totalPrice => _selectedTier.price * _ticketCount;
  int get _rewardPoints => RewardService.calculateRewardPoints(_totalPrice);

  /// Save payment to backend
  Future<void> _savePaymentToBackend(String referenceId) async {
    final url = Uri.parse('${Environment.apiBaseUrl}/api/v1/esewa/create');
    final body = jsonEncode({
      'userId': widget.userId,
      'eventId': widget.event.id,
      'amount': _totalPrice,
      'refId': referenceId,
      'pid': _pid,
      'ticketCount': _ticketCount,
      'tierLabel': _selectedTier.label,
    });

    try {
      if (kDebugMode) print('Sending payment request: $body');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (kDebugMode) print('Payment response status: ${response.statusCode}');
      if (kDebugMode) print('Payment response body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          if (kDebugMode) print('Payment saved successfully');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Ticket purchased successfully!"),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          if (kDebugMode) print('Payment verification failed: ${responseData['verificationError']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Payment verification failed: ${responseData['verificationError'] ?? 'Unknown error'}"),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        if (kDebugMode) print('Failed to save payment: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save ticket: ${errorData['message'] ?? 'Unknown error'}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) print('Error saving payment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error connecting to backend: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Payment callbacks
  void _onPaymentSuccess(EsewaPaymentResponse response) async {
    final referenceId = response.data; // Transaction reference ID
    setState(() {
      paymentData = referenceId ?? '';
      paymentError = '';
      isSaving = true;
    });

    if (referenceId != null && referenceId.isNotEmpty) {
      await _savePaymentToBackend(referenceId);
    }

    setState(() => isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment Successful")),
    );

    _generatePid(); // regenerate pid for next purchase
  }

  void _onPaymentFailure(String errorMessage) {
    setState(() {
      paymentError = errorMessage;
      paymentData = '';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: $errorMessage")),
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
                            "${tier.label} - NPR ${tier.price.toStringAsFixed(2)}",
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
                      rewardPoints: _rewardPoints,
                    ),
                    const SizedBox(height: 24),
                    if (paymentData.isNotEmpty)
                      Text("Payment Reference: $paymentData",
                          style: const TextStyle(color: Colors.green)),
                    if (paymentError.isNotEmpty)
                      Text("Payment Error: $paymentError",
                          style: const TextStyle(color: Colors.red)),
                    if (isSaving)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Center(child: CircularProgressIndicator()),
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
              child: Column(
                children: [
                  Text("PID: $_pid", style: AppTextStyles.caption),
                  const SizedBox(height: 8),
                  EsewaPayButton(
                    paymentConfig: ESewaConfig.dev(
                      amount: _totalPrice,
                      productCode: "EPAYTEST",
                      successUrl: 'https://uat.esewa.com.np/mobile/success',
                      failureUrl: 'https://uat.esewa.com.np/mobile/failure',
                      secretKey: '8gBm/:&EnhH.1/q',
                      transactionUuid: _pid,
                    ),
                    width: double.infinity,
                    onSuccess: _onPaymentSuccess,
                    onFailure: _onPaymentFailure,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Event Summary Card ----------------
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

// ---------------- Price Breakdown ----------------
class _PriceBreakdown extends StatelessWidget {
  final double ticketPrice;
  final int ticketCount;
  final double totalPrice;
  final int rewardPoints;

  const _PriceBreakdown({
    required this.ticketPrice,
    required this.ticketCount,
    required this.totalPrice,
    required this.rewardPoints,
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
              Text("\NRs.${ticketPrice.toStringAsFixed(2)}"),
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
                "NPR ${totalPrice.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (rewardPoints > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.stars,
                        color: AppColors.accentGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "You'll earn",
                        style: TextStyle(
                          color: AppColors.accentGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "$rewardPoints points",
                    style: TextStyle(
                      color: AppColors.accentGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
