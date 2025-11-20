import * as commentService from "../services/commentservice.js";
import { sendSuccess, sendError } from "../utils/response.js";
import { asyncHandler } from "../middlewares/errormiddleware.js";

/**
 * Comment controller
 * Handles event comment-related HTTP requests
 */

/**
 * Create a new comment
 * POST /api/comments
 */
export const createComment = asyncHandler(async (req, res) => {
  if (!req.user || !req.user.userId) {
    return sendError(res, 401, "Authentication required");
  }

  const { eventId, comment } = req.body;

  if (!eventId || !comment) {
    return sendError(res, 400, "Event ID and comment are required");
  }

  const commentData = {
    eventId,
    userId: req.user.userId,
    comment
  };

  const newComment = await commentService.createComment(commentData);
  return sendSuccess(res, 201, "Comment created successfully", newComment);
});

/**
 * Get all comments for an event
 * GET /api/comments/event/:eventId
 */
export const getEventComments = asyncHandler(async (req, res) => {
  const { eventId } = req.params;
  const { page, limit } = req.query;

  const options = { page, limit };
  const result = await commentService.getEventComments(eventId, options);

  return sendSuccess(res, 200, "Comments retrieved successfully", result.comments, result.pagination);
});

/**
 * Get comment by ID
 * GET /api/comments/:commentId
 */
export const getCommentById = asyncHandler(async (req, res) => {
  const { commentId } = req.params;
  const comment = await commentService.getCommentById(commentId);
  return sendSuccess(res, 200, "Comment retrieved successfully", comment);
});

/**
 * Update comment
 * PUT /api/comments/:commentId
 */
export const updateComment = asyncHandler(async (req, res) => {
  if (!req.user || !req.user.userId) {
    return sendError(res, 401, "Authentication required");
  }

  const { commentId } = req.params;
  const updatedComment = await commentService.updateComment(commentId, req.user.userId, req.body);
  return sendSuccess(res, 200, "Comment updated successfully", updatedComment);
});

/**
 * Delete comment
 * DELETE /api/comments/:commentId
 */
export const deleteComment = asyncHandler(async (req, res) => {
  if (!req.user || !req.user.userId) {
    return sendError(res, 401, "Authentication required");
  }

  const { commentId } = req.params;
  const result = await commentService.deleteComment(commentId, req.user.userId);
  return sendSuccess(res, 200, result.message);
});

/**
 * Get comments by user
 * GET /api/comments/user/:userId
 */
export const getCommentsByUser = asyncHandler(async (req, res) => {
  const { userId } = req.params;
  const { page, limit } = req.query;

  const options = { page, limit };
  const result = await commentService.getCommentsByUser(userId, options);

  return sendSuccess(res, 200, "User comments retrieved successfully", result.comments, result.pagination);
});

