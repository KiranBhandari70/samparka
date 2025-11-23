import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/models/event_model.dart';
import '../../widgets/primary_button.dart';

class TicketPurchasePage extends StatefulWidget {
  final EventModel event;
  final double ticketPrice;

  const TicketPurchasePage({
    super.key,
    required this.event,
    this.ticketPrice = 25.00,
  });

  static const String routeName = '/ticket-purchase';

  @override
  State<TicketPurchasePage> createState() => _TicketPurchasePageState();
}

class _TicketPurchasePageState extends State<TicketPurchasePage> {
  int _ticketCount = 1;
  String _selectedPaymentMethod = 'card';
  final _cardNumberController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  double get _totalPrice => widget.ticketPrice * _ticketCount;
  double get _rewardPointsEarned => _totalPrice * 10; // 10 points per dollar

  void _processPayment() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment successful! You earned ${_rewardPointsEarned.toInt()} reward points.'),
        backgroundColor: AppColors.accentGreen,
      ),
    );
    Navigator.of(context).pop();
    Navigator.of(context).pop(); // Go back to event detail
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Purchase Tickets'),
      ),
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
                    Text(
                      'Ticket Quantity',
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Number of Tickets',
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: _ticketCount > 1
                                    ? () => setState(() => _ticketCount--)
                                    : null,
                                color: AppColors.primary,
                              ),
                              Text(
                                '$_ticketCount',
                                style: AppTextStyles.heading3,
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => setState(() => _ticketCount++),
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Payment Method',
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: 16),
                    _PaymentMethodOption(
                      value: 'card',
                      label: 'Credit/Debit Card',
                      icon: Icons.credit_card,
                      isSelected: _selectedPaymentMethod == 'card',
                      onTap: () => setState(() => _selectedPaymentMethod = 'card'),
                    ),
                    const SizedBox(height: 12),
                    _PaymentMethodOption(
                      value: 'wallet',
                      label: 'Reward Points',
                      icon: Icons.account_balance_wallet,
                      isSelected: _selectedPaymentMethod == 'wallet',
                      onTap: () => setState(() => _selectedPaymentMethod = 'wallet'),
                    ),
                    if (_selectedPaymentMethod == 'card') ...[
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _cardNumberController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Card Number',
                          hintText: '1234 5678 9012 3456',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _cardNameController,
                        decoration: const InputDecoration(
                          labelText: 'Cardholder Name',
                          hintText: 'John Doe',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _expiryController,
                              decoration: const InputDecoration(
                                labelText: 'Expiry Date',
                                hintText: 'MM/YY',
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _cvvController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'CVV',
                                hintText: '123',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (_selectedPaymentMethod == 'wallet') ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Available Points',
                                  style: AppTextStyles.body,
                                ),
                                Text(
                                  '2,450',
                                  style: AppTextStyles.heading3.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Points Required',
                                  style: AppTextStyles.body,
                                ),
                                Text(
                                  '${(_totalPrice * 100).toInt()}',
                                  style: AppTextStyles.heading3,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    _PriceBreakdown(
                      ticketPrice: widget.ticketPrice,
                      ticketCount: _ticketCount,
                      totalPrice: _totalPrice,
                      rewardPointsEarned: _rewardPointsEarned,
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: AppTextStyles.heading3,
                      ),
                      Text(
                        '\$${_totalPrice.toStringAsFixed(2)}',
                        style: AppTextStyles.heading2.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Complete Purchase',
                    onPressed: _processPayment,
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
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
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
          Text(
            event.title,
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_month, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Text(
                '${_formatDate(event.dateTime)} • ${event.timeLabel}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.place, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  event.locationName,
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _PaymentMethodOption extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodOption({
    required this.value,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textMuted),
            const SizedBox(width: 16),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _PriceBreakdown extends StatelessWidget {
  final double ticketPrice;
  final int ticketCount;
  final double totalPrice;
  final double rewardPointsEarned;

  const _PriceBreakdown({
    required this.ticketPrice,
    required this.ticketCount,
    required this.totalPrice,
    required this.rewardPointsEarned,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Breakdown',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ticket Price',
                style: AppTextStyles.body,
              ),
              Text(
                '\$${ticketPrice.toStringAsFixed(2)}',
                style: AppTextStyles.body,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quantity',
                style: AppTextStyles.body,
              ),
              Text(
                'x$ticketCount',
                style: AppTextStyles.body,
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppTextStyles.heading3,
              ),
              Text(
                '\$${totalPrice.toStringAsFixed(2)}',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accentYellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.stars, color: AppColors.accentYellow, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You will earn ${rewardPointsEarned.toInt()} reward points',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

