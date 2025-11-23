import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../widgets/primary_button.dart';

class RewardsDashboardPage extends StatelessWidget {
  const RewardsDashboardPage({super.key});

  static const String routeName = '/rewards-dashboard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Rewards Dashboard'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BalanceCard(
                balance: 2450,
                pointsEarnedThisMonth: 320,
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
                description: 'Earn 10 points for every dollar spent',
                points: '+10/\$',
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
              SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    _PartnerCard(
                      name: 'Coffee Shop',
                      discount: '20% OFF',
                      pointsRequired: 500,
                      imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4c7c98?w=400',
                    ),
                    SizedBox(width: 16),
                    _PartnerCard(
                      name: 'Restaurant',
                      discount: '15% OFF',
                      pointsRequired: 400,
                      imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400',
                    ),
                    SizedBox(width: 16),
                    _PartnerCard(
                      name: 'Cinema',
                      discount: 'Free Ticket',
                      pointsRequired: 300,
                      imageUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=400',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Recent Activity',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 16),
              _ActivityItem(
                icon: Icons.add_circle,
                title: 'Points Earned',
                description: 'Attended Tech Meetup',
                points: '+50',
                date: '2 days ago',
                isEarned: true,
              ),
              const SizedBox(height: 12),
              _ActivityItem(
                icon: Icons.remove_circle,
                title: 'Points Redeemed',
                description: 'Coffee Shop Discount',
                points: '-500',
                date: '5 days ago',
                isEarned: false,
              ),
              const SizedBox(height: 12),
              _ActivityItem(
                icon: Icons.add_circle,
                title: 'Points Earned',
                description: 'Bought Event Tickets',
                points: '+250',
                date: '1 week ago',
                isEarned: true,
              ),
            ],
          ),
        ),
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
  final String name;
  final String discount;
  final int pointsRequired;
  final String imageUrl;

  const _PartnerCard({
    required this.name,
    required this.discount,
    required this.pointsRequired,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/partner-detail', arguments: {
          'name': name,
          'discount': discount,
          'pointsRequired': pointsRequired,
        });
      },
      child: Container(
        width: 180,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                imageUrl,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    discount,
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.stars, size: 16, color: AppColors.accentYellow),
                      const SizedBox(width: 4),
                      Text(
                        '$pointsRequired pts',
                        style: AppTextStyles.caption,
                      ),
                    ],
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

