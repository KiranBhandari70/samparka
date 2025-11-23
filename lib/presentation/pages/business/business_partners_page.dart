import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../widgets/primary_button.dart';

class BusinessPartnersPage extends StatelessWidget {
  const BusinessPartnersPage({super.key});

  static const String routeName = '/business-partners';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Discount Offers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed('/add-discount-offer');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: const [
            _DiscountOfferCard(
              title: '20% OFF on Coffee',
              description: 'Valid for all coffee and pastries',
              pointsRequired: 500,
              status: 'Active',
            ),
            SizedBox(height: 16),
            _DiscountOfferCard(
              title: '15% OFF on Meals',
              description: 'Valid for lunch and dinner',
              pointsRequired: 400,
              status: 'Active',
            ),
            SizedBox(height: 16),
            _DiscountOfferCard(
              title: 'Free Dessert',
              description: 'Get a free dessert with any meal',
              pointsRequired: 300,
              status: 'Inactive',
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscountOfferCard extends StatelessWidget {
  final String title;
  final String description;
  final int pointsRequired;
  final String status;

  const _DiscountOfferCard({
    required this.title,
    required this.description,
    required this.pointsRequired,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'Active';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isActive
            ? Border.all(color: AppColors.accentGreen, width: 2)
            : null,
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.heading3,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.accentGreen.withOpacity(0.1)
                      : AppColors.textMuted.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: AppTextStyles.caption.copyWith(
                    color: isActive ? AppColors.accentGreen : AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.stars, size: 20, color: AppColors.accentYellow),
              const SizedBox(width: 8),
              Text(
                '$pointsRequired points required',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Edit offer
                  },
                  child: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Toggle status
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isActive ? AppColors.accentRed : AppColors.accentGreen,
                  ),
                  child: Text(isActive ? 'Deactivate' : 'Activate'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

