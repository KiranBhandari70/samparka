import express from 'express';
import mongoose from 'mongoose';
import { getUserEvents } from '../controllers/userController.js';

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

export default router;
