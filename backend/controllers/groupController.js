import Group from '../models/Group.js';
import GroupMessage from '../models/GroupMessage.js';

// @desc    Get all groups
// @route   GET /api/v1/groups
// @access  Public
export const getGroups = async (req, res, next) => {
  try {
    const {
      search,
      limit = 20,
      offset = 0,
    } = req.query;

    const query = {};

    if (search) {
      query.$text = { $search: search };
    }

    const groups = await Group.find(query)
      .populate('createdBy', 'name email avatarUrl')
      .populate('members', 'name email avatarUrl')
      .sort({ createdAt: -1 })
      .limit(parseInt(limit))
      .skip(parseInt(offset));

    const total = await Group.countDocuments(query);

    res.json({
      success: true,
      count: groups.length,
      total,
      groups,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get single group
// @route   GET /api/v1/groups/:id
// @access  Public
export const getGroup = async (req, res, next) => {
  try {
    const group = await Group.findById(req.params.id)
      .populate('createdBy', 'name email avatarUrl')
      .populate('members', 'name email avatarUrl');

    if (!group) {
      return res.status(404).json({ message: 'Group not found' });
    }

    res.json({
      success: true,
      group,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Create group
// @route   POST /api/v1/groups
// @access  Private
export const createGroup = async (req, res, next) => {
  try {
    const groupData = {
      ...req.body,
      createdBy: req.user._id,
      members: [req.user._id], // Creator is automatically a member
    };

    const group = new Group(groupData);
    await group.save();

    await group.populate('createdBy', 'name email avatarUrl');
    await group.populate('members', 'name email avatarUrl');

    res.status(201).json({
      success: true,
      group,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Update group
// @route   PUT /api/v1/groups/:id
// @access  Private
export const updateGroup = async (req, res, next) => {
  try {
    let group = await Group.findById(req.params.id);

    if (!group) {
      return res.status(404).json({ message: 'Group not found' });
    }

    // Check if user is the creator
    if (group.createdBy.toString() !== req.user._id.toString() && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Not authorized to update this group' });
    }

    group = await Group.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    )
      .populate('createdBy', 'name email avatarUrl')
      .populate('members', 'name email avatarUrl');

    res.json({
      success: true,
      group,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Delete group
// @route   DELETE /api/v1/groups/:id
// @access  Private
export const deleteGroup = async (req, res, next) => {
  try {
    const group = await Group.findById(req.params.id);

    if (!group) {
      return res.status(404).json({ message: 'Group not found' });
    }

    // Check if user is the creator or admin
    if (group.createdBy.toString() !== req.user._id.toString() && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Not authorized to delete this group' });
    }

    // Delete all messages in the group
    await GroupMessage.deleteMany({ groupId: req.params.id });

    await Group.findByIdAndDelete(req.params.id);

    res.json({
      success: true,
      message: 'Group deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Join group
// @route   POST /api/v1/groups/:id/join
// @access  Private
export const joinGroup = async (req, res, next) => {
  try {
    const group = await Group.findById(req.params.id);

    if (!group) {
      return res.status(404).json({ message: 'Group not found' });
    }

    // Check if already a member
    if (group.members.includes(req.user._id)) {
      return res.status(400).json({ message: 'Already a member of this group' });
    }

    group.members.push(req.user._id);
    await group.save();

    await group.populate('createdBy', 'name email avatarUrl');
    await group.populate('members', 'name email avatarUrl');

    res.json({
      success: true,
      message: 'Joined group successfully',
      group,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Leave group
// @route   POST /api/v1/groups/:id/leave
// @access  Private
export const leaveGroup = async (req, res, next) => {
  try {
    const group = await Group.findById(req.params.id);

    if (!group) {
      return res.status(404).json({ message: 'Group not found' });
    }

    // Can't leave if you're the creator
    if (group.createdBy.toString() === req.user._id.toString()) {
      return res.status(400).json({ message: 'Group creator cannot leave the group' });
    }

    group.members = group.members.filter(
      (memberId) => memberId.toString() !== req.user._id.toString()
    );
    await group.save();

    await group.populate('createdBy', 'name email avatarUrl');
    await group.populate('members', 'name email avatarUrl');

    res.json({
      success: true,
      message: 'Left group successfully',
      group,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get group members
// @route   GET /api/v1/groups/:id/members
// @access  Public
export const getGroupMembers = async (req, res, next) => {
  try {
    const group = await Group.findById(req.params.id)
      .populate('members', 'name email avatarUrl');

    if (!group) {
      return res.status(404).json({ message: 'Group not found' });
    }

    res.json({
      success: true,
      members: group.members,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get group messages
// @route   GET /api/v1/groups/:id/messages
// @access  Private
export const getGroupMessages = async (req, res, next) => {
  try {
    const group = await Group.findById(req.params.id);

    if (!group) {
      return res.status(404).json({ message: 'Group not found' });
    }

    // Check if user is a member
    if (!group.members.includes(req.user._id) && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Not a member of this group' });
    }

    const messages = await GroupMessage.find({ groupId: req.params.id })
      .populate('senderId', 'name email avatarUrl')
      .sort({ sentAt: -1 })
      .limit(100); // Limit to last 100 messages

    res.json({
      success: true,
      messages: messages.reverse(), // Reverse to show oldest first
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Send group message
// @route   POST /api/v1/groups/:id/messages
// @access  Private
export const sendGroupMessage = async (req, res, next) => {
  try {
    const { content } = req.body;

    if (!content || content.trim().length === 0) {
      return res.status(400).json({ message: 'Message content is required' });
    }

    const group = await Group.findById(req.params.id);

    if (!group) {
      return res.status(404).json({ message: 'Group not found' });
    }

    // Check if user is a member
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

    res.status(201).json({
      success: true,
      message,
    });
  } catch (error) {
    next(error);
  }
};

