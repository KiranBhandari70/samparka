import * as authService from "../services/authservices.js";
import { sendSuccess, sendError } from "../utils/response.js";
import { asyncHandler } from "../middlewares/errormiddleware.js";

/**
 * Authentication controller
 * Handles authentication-related HTTP requests
 */

/**
 * Register a new user
 * POST /api/auth/register
 */
export const register = asyncHandler(async (req, res) => {
  const userData = req.body;

  if (!userData.name || !userData.authProvider) {
    return sendError(res, 400, "Name and auth provider are required");
  }

  // Validate auth provider
  if (!["google", "phone"].includes(userData.authProvider)) {
    return sendError(res, 400, "Invalid auth provider. Must be 'google' or 'phone'");
  }

  // For phone auth, password is required
  if (userData.authProvider === "phone" && !userData.passwordHash) {
    return sendError(res, 400, "Password is required for phone authentication");
  }

  // For phone auth, phone number is required
  if (userData.authProvider === "phone" && !userData.phoneNumber) {
    return sendError(res, 400, "Phone number is required for phone authentication");
  }

  const result = await authService.registerUser(userData);
  return sendSuccess(res, 201, "User registered successfully", result);
});

/**
 * Login user
 * POST /api/auth/login
 */
export const login = asyncHandler(async (req, res) => {
  const { identifier, password } = req.body;

  if (!identifier || !password) {
    return sendError(res, 400, "Email/phone and password are required");
  }

  const result = await authService.loginUser(identifier, password);
  return sendSuccess(res, 200, "Login successful", result);
});

/**
 * Google OAuth login/register
 * POST /api/auth/google
 */
export const googleLogin = asyncHandler(async (req, res) => {
  const googleData = req.body;

  if (!googleData.email || !googleData.name) {
    return sendError(res, 400, "Email and name are required for Google authentication");
  }

  const result = await authService.googleAuth(googleData);
  return sendSuccess(res, 200, "Google authentication successful", result);
});

/**
 * Get current user profile
 * GET /api/auth/me
 */
export const getMe = asyncHandler(async (req, res) => {
  if (!req.user || !req.user.userId) {
    return sendError(res, 401, "Authentication required");
  }

  const user = await authService.getCurrentUser(req.user.userId);
  return sendSuccess(res, 200, "User profile retrieved successfully", user);
});

/**
 * Update user profile
 * PUT /api/auth/profile
 */
export const updateProfile = asyncHandler(async (req, res) => {
  if (!req.user || !req.user.userId) {
    return sendError(res, 401, "Authentication required");
  }

  const updatedUser = await authService.updateProfile(req.user.userId, req.body);
  return sendSuccess(res, 200, "Profile updated successfully", updatedUser);
});

/**
 * Submit verification request
 * POST /api/auth/verification
 */
export const submitVerification = asyncHandler(async (req, res) => {
  if (!req.user || !req.user.userId) {
    return sendError(res, 401, "Authentication required");
  }

  const { citizenshipNumber, documentUrl } = req.body;

  if (!citizenshipNumber || !documentUrl) {
    return sendError(res, 400, "Citizenship number and document URL are required");
  }

  const verification = await authService.submitVerification(req.user.userId, {
    citizenshipNumber,
    documentUrl
  });

  return sendSuccess(res, 201, "Verification request submitted successfully", verification);
});

/**
 * Get verification status
 * GET /api/auth/verification/status
 */
export const getVerificationStatus = asyncHandler(async (req, res) => {
  if (!req.user || !req.user.userId) {
    return sendError(res, 401, "Authentication required");
  }

  const status = await authService.getVerificationStatus(req.user.userId);
  return sendSuccess(res, 200, "Verification status retrieved successfully", status);
});

