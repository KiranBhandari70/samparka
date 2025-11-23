import User from '../models/User.js';
import Event from '../models/Event.js';

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
    
    // In production, upload to cloud storage (S3, Cloudinary, etc.)
    // For now, use local path
    const avatarUrl = `/uploads/${req.file.filename}`;
    user.avatarUrl = avatarUrl;
    await user.save();

    res.json({
      success: true,
      avatarUrl: user.avatarUrl,
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

