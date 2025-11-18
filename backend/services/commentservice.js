import EventComment from "../models/event_commentsmodel.js";
import Event from "../models/eventsmodel.js";

/**
 * Comment service
 * Handles event comment-related business logic
 */

/**
 * Create a new comment
 * @param {Object} commentData - Comment data
 * @returns {Object} Created comment
 */
export const createComment = async (commentData) => {
  const { eventId, userId, comment } = commentData;

  // Verify event exists
  const event = await Event.findById(eventId);
  if (!event) {
    const error = new Error("Event not found");
    error.statusCode = 404;
    throw error;
  }

  // Create comment
  const newComment = new EventComment({
    eventId,
    userId,
    comment
  });

  await newComment.save();

  // Update event comment count
  event.commentCount = (event.commentCount || 0) + 1;
  await event.save();

  // Populate user
  await newComment.populate("userId", "name avatarUrl");

  return newComment;
};

/**
 * Get all comments for an event
 * @param {string} eventId - Event ID
 * @param {Object} options - Query options (page, limit)
 * @returns {Object} Comments and pagination info
 */
export const getEventComments = async (eventId, options = {}) => {
  const { page = 1, limit = 20 } = options;

  // Verify event exists
  const event = await Event.findById(eventId);
  if (!event) {
    const error = new Error("Event not found");
    error.statusCode = 404;
    throw error;
  }

  const skip = (parseInt(page) - 1) * parseInt(limit);
  const limitNum = parseInt(limit);

  const [comments, total] = await Promise.all([
    EventComment.find({ eventId })
      .populate("userId", "name avatarUrl")
      .skip(skip)
      .limit(limitNum)
      .sort({ createdAt: -1 }),
    EventComment.countDocuments({ eventId })
  ]);

  return {
    comments,
    pagination: {
      page: parseInt(page),
      limit: limitNum,
      total,
      pages: Math.ceil(total / limitNum)
    }
  };
};

/**
 * Get comment by ID
 * @param {string} commentId - Comment ID
 * @returns {Object} Comment object
 */
export const getCommentById = async (commentId) => {
  const comment = await EventComment.findById(commentId).populate("userId", "name avatarUrl");

  if (!comment) {
    const error = new Error("Comment not found");
    error.statusCode = 404;
    throw error;
  }

  return comment;
};

/**
 * Update comment
 * @param {string} commentId - Comment ID
 * @param {string} userId - User ID (for ownership check)
 * @param {Object} updateData - Update data
 * @returns {Object} Updated comment
 */
export const updateComment = async (commentId, userId, updateData) => {
  const comment = await EventComment.findById(commentId);

  if (!comment) {
    const error = new Error("Comment not found");
    error.statusCode = 404;
    throw error;
  }

  // Check ownership
  if (comment.userId.toString() !== userId.toString()) {
    const error = new Error("You don't have permission to update this comment");
    error.statusCode = 403;
    throw error;
  }

  // Update comment
  if (updateData.comment !== undefined) {
    comment.comment = updateData.comment;
  }

  await comment.save();

  // Populate user
  await comment.populate("userId", "name avatarUrl");

  return comment;
};

/**
 * Delete comment
 * @param {string} commentId - Comment ID
 * @param {string} userId - User ID (for ownership check)
 * @returns {Object} Deletion result
 */
export const deleteComment = async (commentId, userId) => {
  const comment = await EventComment.findById(commentId);

  if (!comment) {
    const error = new Error("Comment not found");
    error.statusCode = 404;
    throw error;
  }

  // Check ownership
  if (comment.userId.toString() !== userId.toString()) {
    const error = new Error("You don't have permission to delete this comment");
    error.statusCode = 403;
    throw error;
  }

  // Update event comment count
  const event = await Event.findById(comment.eventId);
  if (event) {
    event.commentCount = Math.max(0, (event.commentCount || 0) - 1);
    await event.save();
  }

  await EventComment.findByIdAndDelete(commentId);

  return { message: "Comment deleted successfully" };
};

/**
 * Get comments by user
 * @param {string} userId - User ID
 * @param {Object} options - Query options (page, limit)
 * @returns {Object} Comments and pagination info
 */
export const getCommentsByUser = async (userId, options = {}) => {
  const { page = 1, limit = 20 } = options;

  const skip = (parseInt(page) - 1) * parseInt(limit);
  const limitNum = parseInt(limit);

  const [comments, total] = await Promise.all([
    EventComment.find({ userId })
      .populate("eventId", "title imageUrl date")
      .skip(skip)
      .limit(limitNum)
      .sort({ createdAt: -1 }),
    EventComment.countDocuments({ userId })
  ]);

  return {
    comments,
    pagination: {
      page: parseInt(page),
      limit: limitNum,
      total,
      pages: Math.ceil(total / limitNum)
    }
  };
};

