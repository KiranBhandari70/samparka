import express from 'express';
import Event from '../models/Event.js';
import Group from '../models/Group.js';
import User from '../models/User.js';

const router = express.Router();

// @desc    Search events
// @route   GET /api/v1/search/events
// @access  Public
router.get('/events', async (req, res, next) => {
  try {
    const { q, limit = 20, offset = 0 } = req.query;

    if (!q) {
      return res.status(400).json({ message: 'Search query is required' });
    }

    const events = await Event.find({ $text: { $search: q } })
      .populate('createdBy', 'name email avatarUrl')
      .limit(parseInt(limit))
      .skip(parseInt(offset));

    res.json({
      success: true,
      events,
    });
  } catch (error) {
    next(error);
  }
});

// @desc    Search groups
// @route   GET /api/v1/search/groups
// @access  Public
router.get('/groups', async (req, res, next) => {
  try {
    const { q, limit = 20, offset = 0 } = req.query;

    if (!q) {
      return res.status(400).json({ message: 'Search query is required' });
    }

    const groups = await Group.find({ $text: { $search: q } })
      .populate('createdBy', 'name email avatarUrl')
      .limit(parseInt(limit))
      .skip(parseInt(offset));

    res.json({
      success: true,
      groups,
    });
  } catch (error) {
    next(error);
  }
});

// @desc    Search users
// @route   GET /api/v1/search/users
// @access  Public
router.get('/users', async (req, res, next) => {
  try {
    const { q, limit = 20, offset = 0 } = req.query;

    if (!q) {
      return res.status(400).json({ message: 'Search query is required' });
    }

    const users = await User.find({
      $or: [
        { name: { $regex: q, $options: 'i' } },
        { email: { $regex: q, $options: 'i' } },
      ],
      blocked: false,
    })
      .limit(parseInt(limit))
      .skip(parseInt(offset));

    res.json({
      success: true,
      users,
    });
  } catch (error) {
    next(error);
  }
});

export default router;

