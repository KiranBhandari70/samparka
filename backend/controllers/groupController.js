import Group from '../models/Group.js';
import GroupMessage from '../models/GroupMessage.js';
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Utility to slugify strings
const slugify = (value = '') =>
  value
    .toString()
    .toLowerCase()
    .replace(/[^a-z0-9]/g, '')
    .slice(0, 20);

// Generate a unique keyword if none exists
const generateKeyword = (name = '') => {
  const base = slugify(name || 'group');
  const suffix = Date.now().toString().slice(-4);
  return `${base}${suffix}`;
};

// Parse keywords input into array of slugs
const parseKeywords = (input) => {
  if (!input) return [];
  if (Array.isArray(input)) {
    return input
      .map((k) => slugify(k))
      .filter((k) => k.length > 0);
  }

  if (typeof input === 'string') {
    try {
      const parsed = JSON.parse(input);
      if (Array.isArray(parsed)) {
        return parsed
          .map((k) => slugify(k))
          .filter((k) => k.length > 0);
      }
    } catch {
      // Not JSON, treat as comma/space separated
    }

    return input
      .split(/[, ]+/)
      .map((k) => slugify(k))
      .filter((k) => k.length > 0);
  }

  return [];
};

// Get uploaded image URL
const getImageUrl = (file) => {
  if (!file) return null;
  const uploadsDir = path.join(__dirname, '..', 'uploads');
  const filePath = path.join(uploadsDir, file.filename);

  if (!fs.existsSync(filePath)) {
    throw new Error('Failed to save image file');
  }

  return `/uploads/${file.filename}`;
};

// =======================
// GROUP CONTROLLERS
// =======================

// GET /api/v1/groups
export const getGroups = async (req, res, next) => {
  try {
    const { search, limit = 20, offset = 0 } = req.query;
    const query = {};

    if (search) query.$text = { $search: search };

    const groups = await Group.find(query)
      .populate('createdBy', 'name email avatarUrl')
      .populate('members', 'name email avatarUrl')
      .sort({ createdAt: -1 })
      .limit(parseInt(limit))
      .skip(parseInt(offset));

    const total = await Group.countDocuments(query);

    res.json({ success: true, count: groups.length, total, groups });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/groups/:id
export const getGroup = async (req, res, next) => {
  try {
    const group = await Group.findById(req.params.id)
      .populate('createdBy', 'name email avatarUrl')
      .populate('members', 'name email avatarUrl');

    if (!group) return res.status(404).json({ message: 'Group not found' });

    res.json({ success: true, group });
  } catch (error) {
    next(error);
  }
};

// POST /api/v1/groups
// @desc    Create a new group
// @route   POST /api/v1/groups
// @access  Private
export const createGroup = async (req, res, next) => {
  try {
    const { name, description: rawDescription, keywords: keywordsInput } = req.body;

    // 1️⃣ Validate required fields
    if (!name || name.trim().length === 0) {
      return res.status(400).json({ message: 'Group name is required' });
    }

    // 2️⃣ Prepare group data
    const groupData = {
      name: name.trim(),
      createdBy: req.user._id,
      members: [req.user._id], // creator is automatically a member
    };

    const description = typeof rawDescription === 'string' ? rawDescription.trim() : '';
    if (description.length > 0) {
      groupData.description = description;
    }

    // 3️⃣ Handle keywords
    const keywords = parseKeywords(keywordsInput);
    groupData.keywords = keywords;

    // 4️⃣ Ensure unique keyword for MongoDB
    if (keywords.length > 0) {
      groupData.keyword = keywords[0];
    } else {
      groupData.keyword = generateKeyword(groupData.name);
    }

    // 5️⃣ Handle uploaded image
    if (req.file) {
      try {
        groupData.imageUrl = getImageUrl(req.file);
      } catch (err) {
        return res.status(400).json({ message: 'Failed to save uploaded image' });
      }
    }

    // 6️⃣ Create and save group
    const group = new Group(groupData);
    await group.save();

    // 7️⃣ Populate creator and members
    await group.populate('createdBy', 'name email avatarUrl');
    await group.populate('members', 'name email avatarUrl');

    // 8️⃣ Return response
    res.status(201).json({
      success: true,
      group,
    });

  } catch (error) {
    // Catch duplicate keyword error
    if (error.code === 11000 && error.keyPattern?.keyword) {
      return res.status(400).json({ message: 'Group keyword already exists. Try a different name.' });
    }
    next(error);
  }
};


// PUT /api/v1/groups/:id
export const updateGroup = async (req, res, next) => {
  try {
    let group = await Group.findById(req.params.id);
    if (!group) return res.status(404).json({ message: 'Group not found' });

    if (group.createdBy.toString() !== req.user._id.toString() && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Not authorized to update this group' });
    }

    const keywordsInput = req.body.keywords ?? req.body.keyword;
    if (keywordsInput !== undefined) {
      const keywords = parseKeywords(keywordsInput);
      req.body.keywords = keywords;
      if (!req.body.keyword && keywords.length > 0) req.body.keyword = keywords[0];
    }

    if (req.body.keyword) {
      const slug = slugify(req.body.keyword);
      req.body.keyword = slug.length >= 4 ? slug : group.keyword;
    }

    if (req.file) req.body.imageUrl = getImageUrl(req.file);

    if (typeof req.body.description === 'string') {
      req.body.description = req.body.description.trim();
    }

    group = await Group.findByIdAndUpdate(req.params.id, req.body, { new: true, runValidators: true })
      .populate('createdBy', 'name email avatarUrl')
      .populate('members', 'name email avatarUrl');

    res.json({ success: true, group });
  } catch (error) {
    if (error.code === 11000 && error.keyPattern?.keyword) {
      return res.status(400).json({ message: 'Keyword already exists, try another one' });
    }
    next(error);
  }
};

// DELETE /api/v1/groups/:id
export const deleteGroup = async (req, res, next) => {
  try {
    const group = await Group.findById(req.params.id);
    if (!group) return res.status(404).json({ message: 'Group not found' });

    if (group.createdBy.toString() !== req.user._id.toString() && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Not authorized to delete this group' });
    }

    await GroupMessage.deleteMany({ groupId: req.params.id });
    await Group.findByIdAndDelete(req.params.id);

    res.json({ success: true, message: 'Group deleted successfully' });
  } catch (error) {
    next(error);
  }
};

// POST /api/v1/groups/:id/join
export const joinGroup = async (req, res, next) => {
  try {
    const group = await Group.findById(req.params.id);
    if (!group) return res.status(404).json({ message: 'Group not found' });

    if (group.members.includes(req.user._id)) return res.status(400).json({ message: 'Already a member of this group' });

    group.members.push(req.user._id);
    await group.save();

    await group.populate('createdBy', 'name email avatarUrl');
    await group.populate('members', 'name email avatarUrl');

    res.json({ success: true, message: 'Joined group successfully', group });
  } catch (error) {
    next(error);
  }
};

// POST /api/v1/groups/:id/leave
export const leaveGroup = async (req, res, next) => {
  try {
    const group = await Group.findById(req.params.id);
    if (!group) return res.status(404).json({ message: 'Group not found' });

    if (group.createdBy.toString() === req.user._id.toString()) {
      return res.status(400).json({ message: 'Group creator cannot leave the group' });
    }

    group.members = group.members.filter((id) => id.toString() !== req.user._id.toString());
    await group.save();

    await group.populate('createdBy', 'name email avatarUrl');
    await group.populate('members', 'name email avatarUrl');

    res.json({ success: true, message: 'Left group successfully', group });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/groups/:id/members
export const getGroupMembers = async (req, res, next) => {
  try {
    const group = await Group.findById(req.params.id)
      .populate('members', 'name email avatarUrl');

    if (!group) return res.status(404).json({ message: 'Group not found' });

    res.json({ success: true, members: group.members });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/groups/:id/messages
export const getGroupMessages = async (req, res, next) => {
  try {
    const group = await Group.findById(req.params.id);
    if (!group) return res.status(404).json({ message: 'Group not found' });

    if (!group.members.includes(req.user._id) && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Not a member of this group' });
    }

    const messages = await GroupMessage.find({ groupId: req.params.id })
      .populate('senderId', 'name email avatarUrl')
      .sort({ sentAt: -1 })
      .limit(100);

    res.json({ success: true, messages: messages.reverse() });
  } catch (error) {
    next(error);
  }
};

// POST /api/v1/groups/:id/messages
export const sendGroupMessage = async (req, res, next) => {
  try {
    const { content } = req.body;
    if (!content || content.trim().length === 0) return res.status(400).json({ message: 'Message content is required' });

    const group = await Group.findById(req.params.id);
    if (!group) return res.status(404).json({ message: 'Group not found' });

    if (!group.members.includes(req.user._id) && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Not a member of this group' });
    }

    const message = new GroupMessage({
      groupId: req.params.id,
      senderId: req.user._id,
      message: content.trim(),
      attachments: req.body.attachments || [],
    });

    await message.save();
    await message.populate('senderId', 'name email avatarUrl');

    res.status(201).json({ success: true, message });
  } catch (error) {
    next(error);
  }
};
