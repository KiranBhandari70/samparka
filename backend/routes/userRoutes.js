import express from 'express';
import {
  getProfile,
  updateProfile,
  uploadAvatar,
  updateInterests,
  getUserEvents,
} from '../controllers/userController.js';
import { authenticate } from '../middleware/auth.js';
import { upload } from '../middleware/upload.js';

const router = express.Router();

// User profile routes (requires authentication)
router.get('/profile', authenticate, getProfile);
router.put('/profile', authenticate, updateProfile);
router.post('/avatar', authenticate, upload.single('avatar'), uploadAvatar);
router.put('/interests', authenticate, updateInterests);

export default router;

