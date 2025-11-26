import RewardService from '../services/rewardService.js';
import User from '../models/User.js';

// Get user's reward dashboard data
export const getRewardDashboard = async (req, res) => {
  try {
    const { userId } = req.params;

    if (!userId) {
      return res.status(400).json({ success: false, message: 'User ID is required' });
    }

    // Get reward statistics
    const stats = await RewardService.getUserRewardStats(userId);
    
    // Get recent reward history (last 10 transactions)
    const recentActivity = await RewardService.getUserRewardHistory(userId, 10, 0);

    return res.status(200).json({
      success: true,
      data: {
        balance: stats.currentBalance,
        monthlyEarned: stats.monthlyEarned,
        totalEarned: stats.totalEarned,
        totalRedeemed: stats.totalRedeemed,
        recentActivity,
      },
    });
  } catch (error) {
    console.error('getRewardDashboard error:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message,
    });
  }
};

// Get user's complete reward history with pagination
export const getRewardHistory = async (req, res) => {
  try {
    const { userId } = req.params;
    const { limit = 20, offset = 0 } = req.query;

    if (!userId) {
      return res.status(400).json({ success: false, message: 'User ID is required' });
    }

    const transactions = await RewardService.getUserRewardHistory(
      userId,
      parseInt(limit),
      parseInt(offset)
    );

    return res.status(200).json({
      success: true,
      data: transactions,
    });
  } catch (error) {
    console.error('getRewardHistory error:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message,
    });
  }
};

// Admin endpoint to add reward points manually
export const addRewardPoints = async (req, res) => {
  try {
    const { userId, amount, description } = req.body;

    if (!userId || !amount || !description) {
      return res.status(400).json({
        success: false,
        message: 'User ID, amount, and description are required',
      });
    }

    if (amount <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Amount must be positive',
      });
    }

    const result = await RewardService.addRewardPoints(
      userId,
      amount,
      'admin_adjustment',
      description,
      { adminNote: 'Manual adjustment by admin' }
    );

    return res.status(200).json({
      success: true,
      message: 'Reward points added successfully',
      data: {
        newBalance: result.newBalance,
        transaction: result.transaction,
      },
    });
  } catch (error) {
    console.error('addRewardPoints error:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message,
    });
  }
};

// Redeem reward points (for partner offers)
export const redeemRewardPoints = async (req, res) => {
  try {
    const { userId, amount, partnerName, offerDescription } = req.body;

    if (!userId || !amount || !partnerName || !offerDescription) {
      return res.status(400).json({
        success: false,
        message: 'All fields are required',
      });
    }

    if (amount <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Amount must be positive',
      });
    }

    const result = await RewardService.deductRewardPoints(
      userId,
      amount,
      'partner_redemption',
      `Redeemed ${amount} points for ${offerDescription} at ${partnerName}`,
      { partnerName, offerDescription }
    );

    return res.status(200).json({
      success: true,
      message: 'Reward points redeemed successfully',
      data: {
        newBalance: result.newBalance,
        transaction: result.transaction,
      },
    });
  } catch (error) {
    console.error('redeemRewardPoints error:', error);
    
    if (error.message === 'Insufficient reward balance') {
      return res.status(400).json({
        success: false,
        message: 'Insufficient reward balance',
      });
    }

    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message,
    });
  }
};
