import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../widgets/primary_button.dart';

class PartnerBusinessesPage extends StatelessWidget {
  const PartnerBusinessesPage({super.key});

  static const String routeName = '/partner-businesses';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Partner Businesses'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search field
            Padding(
              padding: const EdgeInsets.all(24),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search businesses...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Businesses list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: 0, // Replace with your dynamic data length
                itemBuilder: (context, index) {
                  // Replace with your dynamic data
                  final business = null; // Your business model

                  return Column(
                    children: [
                      _PartnerBusinessCard(
                        name: business?.name ?? '',
                        category: business?.category ?? '',
                        discount: business?.discount ?? '',
                        pointsRequired: business?.pointsRequired ?? 0,
                        description: business?.description ?? '',
                        imageUrl: business?.imageUrl ?? '',
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PartnerBusinessCard extends StatelessWidget {
  final String name;
  final String category;
  final String discount;
  final int pointsRequired;
  final String description;
  final String imageUrl;

  const _PartnerBusinessCard({
    required this.name,
    required this.category,
    required this.discount,
    required this.pointsRequired,
    required this.description,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Image.network(
                imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: AppTextStyles.heading3),
                          const SizedBox(height: 4),
                          Text(category, style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    if (discount.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          discount,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (description.isNotEmpty) Text(description, style: AppTextStyles.body),
                const SizedBox(height: 16),
                if (pointsRequired > 0)
                  Row(
                    children: [
                      Icon(Icons.stars, size: 20, color: AppColors.accentYellow),
                      const SizedBox(width: 8),
                      Text(
                        '$pointsRequired points required',
                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Redeem Now',
                  onPressed: () {
                    // Implement redemption logic here
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
