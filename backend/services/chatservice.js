import UserChat from "../models/user_chatsmodel.js";
import User from "../models/usermodel.js";

/**
 * Chat service
 * Handles user chat-related business logic
 */

/**
 * Get or create a chat between two users
 * @param {string} userId1 - First user ID
 * @param {string} userId2 - Second user ID
 * @returns {Object} Chat object
 */
export const getOrCreateChat = async (userId1, userId2) => {
  // Validate users exist
  const [user1, user2] = await Promise.all([User.findById(userId1), User.findById(userId2)]);

  if (!user1 || !user2) {
    const error = new Error("One or both users not found");
    error.statusCode = 404;
    throw error;
  }

  if (userId1 === userId2) {
    const error = new Error("Cannot create chat with yourself");
    error.statusCode = 400;
    throw error;
  }

  // Find existing chat
  let chat = await UserChat.findOne({
    participants: { $all: [userId1, userId2], $size: 2 }
  })
    .populate("participants", "name avatarUrl email phoneNumber")
    .sort({ updatedAt: -1 });

  // Create new chat if doesn't exist
  if (!chat) {
    chat = new UserChat({
      participants: [userId1, userId2],
      messages: [],
      lastMessage: null
    });
    await chat.save();
    await chat.populate("participants", "name avatarUrl email phoneNumber");
  }

  return chat;
};

/**
 * Get all chats for a user
 * @param {string} userId - User ID
 * @returns {Array} User chats
 */
export const getUserChats = async (userId) => {
  const chats = await UserChat.find({
    participants: userId
  })
    .populate("participants", "name avatarUrl email phoneNumber")
    .sort({ updatedAt: -1 });

  return chats;
};

/**
 * Get chat by ID
 * @param {string} chatId - Chat ID
 * @param {string} userId - User ID (for access verification)
 * @returns {Object} Chat object
 */
export const getChatById = async (chatId, userId) => {
  const chat = await UserChat.findById(chatId).populate("participants", "name avatarUrl email phoneNumber");

  if (!chat) {
    const error = new Error("Chat not found");
    error.statusCode = 404;
    throw error;
  }

  // Verify user is a participant
  const isParticipant = chat.participants.some((p) => p._id.toString() === userId.toString());
  if (!isParticipant) {
    const error = new Error("You don't have access to this chat");
    error.statusCode = 403;
    throw error;
  }

  return chat;
};

/**
 * Send a message in a chat
 * @param {string} chatId - Chat ID
 * @param {string} senderId - Sender user ID
 * @param {string} text - Message text
 * @returns {Object} Updated chat with new message
 */
export const sendMessage = async (chatId, senderId, text) => {
  const chat = await UserChat.findById(chatId);

  if (!chat) {
    const error = new Error("Chat not found");
    error.statusCode = 404;
    throw error;
  }

  // Verify sender is a participant
  const isParticipant = chat.participants.some((p) => p.toString() === senderId.toString());
  if (!isParticipant) {
    const error = new Error("You don't have permission to send messages in this chat");
    error.statusCode = 403;
    throw error;
  }

  // Add message
  const message = {
    senderId,
    text,
    sentAt: new Date(),
    seen: false
  };

  chat.messages.push(message);
  chat.lastMessage = text;
  chat.updatedAt = new Date();

  await chat.save();

  // Populate participants and last message sender
  await chat.populate("participants", "name avatarUrl");
  await chat.populate("messages.senderId", "name avatarUrl");

  return chat;
};

/**
 * Mark messages as seen
 * @param {string} chatId - Chat ID
 * @param {string} userId - User ID (who is marking as seen)
 * @returns {Object} Updated chat
 */
export const markMessagesAsSeen = async (chatId, userId) => {
  const chat = await UserChat.findById(chatId);

  if (!chat) {
    const error = new Error("Chat not found");
    error.statusCode = 404;
    throw error;
  }

  // Verify user is a participant
  const isParticipant = chat.participants.some((p) => p.toString() === userId.toString());
  if (!isParticipant) {
    const error = new Error("You don't have access to this chat");
    error.statusCode = 403;
    throw error;
  }

  // Mark all messages not sent by this user as seen
  chat.messages.forEach((msg) => {
    if (msg.senderId.toString() !== userId.toString()) {
      msg.seen = true;
    }
  });

  await chat.save();

  return chat;
};

/**
 * Get chat messages
 * @param {string} chatId - Chat ID
 * @param {string} userId - User ID (for access verification)
 * @param {Object} options - Query options (page, limit)
 * @returns {Object} Messages and pagination info
 */
export const getChatMessages = async (chatId, userId, options = {}) => {
  const { page = 1, limit = 50 } = options;

  const chat = await UserChat.findById(chatId);

  if (!chat) {
    const error = new Error("Chat not found");
    error.statusCode = 404;
    throw error;
  }

  // Verify user is a participant
  const isParticipant = chat.participants.some((p) => p.toString() === userId.toString());
  if (!isParticipant) {
    const error = new Error("You don't have access to this chat");
    error.statusCode = 403;
    throw error;
  }

  // Get messages with pagination (reverse order for latest first)
  const messages = [...chat.messages].reverse();
  const skip = (parseInt(page) - 1) * parseInt(limit);
  const limitNum = parseInt(limit);
  const paginatedMessages = messages.slice(skip, skip + limitNum);

  // Populate sender info
  await UserChat.populate(paginatedMessages, { path: "senderId", select: "name avatarUrl" });

  return {
    messages: paginatedMessages.reverse(), // Reverse back to chronological order
    pagination: {
      page: parseInt(page),
      limit: limitNum,
      total: messages.length,
      pages: Math.ceil(messages.length / limitNum)
    }
  };
};

/**
 * Delete a chat
 * @param {string} chatId - Chat ID
 * @param {string} userId - User ID (for access verification)
 * @returns {Object} Deletion result
 */
export const deleteChat = async (chatId, userId) => {
  const chat = await UserChat.findById(chatId);

  if (!chat) {
    const error = new Error("Chat not found");
    error.statusCode = 404;
    throw error;
  }

  // Verify user is a participant
  const isParticipant = chat.participants.some((p) => p.toString() === userId.toString());
  if (!isParticipant) {
    const error = new Error("You don't have permission to delete this chat");
    error.statusCode = 403;
    throw error;
  }

  await UserChat.findByIdAndDelete(chatId);

  return { message: "Chat deleted successfully" };
};

