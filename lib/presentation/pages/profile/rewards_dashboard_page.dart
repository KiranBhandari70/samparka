import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/reward_provider.dart';
import '../../../provider/offer_provider.dart';
import '../../../data/models/reward_transaction_model.dart';
import '../../../data/models/offer_model.dart';
import '../../widgets/primary_button.dart';

class RewardsDashboardPage extends StatefulWidget {
  const RewardsDashboardPage({super.key});

  static const String routeName = '/rewards-dashboard';

  @override
  State<RewardsDashboardPage> createState() => _RewardsDashboardPageState();
}

class _RewardsDashboardPageState extends State<RewardsDashboardPage> {
  @override
  void initState() {
    super.initState();
    _loadRewardData();
  }

  Future<void> _loadRewardData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final rewardProvider = Provider.of<RewardProvider>(context, listen: false);
    final offerProvider = Provider.of<OfferProvider>(context, listen: false);
    
    final userId = authProvider.currentUserId;
    if (userId != null && userId.isNotEmpty) {
      await Future.wait([
        rewardProvider.loadRewardDashboard(userId),
        offerProvider.loadOffers(refresh: true),
      ]);
    }
  }

  Future<void> _refreshData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final rewardProvider = Provider.of<RewardProvider>(context, listen: false);
    final offerProvider = Provider.of<OfferProvider>(context, listen: false);
    
    final userId = authProvider.currentUserId;
    if (userId != null && userId.isNotEmpty) {
      await Future.wait([
        rewardProvider.refreshData(userId),
        offerProvider.loadOffers(refresh: true),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Rewards Dashboard'),
      ),
      body: Consumer<RewardProvider>(
        builder: (context, rewardProvider, child) {
          if (rewardProvider.isLoading && rewardProvider.dashboardData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (rewardProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading rewards data',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    rewardProvider.error!,
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadRewardData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BalanceCard(
                    balance: rewardProvider.currentBalance,
                    pointsEarnedThisMonth: rewardProvider.monthlyEarned,
                  ),
              const SizedBox(height: 24),
              Text(
                'How to Earn Points',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 16),
              _EarningMethodCard(
                icon: Icons.event,
                title: 'Attend Events',
                description: 'Earn 50 points for each event you attend',
                points: '+50',
              ),
              const SizedBox(height: 12),
              _EarningMethodCard(
                icon: Icons.shopping_bag,
                title: 'Buy Tickets',
                description: 'Earn 0.5% points for every NPR spent',
                points: '+0.5%',
              ),
              const SizedBox(height: 12),
              _EarningMethodCard(
                icon: Icons.star,
                title: 'Host Events',
                description: 'Earn 200 points for hosting a successful event',
                points: '+200',
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Redeem Points',
                    style: AppTextStyles.heading3,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/partner-businesses');
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Consumer<OfferProvider>(
                builder: (context, offerProvider, child) {
                  final availableOffers = offerProvider.availableOffers.take(5).toList();
                  
                  if (availableOffers.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.local_offer_outlined,
                              size: 48,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No offers available',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Check back later for new discount offers!',
                              style: AppTextStyles.caption,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  return SizedBox(
                    height: 240,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: availableOffers.length,
                      itemBuilder: (context, index) {
                        final offer = availableOffers[index];
                        return Padding(
                          padding: EdgeInsets.only(right: index < availableOffers.length - 1 ? 16 : 0),
                          child: _PartnerCard(
                            offer: offer,
                            currentBalance: rewardProvider.currentBalance,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Recent Activity',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 16),
              if (rewardProvider.recentActivity.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.history,
                          size: 48,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No recent activity',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start earning points by purchasing event tickets!',
                          style: AppTextStyles.caption,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...rewardProvider.recentActivity.map((transaction) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ActivityItem(
                    icon: transaction.isEarned ? Icons.add_circle : Icons.remove_circle,
                    title: transaction.displayTitle,
                    description: transaction.description,
                    points: transaction.formattedAmount,
                    date: transaction.timeAgo,
                    isEarned: transaction.isEarned,
                  ),
                )).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final int balance;
  final int pointsEarnedThisMonth;

  const _BalanceCard({
    required this.balance,
    required this.pointsEarnedThisMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB347), Color(0xFFFF7A00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Balance',
            style: AppTextStyles.body.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$balance',
            style: AppTextStyles.heading1.copyWith(
              color: Colors.white,
              fontSize: 42,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Reward Points',
            style: AppTextStyles.body.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This Month',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+$pointsEarnedThisMonth',
                      style: AppTextStyles.heading3.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: 32,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EarningMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String points;

  const _EarningMethodCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              points,
              style: AppTextStyles.body.copyWith(
                color: AppColors.accentGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PartnerCard extends StatelessWidget {
  final OfferModel offer;
  final int currentBalance;

  const _PartnerCard({
    required this.offer,
    required this.currentBalance,
  });

  @override
  Widget build(BuildContext context) {
    final canAfford = currentBalance >= offer.pointsRequired;
    
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/partner-businesses');
      },
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                offer.imageUrlOrPlaceholder,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    color: AppColors.background,
                    child: Icon(
                      Icons.image_not_supported,
                      color: AppColors.textMuted,
                      size: 32,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.businessName,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    offer.discountText,
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.primary,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.stars_rounded,
                        size: 16,
                        color: canAfford ? AppColors.accentYellow : AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${offer.pointsRequired} pts',
                          style: AppTextStyles.caption.copyWith(
                            color: canAfford ? AppColors.textSecondary : AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!canAfford) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accentRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Need ${offer.pointsRequired - currentBalance} more',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.accentRed,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String points;
  final String date;
  final bool isEarned;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.points,
    required this.date,
    required this.isEarned,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isEarned ? AppColors.accentGreen : AppColors.accentRed)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isEarned ? AppColors.accentGreen : AppColors.accentRed,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            points,
            style: AppTextStyles.heading3.copyWith(
              color: isEarned ? AppColors.accentGreen : AppColors.accentRed,
            ),
          ),
        ],
      ),
    );
  }
}

