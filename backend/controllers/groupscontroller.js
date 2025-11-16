import * as groupService from "../services/groupservice.js";
import { sendSuccess, sendError } from "../utils/response.js";
import { asyncHandler } from "../middlewares/errormiddleware.js";

/**
 * Group controller
 * Handles group-related HTTP requests
 */

/**
 * Create a new group
 * POST /api/groups
 */
export const createGroup = asyncHandler(async (req, res) => {
  if (!req.user || !req.user.userId) {
    return sendError(res, 401, "Authentication required");
  }

  const { name, keyword } = req.body;

  if (!name || !keyword) {
    return sendError(res, 400, "Name and keyword are required");
  }

  const groupData = {
    ...req.body,
    createdBy: req.user.userId
  };

  const group = await groupService.createGroup(groupData);
  return sendSuccess(res, 201, "Group created successfully", group);
});

/**
 * Get all groups with pagination and filters
 * GET /api/groups
 */
export const getAllGroups = asyncHandler(async (req, res) => {
  const { page, limit, keyword, search, createdBy, longitude, latitude, maxDistance } = req.query;

  const options = {
    page,
    limit,
    keyword,
    search,
    createdBy,
    longitude,
    latitude,
    maxDistance
  };

  const result = await groupService.getAllGroups(options);
  return sendSuccess(res, 200, "Groups retrieved successfully", result.groups, result.pagination);
});

/**
 * Get group by ID
 * GET /api/groups/:groupId
 */
export const getGroupById = asyncHandler(async (req, res) => {
  const { groupId } = req.params;
  const group = await groupService.getGroupById(groupId);
  return sendSuccess(res, 200, "Group retrieved successfully", group);
});

/**
 * Update group
 * PUT /api/groups/:groupId
 */
export const updateGroup = asyncHandler(async (req, res) => {
  if (!req.user || !req.user.userId) {
    return sendError(res, 401, "Authentication required");
  }

  const { groupId } = req.params;
  const updatedGroup = await groupService.updateGroup(groupId, req.user.userId, req.body);
  return sendSuccess(res, 200, "Group updated successfully", updatedGroup);
});

/**
 * Delete group
 * DELETE /api/groups/:groupId
 */
export const deleteGroup = asyncHandler(async (req, res) => {
  if (!req.user || !req.user.userId) {
    return sendError(res, 401, "Authentication required");
  }

  const { groupId } = req.params;
  const result = await groupService.deleteGroup(groupId, req.user.userId);
  return sendSuccess(res, 200, result.message);
});

/**
 * Join group
 * POST /api/groups/:groupId/join
 */
export const joinGroup = asyncHandler(async (req, res) => {
  if (!req.user || !req.user.userId) {
    return sendError(res, 401, "Authentication required");
  }

  const { groupId } = req.params;
  const updatedGroup = await groupService.joinGroup(groupId, req.user.userId);
  return sendSuccess(res, 200, "Joined group successfully", updatedGroup);
});

/**
 * Leave group
 * POST /api/groups/:groupId/leave
 */
export const leaveGroup = asyncHandler(async (req, res) => {
  if (!req.user || !req.user.userId) {
    return sendError(res, 401, "Authentication required");
  }

  const { groupId } = req.params;
  const updatedGroup = await groupService.leaveGroup(groupId, req.user.userId);
  return sendSuccess(res, 200, "Left group successfully", updatedGroup);
});

/**
 * Get groups by user
 * GET /api/groups/user/:userId
 */
export const getGroupsByUser = asyncHandler(async (req, res) => {
  const { userId } = req.params;
  const { type = "member" } = req.query;

  if (!["created", "member"].includes(type)) {
    return sendError(res, 400, "Type must be 'created' or 'member'");
  }

  const groups = await groupService.getGroupsByUser(userId, type);
  return sendSuccess(res, 200, "User groups retrieved successfully", groups);
});

/**
 * Create a group message
 * POST /api/groups/:groupId/messages
 */
export const createGroupMessage = asyncHandler(async (req, res) => {
  if (!req.user || !req.user.userId) {
    return sendError(res, 401, "Authentication required");
  }

  const { groupId } = req.params;
  const { message, attachments } = req.body;

  if (!message) {
    return sendError(res, 400, "Message is required");
  }

  const messageData = {
    groupId,
    senderId: req.user.userId,
    message,
    attachments
  };

  const newMessage = await groupService.createGroupMessage(messageData);
  return sendSuccess(res, 201, "Message sent successfully", newMessage);
});

/**
 * Get group messages
 * GET /api/groups/:groupId/messages
 */
export const getGroupMessages = asyncHandler(async (req, res) => {
  const { groupId } = req.params;
  const { page, limit } = req.query;

  const options = { page, limit };
  const result = await groupService.getGroupMessages(groupId, options);

  return sendSuccess(res, 200, "Messages retrieved successfully", result.messages, result.pagination);
});

