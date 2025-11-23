import User from '../models/User.js';
import { generateToken } from '../utils/generateToken.js';
import { OAuth2Client } from 'google-auth-library';
import { config } from '../config/env.js';

const googleClient = new OAuth2Client(config.googleClientId);

// @desc    Register user
// @route   POST /api/v1/auth/register
// @access  Public
export const register = async (req, res, next) => {
  try {
    const { email, password, name, lat, lng } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: 'Email and password are required' });
    }

    // Check if user exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: 'User already exists with this email' });
    }

    // Validate coordinates
    let coordinates = [0, 0]; // default
    if (lat !== undefined && lng !== undefined) {
      coordinates = [parseFloat(lng), parseFloat(lat)]; // MongoDB expects [lng, lat]
    }

    // Create user
    const user = new User({
      email,
      name: name || email.split('@')[0],
      authProvider: 'email',
      location: {
        type: 'Point',
        coordinates,
      },
    });

    await user.hashPassword(password);
    await user.save();

    const token = generateToken(user._id);

    res.status(201).json({
      success: true,
      token,
      user: user.toJSON(),
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Login user
// @route   POST /api/v1/auth/login
// @access  Public
export const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: 'Email and password are required' });
    }

    const user = await User.findOne({ email }).select('+passwordHash');
    if (!user) return res.status(401).json({ message: 'Invalid credentials' });
    if (user.blocked) return res.status(403).json({ message: 'Account is blocked' });

    if (user.authProvider === 'email' && !user.passwordHash) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) return res.status(401).json({ message: 'Invalid credentials' });

    const token = generateToken(user._id);

    res.json({ success: true, token, user: user.toJSON() });
  } catch (error) {
    next(error);
  }
};

// @desc    Google OAuth login
// @route   POST /api/v1/auth/google
// @access  Public
export const googleLogin = async (req, res, next) => {
  try {
    const { tokenId } = req.body;
    if (!tokenId) return res.status(400).json({ message: 'Google token is required' });

    const ticket = await googleClient.verifyIdToken({
      idToken: tokenId,
      audience: config.googleClientId,
    });

    const payload = ticket.getPayload();
    const { email, name, picture } = payload;

    // Find or create user
    let user = await User.findOne({ email });

    if (user) {
      if (!user.avatarUrl && picture) user.avatarUrl = picture;
      if (user.authProvider !== 'google') user.authProvider = 'google';
      await user.save();
    } else {
      user = new User({
        email,
        name: name || email.split('@')[0],
        avatarUrl: picture,
        authProvider: 'google',
        verified: true,
        location: {
          type: 'Point',
          coordinates: [0, 0], // default location
        },
      });
      await user.save();
    }

    if (user.blocked) return res.status(403).json({ message: 'Account is blocked' });

    const token = generateToken(user._id);

    res.json({ success: true, token, user: user.toJSON() });
  } catch (error) {
    next(error);
  }
};

// @desc    Get current user
// @route   GET /api/v1/auth/me
// @access  Private
export const getMe = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id);
    res.json({ success: true, user: user.toJSON() });
  } catch (error) {
    next(error);
  }
};

// @desc    Refresh token
// @route   POST /api/v1/auth/refresh
// @access  Private
export const refreshToken = async (req, res, next) => {
  try {
    const token = generateToken(req.user._id);
    res.json({ success: true, token });
  } catch (error) {
    next(error);
  }
};

// @desc    Logout
// @route   POST /api/v1/auth/logout
// @access  Private
export const logout = async (req, res, next) => {
  try {
    res.json({ success: true, message: 'Logged out successfully' });
  } catch (error) {
    next(error);
  }
};

// @desc    Forgot password
// @route   POST /api/v1/auth/forgot-password
// @access  Public
export const forgotPassword = async (req, res, next) => {
  try {
    const { email } = req.body;
    if (!email) return res.status(400).json({ message: 'Email is required' });

    const user = await User.findOne({ email });
    res.json({
      success: true,
      message: 'If an account exists with this email, a password reset link has been sent',
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Reset password
// @route   POST /api/v1/auth/reset-password
// @access  Public
export const resetPassword = async (req, res, next) => {
  try {
    res.status(501).json({ message: 'Password reset not yet implemented' });
  } catch (error) {
    next(error);
  }
};

// @desc    Verify email
// @route   POST /api/v1/auth/verify-email
// @access  Public
export const verifyEmail = async (req, res, next) => {
  try {
    res.status(501).json({ message: 'Email verification not yet implemented' });
  } catch (error) {
    next(error);
  }
};
