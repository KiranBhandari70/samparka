import express from 'express';
import { getUserEvents } from '../controllers/userController.js';

const router = express.Router();

// Public route for user events
router.get('/:userId/events', getUserEvents);

export default router;

