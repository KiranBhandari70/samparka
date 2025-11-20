import Group from "../models/groupsmodel.js";
import GroupMessage from "../models/group_messagesmodel.js";

/**
 * Group service
 * Handles group-related business logic
 */

/**
 * Create a new group
 * @param {Object} groupData - Group data
 * @returns {Object} Created group
 */
export const createGroup = async (groupData) => {
  const { name, description, keyword, location, createdBy } = groupData;

  // Create group with creator as first member
  const group = new Group({
    name,
    description,
    keyword,
    location,
    createdBy,
    members: [createdBy],
    memberCount: 1
  });

  await group.save();

  // Populate creator and members
  await group.populate("createdBy", "name avatarUrl");
  await group.populate("members", "name avatarUrl");

  return group;
};

/**
 * Get all groups with pagination and filters
 * @param {Object} options - Query options
 * @returns {Object} Groups and pagination info
 */
export const getAllGroups = async (options = {}) => {
  const { page = 1, limit = 20, keyword, search, createdBy, longitude, latitude, maxDistance } = options;

  const query = {};

  // Filter by keyword
  if (keyword) {
    query.keyword = keyword;
  }

  // Filter by creator
  if (createdBy) {
    query.createdBy = createdBy;
  }

  // Search by name or description
  if (search) {
    query.$or = [
      { name: { $regex: search, $options: "i" } },
      { description: { $regex: search, $options: "i" } }
    ];
  }

  // Filter by location (nearby groups)
  if (longitude && latitude) {
    query.location = {
      $near: {
        $geometry: {
          type: "Point",
          coordinates: [parseFloat(longitude), parseFloat(latitude)]
        },
        $maxDistance: maxDistance || 10000
      }
    };
  }

  const skip = (parseInt(page) - 1) * parseInt(limit);
  const limitNum = parseInt(limit);

  const [groups, total] = await Promise.all([
    Group.find(query)
      .populate("createdBy", "name avatarUrl")
      .populate("members", "name avatarUrl")
      .skip(skip)
      .limit(limitNum)
      .sort({ createdAt: -1 }),
    Group.countDocuments(query)
  ]);

  return {
    groups,
    pagination: {
      page: parseInt(page),
      limit: limitNum,
      total,
      pages: Math.ceil(total / limitNum)
    }
  };
};

/**
 * Get group by ID
 * @param {string} groupId - Group ID
 * @returns {Object} Group object
 */
export const getGroupById = async (groupId) => {
  const group = await Group.findById(groupId)
    .populate("createdBy", "name avatarUrl email")
    .populate("members", "name avatarUrl");

  if (!group) {
    const error = new Error("Group not found");
    error.statusCode = 404;
    throw error;
  }

  return group;
};

/**
 * Update group
 * @param {string} groupId - Group ID
 * @param {string} userId - User ID (for ownership check)
 * @param {Object} updateData - Update data
 * @returns {Object} Updated group
 */
export const updateGroup = async (groupId, userId, updateData) => {
  const group = await Group.findById(groupId);

  if (!group) {
    const error = new Error("Group not found");
    error.statusCode = 404;
    throw error;
  }

  // Check ownership
  if (group.createdBy.toString() !== userId.toString()) {
    const error = new Error("You don't have permission to update this group");
    error.statusCode = 403;
    throw error;
  }

  // Update allowed fields
  const allowedFields = ["name", "description", "keyword", "location"];
  allowedFields.forEach((field) => {
    if (updateData[field] !== undefined) {
      group[field] = updateData[field];
    }
  });

  await group.save();

  // Populate creator and members
  await group.populate("createdBy", "name avatarUrl");
  await group.populate("members", "name avatarUrl");

  return group;
};

/**
 * Delete group
 * @param {string} groupId - Group ID
 * @param {string} userId - User ID (for ownership check)
 * @returns {Object} Deletion result
 */
export const deleteGroup = async (groupId, userId) => {
  const group = await Group.findById(groupId);

  if (!group) {
    const error = new Error("Group not found");
    error.statusCode = 404;
    throw error;
  }

  // Check ownership
  if (group.createdBy.toString() !== userId.toString()) {
    const error = new Error("You don't have permission to delete this group");
    error.statusCode = 403;
    throw error;
  }

  // Delete associated messages
  await GroupMessage.deleteMany({ groupId });

  await Group.findByIdAndDelete(groupId);

  return { message: "Group deleted successfully" };
};

/**
 * Join group (add user to members)
 * @param {string} groupId - Group ID
 * @param {string} userId - User ID
 * @returns {Object} Updated group
 */
export const joinGroup = async (groupId, userId) => {
  const group = await Group.findById(groupId);

  if (!group) {
    const error = new Error("Group not found");
    error.statusCode = 404;
    throw error;
  }

  // Check if user is already a member
  if (group.members.includes(userId)) {
    const error = new Error("User is already a member of this group");
    error.statusCode = 409;
    throw error;
  }

  // Add user to members
  group.members.push(userId);
  group.memberCount = group.members.length;
  await group.save();

  // Populate members
  await group.populate("members", "name avatarUrl");

  return group;
};

/**
 * Leave group (remove user from members)
 * @param {string} groupId - Group ID
 * @param {string} userId - User ID
 * @returns {Object} Updated group
 */
export const leaveGroup = async (groupId, userId) => {
  const group = await Group.findById(groupId);

  if (!group) {
    const error = new Error("Group not found");
    error.statusCode = 404;
    throw error;
  }

  // Prevent creator from leaving
  if (group.createdBy.toString() === userId.toString()) {
    const error = new Error("Group creator cannot leave the group");
    error.statusCode = 403;
    throw error;
  }

  // Remove user from members
  group.members = group.members.filter((memberId) => memberId.toString() !== userId.toString());
  group.memberCount = group.members.length;
  await group.save();

  // Populate members
  await group.populate("members", "name avatarUrl");

  return group;
};

/**
 * Get groups by user
 * @param {string} userId - User ID
 * @param {string} type - Type of groups ('created' or 'member')
 * @returns {Array} User groups
 */
export const getGroupsByUser = async (userId, type = "member") => {
  const query = type === "created" ? { createdBy: userId } : { members: userId };

  const groups = await Group.find(query)
    .populate("createdBy", "name avatarUrl")
    .populate("members", "name avatarUrl")
    .sort({ createdAt: -1 });

  return groups;
};

/**
 * Create a group message
 * @param {Object} messageData - Message data
 * @returns {Object} Created message
 */
export const createGroupMessage = async (messageData) => {
  const { groupId, senderId, message, attachments } = messageData;

  // Verify group exists and user is a member
  const group = await Group.findById(groupId);
  if (!group) {
    const error = new Error("Group not found");
    error.statusCode = 404;
    throw error;
  }

  if (!group.members.includes(senderId)) {
    const error = new Error("You must be a member of this group to send messages");
    error.statusCode = 403;
    throw error;
  }

  // Create message
  const newMessage = new GroupMessage({
    groupId,
    senderId,
    message,
    attachments: attachments || []
  });

  await newMessage.save();

  // Populate sender
  await newMessage.populate("senderId", "name avatarUrl");

  return newMessage;
};

/**
 * Get group messages
 * @param {string} groupId - Group ID
 * @param {Object} options - Query options (page, limit)
 * @returns {Object} Messages and pagination info
 */
export const getGroupMessages = async (groupId, options = {}) => {
  const { page = 1, limit = 50 } = options;

  // Verify group exists
  const group = await Group.findById(groupId);
  if (!group) {
    const error = new Error("Group not found");
    error.statusCode = 404;
    throw error;
  }

  const skip = (parseInt(page) - 1) * parseInt(limit);
  const limitNum = parseInt(limit);

  const [messages, total] = await Promise.all([
    GroupMessage.find({ groupId })
      .populate("senderId", "name avatarUrl")
      .skip(skip)
      .limit(limitNum)
      .sort({ sentAt: -1 }),
    GroupMessage.countDocuments({ groupId })
  ]);

  return {
    messages,
    pagination: {
      page: parseInt(page),
      limit: limitNum,
      total,
      pages: Math.ceil(total / limitNum)
    }
  };
};

