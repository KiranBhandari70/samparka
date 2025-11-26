import express from 'express';
import mongoose from 'mongoose';

import {
  getProfile,
  updateProfile,
  uploadAvatar,
  updateInterests,
  getUserEvents,
  getRegisteredUsers,
  getAllUsersAdmin,
  setUserBlockedStatus,
} from '../controllers/userController.js';
import { authenticate, authorize } from '../middleware/auth.js';
import { upload } from '../middleware/upload.js';

const router = express.Router();

// PUBLIC / USER-SCOPED ROUTES
router.get('/:userId/events', async (req, res, next) => {
  const { userId } = req.params;

  // Validate MongoDB ObjectId
  if (!mongoose.Types.ObjectId.isValid(userId)) {
    return res.status(400).json({ message: 'Invalid user ID' });
  }

  try {
    await getUserEvents(req, res);
  } catch (error) {
    next(error);
  }
});

// User profile routes (requires authentication)
router.get('/profile', authenticate, getProfile);
router.put('/profile', authenticate, updateProfile);
router.post('/avatar', authenticate, upload.single('avatar'), uploadAvatar);
router.put('/interests', authenticate, updateInterests);
router.get('/registered', getRegisteredUsers);

// ADMIN ROUTES
router.get('/admin', authenticate, authorize('admin'), getAllUsersAdmin);
router.patch('/admin/:userId/block', authenticate, authorize('admin'), setUserBlockedStatus);

export default router;

