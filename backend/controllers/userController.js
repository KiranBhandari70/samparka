import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

import User from '../models/User.js';
import Event from '../models/Event.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// @desc    Get user profile
// @route   GET /api/v1/user/profile
// @access  Private
export const getProfile = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id);
    res.json({
      success: true,
      user: user.toJSON(),
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Update user profile
// @route   PUT /api/v1/user/profile
// @access  Private
export const updateProfile = async (req, res, next) => {
  try {
    const {
      name,
      age,
      bio,
      interests,
      locationLabel,
      location,
      role,
    } = req.body;

    const user = await User.findById(req.user._id);

    if (name) user.name = name;
    if (age !== undefined) user.age = age;
    if (bio !== undefined) user.bio = bio;
    if (interests) user.interests = interests;
    if (locationLabel !== undefined) user.locationLabel = locationLabel;
    if (location) {
      user.location = {
        type: 'Point',
        coordinates: location.coordinates || [location.longitude, location.latitude],
      };
    }

    if (role !== undefined) {
      const allowedRoles = ['member', 'business'];
      if (!allowedRoles.includes(role)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid role update request',
        });
      }

      // Prevent privilege escalation
      if (role === 'admin' && user.role !== 'admin') {
        return res.status(403).json({
          success: false,
          message: 'You are not authorized to become an admin',
        });
      }

      user.role = role;
    }

    await user.save();

    res.json({
      success: true,
      user: user.toJSON(),
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Upload avatar
// @route   POST /api/v1/user/avatar
// @access  Private
export const uploadAvatar = async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'No file uploaded' });
    }

    const user = await User.findById(req.user._id);

    // Remove old avatar from disk if it exists
    if (user.avatarUrl && user.avatarUrl.startsWith('/uploads/')) {
      const oldAvatarPath = path.join(__dirname, '..', user.avatarUrl.replace(/^\//, ''));
      if (fs.existsSync(oldAvatarPath)) {
        try {
          await fs.promises.unlink(oldAvatarPath);
        } catch (unlinkError) {
          console.warn('Failed to remove previous avatar:', unlinkError.message);
        }
      }
    }

    // In production, upload to cloud storage (S3, Cloudinary, etc.)
    // For now, use local path
    const savedFilePath = path.join(__dirname, '..', 'uploads', req.file.filename);
    if (!fs.existsSync(savedFilePath)) {
      return res.status(500).json({
        success: false,
        message: 'Failed to save avatar file',
      });
    }

    const avatarUrl = `/uploads/${req.file.filename}`;
    user.avatarUrl = avatarUrl;
    await user.save();

    res.json({
      success: true,
      avatarUrl: user.avatarUrl,
      user: user.toJSON(),
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get recently registered users
// @route   GET /api/v1/users/registered
// @access  Public
export const getRegisteredUsers = async (req, res, next) => {
  try {
    const limit = Math.min(Number(req.query.limit) || 10, 50);
    const users = await User.find({})
      .sort({ createdAt: -1 })
      .limit(limit)
      .select('name avatarUrl interests locationLabel role createdAt');

    res.json({
      success: true,
      count: users.length,
      users,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Update interests
// @route   PUT /api/v1/user/interests
// @access  Private
export const updateInterests = async (req, res, next) => {
  try {
    const { interests } = req.body;

    if (!Array.isArray(interests)) {
      return res.status(400).json({ message: 'Interests must be an array' });
    }

    const user = await User.findById(req.user._id);
    user.interests = interests;
    await user.save();

    res.json({
      success: true,
      interests: user.interests,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get user events
// @route   GET /api/v1/users/:userId/events
// @access  Public
export const getUserEvents = async (req, res, next) => {
  try {
    const { userId } = req.params;
    const events = await Event.find({ createdBy: userId })
      .populate('createdBy', 'name email avatarUrl')
      .populate('attendees', 'name email avatarUrl')
      .sort({ startsAt: -1 });

    res.json({
      success: true,
      events,
    });
  } catch (error) {
    next(error);
  }
};

