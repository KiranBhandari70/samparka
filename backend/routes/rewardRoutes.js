import express from 'express';
import {
  getRewardDashboard,
  getRewardHistory,
  addRewardPoints,
  redeemRewardPoints,
} from '../controllers/rewardController.js';

const router = express.Router();

// Get reward dashboard data for a user
router.get('/dashboard/:userId', getRewardDashboard);

// Get reward history for a user
router.get('/history/:userId', getRewardHistory);

// Admin: Add reward points manually
router.post('/add', addRewardPoints);

// Redeem reward points
router.post('/redeem', redeemRewardPoints);

export default router;
