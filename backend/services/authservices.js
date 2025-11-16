import bcrypt from "bcrypt";
import User from "../models/usermodel.js";
import Verification from "../models/verificationsmodel.js";
import { generateToken } from "../utils/jwt.js";

/**
 * Authentication service
 * Handles user authentication, registration, and verification
 */

/**
 * Register a new user
 * @param {Object} userData - User registration data
 * @returns {Object} Created user and token
 */
export const registerUser = async (userData) => {
  const { name, email, phoneNumber, passwordHash, authProvider } = userData;

  // Check if user already exists
  const existingUser = await User.findOne({
    $or: [{ email }, { phoneNumber }]
  });

  if (existingUser) {
    const error = new Error("User already exists with this email or phone number");
    error.statusCode = 409;
    throw error;
  }

  // Hash password if provided
  let hashedPassword = passwordHash;
  if (passwordHash && authProvider === "phone") {
    hashedPassword = await bcrypt.hash(passwordHash, 10);
  }

  // Create new user
  const user = new User({
    name,
    email,
    phoneNumber,
    passwordHash: hashedPassword,
    authProvider,
    avatarUrl: userData.avatarUrl,
    bio: userData.bio,
    interests: userData.interests || [],
    location: userData.location
  });

  await user.save();

  // Generate token
  const token = generateToken(user._id.toString());

  // Remove sensitive data
  const userObj = user.toObject();
  delete userObj.passwordHash;

  return {
    user: userObj,
    token
  };
};

/**
 * Login user with email/phone and password
 * @param {string} identifier - Email or phone number
 * @param {string} password - User password
 * @returns {Object} User and token
 */
export const loginUser = async (identifier, password) => {
  // Find user by email or phone
  const user = await User.findOne({
    $or: [{ email: identifier }, { phoneNumber: identifier }]
  });

  if (!user) {
    const error = new Error("Invalid credentials");
    error.statusCode = 401;
    throw error;
  }

  // Verify password
  if (user.passwordHash) {
    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    if (!isPasswordValid) {
      const error = new Error("Invalid credentials");
      error.statusCode = 401;
      throw error;
    }
  }

  // Generate token
  const token = generateToken(user._id.toString());

  // Remove sensitive data
  const userObj = user.toObject();
  delete userObj.passwordHash;

  return {
    user: userObj,
    token
  };
};

/**
 * Login or register user with Google OAuth
 * @param {Object} googleData - Google OAuth data
 * @returns {Object} User and token
 */
export const googleAuth = async (googleData) => {
  const { email, name, avatarUrl, googleId } = googleData;

  // Check if user exists
  let user = await User.findOne({ email });

  if (user) {
    // Update user if needed
    if (!user.avatarUrl && avatarUrl) {
      user.avatarUrl = avatarUrl;
      await user.save();
    }
  } else {
    // Create new user
    user = new User({
      name,
      email,
      authProvider: "google",
      avatarUrl
    });
    await user.save();
  }

  // Generate token
  const token = generateToken(user._id.toString());

  // Remove sensitive data
  const userObj = user.toObject();
  delete userObj.passwordHash;

  return {
    user: userObj,
    token
  };
};

/**
 * Get current user profile
 * @param {string} userId - User ID
 * @returns {Object} User profile
 */
export const getCurrentUser = async (userId) => {
  const user = await User.findById(userId).select("-passwordHash");

  if (!user) {
    const error = new Error("User not found");
    error.statusCode = 404;
    throw error;
  }

  return user;
};

/**
 * Update user profile
 * @param {string} userId - User ID
 * @param {Object} updateData - Profile update data
 * @returns {Object} Updated user
 */
export const updateProfile = async (userId, updateData) => {
  const user = await User.findById(userId);

  if (!user) {
    const error = new Error("User not found");
    error.statusCode = 404;
    throw error;
  }

  // Update allowed fields
  const allowedFields = ["name", "bio", "avatarUrl", "interests", "location"];
  allowedFields.forEach((field) => {
    if (updateData[field] !== undefined) {
      user[field] = updateData[field];
    }
  });

  await user.save();

  // Remove sensitive data
  const userObj = user.toObject();
  delete userObj.passwordHash;

  return userObj;
};

/**
 * Submit verification request
 * @param {string} userId - User ID
 * @param {Object} verificationData - Verification data
 * @returns {Object} Verification request
 */
export const submitVerification = async (userId, verificationData) => {
  // Check if verification already exists
  const existingVerification = await Verification.findOne({ userId });

  if (existingVerification && existingVerification.status === "pending") {
    const error = new Error("Verification request already pending");
    error.statusCode = 409;
    throw error;
  }

  const verification = new Verification({
    userId,
    citizenshipNumber: verificationData.citizenshipNumber,
    documentUrl: verificationData.documentUrl,
    status: "pending"
  });

  await verification.save();

  return verification;
};

/**
 * Get user verification status
 * @param {string} userId - User ID
 * @returns {Object} Verification status
 */
export const getVerificationStatus = async (userId) => {
  const verification = await Verification.findOne({ userId });

  if (!verification) {
    return { status: "not_submitted" };
  }

  // Update user verified status if approved
  if (verification.status === "approved") {
    await User.findByIdAndUpdate(userId, { verified: true });
  }

  return verification;
};

