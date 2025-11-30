import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

import User from '../models/User.js';
import Event from '../models/Event.js';
import BusinessProfile from '../models/BusinessProfile.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// @desc    Get user profile
// @route   GET /api/v1/user/profile
// @access  Private
export const getProfile = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id).populate('businessProfile');
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
      businessDetails,
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

    // Handle business profile creation/update
    if (businessDetails) {
      // Check if user already has a business profile
      if (user.businessProfile) {
        // Update existing business profile
        const businessProfile = await BusinessProfile.findById(user.businessProfile);
        if (businessProfile) {
          businessProfile.businessName = businessDetails.businessName;
          businessProfile.businessType = businessDetails.businessType;
          businessProfile.businessDescription = businessDetails.businessDescription;
          businessProfile.businessAddress = businessDetails.businessAddress;
          businessProfile.businessPhone = businessDetails.businessPhone;
          if (businessDetails.businessEmail) businessProfile.businessEmail = businessDetails.businessEmail;
          if (businessDetails.businessWebsite) businessProfile.businessWebsite = businessDetails.businessWebsite;
          await businessProfile.save();
        }
      } else {
        // Check if user already has a business profile (prevent duplicate)
        const existingProfile = await BusinessProfile.findOne({ owner: user._id });
        if (existingProfile) {
          return res.status(400).json({
            success: false,
            message: 'You already have a business profile registered',
          });
        }

        // Create new business profile
        const businessProfile = new BusinessProfile({
          businessName: businessDetails.businessName,
          businessType: businessDetails.businessType,
          businessDescription: businessDetails.businessDescription,
          businessAddress: businessDetails.businessAddress,
          businessPhone: businessDetails.businessPhone,
          businessEmail: businessDetails.businessEmail || undefined,
          businessWebsite: businessDetails.businessWebsite || undefined,
          owner: user._id,
        });

        await businessProfile.save();
        user.businessProfile = businessProfile._id;
      }
    }

    await user.save();

    // Populate business profile if it exists
    await user.populate('businessProfile');

    res.json({
      success: true,
      user: user.toJSON(),
    });
  } catch (error) {
    // Handle duplicate key error
    if (error.code === 11000) {
      return res.status(400).json({
        success: false,
        message: 'You already have a business profile registered',
      });
    }
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

// @desc    Get recently registered users (public, lightweight)
// @route   GET /api/v1/users/registered
// @access  Public
export const getRegisteredUsers = async (req, res, next) => {
  try {
    // Allow higher limit for "see all" functionality, but cap at 1000 for performance
    const limit = Math.min(Number(req.query.limit) || 10, 1000);
    const users = await User.find({})
      .sort({ createdAt: -1 })
      .limit(limit)
      .select('name email avatarUrl interests locationLabel role verified bio createdAt');

    res.json({
      success: true,
      count: users.length,
      users,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get all users (admin)
// @route   GET /api/v1/users/admin
// @access  Private/Admin
export const getAllUsersAdmin = async (req, res, next) => {
  try {
    const users = await User.find({})
      .sort({ createdAt: -1 })
      .select('name email avatarUrl role blocked verified createdAt');

    res.json({
      success: true,
      count: users.length,
      users,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Block or unblock a user (admin)
// @route   PATCH /api/v1/users/admin/:userId/block
// @access  Private/Admin
export const setUserBlockedStatus = async (req, res, next) => {
  try {
    const { userId } = req.params;
    const { blocked } = req.body;

    if (typeof blocked !== 'boolean') {
      return res.status(400).json({
        success: false,
        message: 'Invalid blocked value. Expected boolean.',
      });
    }

    // Prevent admin from blocking themselves
    if (userId === req.user._id.toString()) {
      return res.status(400).json({
        success: false,
        message: 'Admins cannot block themselves.',
      });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    user.blocked = blocked;
    await user.save();

    res.json({
      success: true,
      message: blocked ? 'User blocked successfully' : 'User unblocked successfully',
      user: user.toJSON(),
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

// @desc    Submit verification documents
// @route   POST /api/v1/user/verification
// @access  Private
export const submitVerification = async (req, res, next) => {
  try {
    const { phoneNumber } = req.body;
    const citizenshipFront = req.files?.citizenshipFront?.[0];
    const citizenshipBack = req.files?.citizenshipBack?.[0];

    if (!phoneNumber) {
      return res.status(400).json({
        success: false,
        message: 'Phone number is required',
      });
    }

    if (!citizenshipFront || !citizenshipBack) {
      return res.status(400).json({
        success: false,
        message: 'Both citizenship card front and back photos are required',
      });
    }

    const user = await User.findById(req.user._id);

    // Check if already verified
    if (user.verified) {
      return res.status(400).json({
        success: false,
        message: 'User is already verified',
      });
    }

    // Check if already pending
    if (user.verificationStatus === 'pending') {
      return res.status(400).json({
        success: false,
        message: 'Verification request is already pending review',
      });
    }

    // Save file paths
    const citizenshipFrontUrl = `/uploads/${citizenshipFront.filename}`;
    const citizenshipBackUrl = `/uploads/${citizenshipBack.filename}`;

    // Update user verification data
    user.verificationData = {
      phoneNumber,
      citizenshipFrontUrl,
      citizenshipBackUrl,
      submittedAt: new Date(),
    };
    user.verificationStatus = 'pending';

    await user.save();

    res.json({
      success: true,
      message: 'Verification documents submitted successfully. Admin will review your request.',
      user: user.toJSON(),
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get pending verification requests (admin)
// @route   GET /api/v1/users/admin/verifications
// @access  Private/Admin
export const getPendingVerifications = async (req, res, next) => {
  try {
    const users = await User.find({ verificationStatus: 'pending' })
      .select('name email avatarUrl verificationData verificationStatus createdAt')
      .sort({ 'verificationData.submittedAt': -1 });

    res.json({
      success: true,
      count: users.length,
      users,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Approve or reject verification (admin)
// @route   PATCH /api/v1/users/admin/:userId/verification
// @access  Private/Admin
export const reviewVerification = async (req, res, next) => {
  try {
    const { userId } = req.params;
    const { action, rejectionReason } = req.body; // action: 'approve' or 'reject'

    if (!['approve', 'reject'].includes(action)) {
      return res.status(400).json({
        success: false,
        message: 'Action must be either "approve" or "reject"',
      });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    if (user.verificationStatus !== 'pending') {
      return res.status(400).json({
        success: false,
        message: 'User verification is not in pending status',
      });
    }

    if (action === 'approve') {
      user.verificationStatus = 'approved';
      user.verified = true;
      user.verificationData.reviewedAt = new Date();
      user.verificationData.reviewedBy = req.user._id;
      if (user.verificationData.rejectionReason) {
        user.verificationData.rejectionReason = undefined;
      }
    } else {
      user.verificationStatus = 'rejected';
      user.verified = false;
      user.verificationData.reviewedAt = new Date();
      user.verificationData.reviewedBy = req.user._id;
      user.verificationData.rejectionReason = rejectionReason || 'Verification rejected by admin';
    }

    await user.save();

    res.json({
      success: true,
      message: `Verification ${action === 'approve' ? 'approved' : 'rejected'} successfully`,
      user: user.toJSON(),
    });
  } catch (error) {
    next(error);
  }
};

