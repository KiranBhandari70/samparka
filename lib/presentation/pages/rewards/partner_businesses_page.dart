import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../provider/offer_provider.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/reward_provider.dart';
import '../../../data/models/offer_model.dart';
import '../../widgets/primary_button.dart';

class PartnerBusinessesPage extends StatefulWidget {
  const PartnerBusinessesPage({super.key});

  static const String routeName = '/partner-businesses';

  @override
  State<PartnerBusinessesPage> createState() => _PartnerBusinessesPageState();
}

class _PartnerBusinessesPageState extends State<PartnerBusinessesPage> {
  String _selectedCategory = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final offerProvider = Provider.of<OfferProvider>(context, listen: false);
    await Future.wait([
      offerProvider.loadOffers(refresh: true),
      offerProvider.loadCategories(),
    ]);
  }

  Future<void> _refreshData() async {
    final offerProvider = Provider.of<OfferProvider>(context, listen: false);
    await offerProvider.loadOffers(refresh: true);
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
    final offerProvider = Provider.of<OfferProvider>(context, listen: false);
    offerProvider.loadOffers(category: category == 'all' ? null : category, refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Partner Businesses'),
      ),
      body: Consumer<OfferProvider>(
        builder: (context, offerProvider, child) {
          if (offerProvider.isLoading && offerProvider.allOffers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (offerProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading offers',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    offerProvider.error!,
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: Column(
              children: [
                // Search field
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search offers...',
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

                // Category filter
                if (offerProvider.categories.isNotEmpty) _buildCategoryFilter(offerProvider),

                // Offers list
                Expanded(
                  child: offerProvider.availableOffers.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: offerProvider.availableOffers.length,
                          itemBuilder: (context, index) {
                            final offer = offerProvider.availableOffers[index];
                            return Column(
                              children: [
                                _OfferCard(offer: offer),
                                const SizedBox(height: 16),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilter(OfferProvider offerProvider) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: offerProvider.categories.length + 1, // +1 for "All"
        itemBuilder: (context, index) {
          if (index == 0) {
            return _CategoryChip(
              label: 'All',
              isSelected: _selectedCategory == 'all',
              onTap: () => _filterByCategory('all'),
            );
          }
          
          final category = offerProvider.categories[index - 1];
          return _CategoryChip(
            label: category.label,
            isSelected: _selectedCategory == category.value,
            onTap: () => _filterByCategory(category.value),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 64,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'No offers available',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new discount offers!',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.textMuted.withOpacity(0.3),
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final OfferModel offer;

  const _OfferCard({required this.offer});

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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Image.network(
              offer.imageUrlOrPlaceholder,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 160,
                  color: AppColors.background,
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: AppColors.textMuted,
                  ),
                );
              },
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
                          Text(offer.businessName, style: AppTextStyles.heading3),
                          const SizedBox(height: 4),
                          Text(offer.categoryLabel, style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        offer.discountText,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(offer.title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(offer.description, style: AppTextStyles.body),
                const SizedBox(height: 12),
                Text(offer.validityText, style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.stars, size: 20, color: AppColors.accentYellow),
                    const SizedBox(width: 8),
                    Text(
                      '${offer.pointsRequired} points required',
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return Consumer<RewardProvider>(
                      builder: (context, rewardProvider, child) {
                        final canAfford = rewardProvider.currentBalance >= offer.pointsRequired;
                        
                        return PrimaryButton(
                          label: canAfford ? 'Redeem Now' : 'Insufficient Points',
                          onPressed: canAfford ? () => _redeemOffer(context, offer, authProvider.currentUserId!) : null,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _redeemOffer(BuildContext context, OfferModel offer, String userId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Redeem Offer'),
        content: Text(
          'Are you sure you want to redeem "${offer.title}" for ${offer.pointsRequired} points?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Redeem'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final offerProvider = Provider.of<OfferProvider>(context, listen: false);
      final rewardProvider = Provider.of<RewardProvider>(context, listen: false);
      
      final result = await offerProvider.redeemOffer(offer.id, userId);
      
      // Close loading dialog
      if (context.mounted) Navigator.of(context).pop();

      if (result != null) {
        // Refresh reward data
        await rewardProvider.loadRewardDashboard(userId);
        
        // Show success dialog with redemption code
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Offer Redeemed!'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Successfully redeemed ${result.offer.discountText} at ${result.offer.businessName}'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Redemption Code:', style: AppTextStyles.caption),
                        const SizedBox(height: 4),
                        Text(
                          result.redemptionCode,
                          style: AppTextStyles.heading3.copyWith(
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Show this code to the business to claim your discount.'),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) Navigator.of(context).pop();
      
      // Show error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to redeem offer: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    }
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
