import express from 'express';
import mongoose from 'mongoose';

import {
  getProfile,
  updateProfile,
  uploadAvatar,
  updateInterests,
  getUserEvents,
  getRegisteredUsers,
} from '../controllers/userController.js';
import { authenticate } from '../middleware/auth.js';
import { upload } from '../middleware/upload.js';

const router = express.Router();
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

export default router;

