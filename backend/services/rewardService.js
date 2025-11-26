import User from '../models/User.js';
import RewardTransaction from '../models/RewardTransaction.js';

class RewardService {
  // Calculate reward points for ticket purchase (0.5% of total cost)
  static calculateTicketRewardPoints(ticketAmount) {
    return Math.floor(ticketAmount * 0.005); // 0.5% rounded down
  }

  // Add reward points to user and create transaction record
  static async addRewardPoints(userId, amount, source, description, metadata = {}) {
    try {
      // Start a transaction to ensure data consistency
      const session = await User.startSession();
      
      let result;
      await session.withTransaction(async () => {
        // Update user's reward balance
        const user = await User.findByIdAndUpdate(
          userId,
          { $inc: { rewardBalance: amount } },
          { new: true, session }
        );

        if (!user) {
          throw new Error('User not found');
        }

        // Create reward transaction record
        const transaction = await RewardTransaction.create([{
          userId,
          type: 'earned',
          source,
          amount,
          description,
          metadata,
        }], { session });

        result = {
          user,
          transaction: transaction[0],
          newBalance: user.rewardBalance,
        };
      });

      await session.endSession();
      return result;
    } catch (error) {
      console.error('Error adding reward points:', error);
      throw error;
    }
  }

  // Deduct reward points from user (for redemptions)
  static async deductRewardPoints(userId, amount, source, description, metadata = {}) {
    try {
      const session = await User.startSession();
      
      let result;
      await session.withTransaction(async () => {
        // Check if user has sufficient balance
        const user = await User.findById(userId).session(session);
        if (!user) {
          throw new Error('User not found');
        }

        if (user.rewardBalance < amount) {
          throw new Error('Insufficient reward balance');
        }

        // Update user's reward balance
        const updatedUser = await User.findByIdAndUpdate(
          userId,
          { $inc: { rewardBalance: -amount } },
          { new: true, session }
        );

        // Create reward transaction record
        const transaction = await RewardTransaction.create([{
          userId,
          type: 'redeemed',
          source,
          amount,
          description,
          metadata,
        }], { session });

        result = {
          user: updatedUser,
          transaction: transaction[0],
          newBalance: updatedUser.rewardBalance,
        };
      });

      await session.endSession();
      return result;
    } catch (error) {
      console.error('Error deducting reward points:', error);
      throw error;
    }
  }

  // Get user's reward transaction history
  static async getUserRewardHistory(userId, limit = 20, offset = 0) {
    try {
      const transactions = await RewardTransaction.find({ userId })
        .populate('relatedEventId', 'title imageUrl')
        .sort({ createdAt: -1 })
        .limit(limit)
        .skip(offset);

      return transactions;
    } catch (error) {
      console.error('Error fetching reward history:', error);
      throw error;
    }
  }

  // Get user's reward statistics
  static async getUserRewardStats(userId) {
    try {
      const user = await User.findById(userId);
      if (!user) {
        throw new Error('User not found');
      }

      // Get current month's earned points
      const startOfMonth = new Date();
      startOfMonth.setDate(1);
      startOfMonth.setHours(0, 0, 0, 0);

      const monthlyEarned = await RewardTransaction.aggregate([
        {
          $match: {
            userId: user._id,
            type: 'earned',
            createdAt: { $gte: startOfMonth },
          },
        },
        {
          $group: {
            _id: null,
            total: { $sum: '$amount' },
          },
        },
      ]);

      // Get total earned and redeemed points
      const totalStats = await RewardTransaction.aggregate([
        {
          $match: { userId: user._id },
        },
        {
          $group: {
            _id: '$type',
            total: { $sum: '$amount' },
          },
        },
      ]);

      const totalEarned = totalStats.find(stat => stat._id === 'earned')?.total || 0;
      const totalRedeemed = totalStats.find(stat => stat._id === 'redeemed')?.total || 0;

      return {
        currentBalance: user.rewardBalance,
        monthlyEarned: monthlyEarned[0]?.total || 0,
        totalEarned,
        totalRedeemed,
      };
    } catch (error) {
      console.error('Error fetching reward stats:', error);
      throw error;
    }
  }
}

export default RewardService;
