import * as userService from "../services/userservice.js";
import { sendSuccess, sendError } from "../utils/response.js";
import { asyncHandler } from "../middlewares/errormiddleware.js";

/**
 * User controller
 * Handles user-related HTTP requests
 */

/**
 * Get user by ID
 * GET /api/users/:userId
 */
export const getUserById = asyncHandler(async (req, res) => {
  const { userId } = req.params;
  const user = await userService.getUserById(userId);
  return sendSuccess(res, 200, "User retrieved successfully", user);
});

/**
 * Get all users with pagination
 * GET /api/users
 */
export const getAllUsers = asyncHandler(async (req, res) => {
  const { page, limit, search, interests, verified, longitude, latitude, maxDistance } = req.query;

  const options = {
    page,
    limit,
    search,
    interests: interests ? interests.split(",") : undefined,
    verified,
    longitude,
    latitude,
    maxDistance
  };

  const result = await userService.getAllUsers(options);
  return sendSuccess(res, 200, "Users retrieved successfully", result.users, result.pagination);
});

/**
 * Update user
 * PUT /api/users/:userId
 */
export const updateUser = asyncHandler(async (req, res) => {
  const { userId } = req.params;

  // Check if user is updating their own profile or is admin
  if (req.user && req.user.userId !== userId) {
    // Only allow if user is admin (you can add role check here)
    return sendError(res, 403, "You don't have permission to update this user");
  }

  const updatedUser = await userService.updateUser(userId, req.body);
  return sendSuccess(res, 200, "User updated successfully", updatedUser);
});

/**
 * Delete user
 * DELETE /api/users/:userId
 */
export const deleteUser = asyncHandler(async (req, res) => {
  const { userId } = req.params;

  // Check if user is deleting their own account or is admin
  if (req.user && req.user.userId !== userId) {
    return sendError(res, 403, "You don't have permission to delete this user");
  }

  const result = await userService.deleteUser(userId);
  return sendSuccess(res, 200, result.message);
});

/**
 * Get nearby users
 * GET /api/users/nearby
 */
export const getNearbyUsers = asyncHandler(async (req, res) => {
  const { longitude, latitude, maxDistance = 10000 } = req.query;

  if (!longitude || !latitude) {
    return sendError(res, 400, "Longitude and latitude are required");
  }

  const users = await userService.getNearbyUsers(
    parseFloat(longitude),
    parseFloat(latitude),
    parseInt(maxDistance)
  );

  return sendSuccess(res, 200, "Nearby users retrieved successfully", users);
});

/**
 * Get user statistics
 * GET /api/users/:userId/stats
 */
export const getUserStats = asyncHandler(async (req, res) => {
  const { userId } = req.params;
  const stats = await userService.getUserStats(userId);
  return sendSuccess(res, 200, "User statistics retrieved successfully", stats);
});

