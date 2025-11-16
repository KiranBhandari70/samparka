import * as chatService from "../services/chatservice.js";
import { sendSuccess, sendError } from "../utils/response.js";
import { asyncHandler } from "../middlewares/errormiddleware.js";

/**
 * Chat controller
 * Handles user chat-related HTTP requests
 */

/**
 * Get or create a chat between two users
 * POST /api/chats
 */
export const getOrCreateChat = asyncHandler(async (req, res) => {
  if (!req.user || !req.user.userId) {
    return sendError(res, 401, "Authentication required");
  }

  const { userId2 } = req.body;

  if (!userId2) {
    return sendError(res, 400, "Second user ID is required");
  }

  const chat = await chatService.getOrCreateChat(req.user.userId, userId2);
  return sendSuccess(res, 200, "Chat retrieved successfully", chat);
});

/**
 * Get all chats for current user
 * GET /api/chats
 */
export const getUserChats = asyncHandler(async (req, res) => {
  if (!req.user || !req.user.userId) {
    return sendError(res, 401, "Authentication required");
  }

  const chats = await chatService.getUserChats(req.user.userId);
  return sendSuccess(res, 200, "User chats retrieved successfully", chats);
});

/**
 * Get chat by ID
 * GET /api/chats/:chatId
 */
export const getChatById = asyncHandler(async (req, res) => {
  if (!req.user || !req.user.userId) {
    return sendError(res, 401, "Authentication required");
  }

  const { chatId } = req.params;
  const chat = await chatService.getChatById(chatId, req.user.userId);
  return sendSuccess(res, 200, "Chat retrieved successfully", chat);
});

/**
 * Send a message in a chat
 * POST /api/chats/:chatId/messages
 */
export const sendMessage = asyncHandler(async (req, res) => {
  if (!req.user || !req.user.userId) {
    return sendError(res, 401, "Authentication required");
  }

  const { chatId } = req.params;
  const { text } = req.body;

  if (!text) {
    return sendError(res, 400, "Message text is required");
  }

  const chat = await chatService.sendMessage(chatId, req.user.userId, text);
  return sendSuccess(res, 201, "Message sent successfully", chat);
});

/**
 * Mark messages as seen
 * PUT /api/chats/:chatId/seen
 */
export const markMessagesAsSeen = asyncHandler(async (req, res) => {
  if (!req.user || !req.user.userId) {
    return sendError(res, 401, "Authentication required");
  }

  const { chatId } = req.params;
  const chat = await chatService.markMessagesAsSeen(chatId, req.user.userId);
  return sendSuccess(res, 200, "Messages marked as seen", chat);
});

/**
 * Get chat messages
 * GET /api/chats/:chatId/messages
 */
export const getChatMessages = asyncHandler(async (req, res) => {
  if (!req.user || !req.user.userId) {
    return sendError(res, 401, "Authentication required");
  }

  const { chatId } = req.params;
  const { page, limit } = req.query;

  const options = { page, limit };
  const result = await chatService.getChatMessages(chatId, req.user.userId, options);

  return sendSuccess(res, 200, "Messages retrieved successfully", result.messages, result.pagination);
});

/**
 * Delete a chat
 * DELETE /api/chats/:chatId
 */
export const deleteChat = asyncHandler(async (req, res) => {
  if (!req.user || !req.user.userId) {
    return sendError(res, 401, "Authentication required");
  }

  const { chatId } = req.params;
  const result = await chatService.deleteChat(chatId, req.user.userId);
  return sendSuccess(res, 200, result.message);
});

