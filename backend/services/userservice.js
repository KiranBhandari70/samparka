import User from "../models/usermodel.js";

/**
 * User service
 * Handles user-related business logic
 */

/**
 * Get user by ID
 * @param {string} userId - User ID
 * @returns {Object} User object
 */
export const getUserById = async (userId) => {
  const user = await User.findById(userId).select("-passwordHash");

  if (!user) {
    const error = new Error("User not found");
    error.statusCode = 404;
    throw error;
  }

  return user;
};

/**
 * Get all users with pagination
 * @param {Object} options - Query options (page, limit, search)
 * @returns {Object} Users and pagination info
 */
export const getAllUsers = async (options = {}) => {
  const { page = 1, limit = 20, search, interests, verified } = options;

  const query = {};

  // Search by name, email, or phone
  if (search) {
    query.$or = [
      { name: { $regex: search, $options: "i" } },
      { email: { $regex: search, $options: "i" } },
      { phoneNumber: { $regex: search, $options: "i" } }
    ];
  }

  // Filter by interests
  if (interests && Array.isArray(interests) && interests.length > 0) {
    query.interests = { $in: interests };
  }

  // Filter by verified status
  if (verified !== undefined) {
    query.verified = verified === "true" || verified === true;
  }

  const skip = (parseInt(page) - 1) * parseInt(limit);
  const limitNum = parseInt(limit);

  const [users, total] = await Promise.all([
    User.find(query)
      .select("-passwordHash")
      .skip(skip)
      .limit(limitNum)
      .sort({ createdAt: -1 }),
    User.countDocuments(query)
  ]);

  return {
    users,
    pagination: {
      page: parseInt(page),
      limit: limitNum,
      total,
      pages: Math.ceil(total / limitNum)
    }
  };
};

/**
 * Update user
 * @param {string} userId - User ID
 * @param {Object} updateData - Update data
 * @returns {Object} Updated user
 */
export const updateUser = async (userId, updateData) => {
  const user = await User.findById(userId);

  if (!user) {
    const error = new Error("User not found");
    error.statusCode = 404;
    throw error;
  }

  // Update allowed fields
  const allowedFields = ["name", "email", "phoneNumber", "bio", "avatarUrl", "interests", "location"];
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
 * Delete user
 * @param {string} userId - User ID
 * @returns {Object} Deletion result
 */
export const deleteUser = async (userId) => {
  const user = await User.findByIdAndDelete(userId);

  if (!user) {
    const error = new Error("User not found");
    error.statusCode = 404;
    throw error;
  }

  return { message: "User deleted successfully" };
};

/**
 * Get users by location (nearby users)
 * @param {number} longitude - Longitude
 * @param {number} latitude - Latitude
 * @param {number} maxDistance - Maximum distance in meters
 * @returns {Array} Nearby users
 */
export const getNearbyUsers = async (longitude, latitude, maxDistance = 10000) => {
  const users = await User.find({
    location: {
      $near: {
        $geometry: {
          type: "Point",
          coordinates: [longitude, latitude]
        },
        $maxDistance: maxDistance
      }
    }
  })
    .select("-passwordHash")
    .limit(50);

  return users;
};

/**
 * Get user statistics
 * @param {string} userId - User ID
 * @returns {Object} User statistics
 */
export const getUserStats = async (userId) => {
  const user = await User.findById(userId);

  if (!user) {
    const error = new Error("User not found");
    error.statusCode = 404;
    throw error;
  }

  // This would typically aggregate data from other collections
  // For now, return basic user info
  return {
    userId: user._id,
    name: user.name,
    verified: user.verified,
    createdAt: user.createdAt
  };
};

