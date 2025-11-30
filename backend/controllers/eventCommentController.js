import Event from '../models/Event.js';
import EventComment from '../models/EventComment.js';

export const getEventComments = async (req, res) => {
  try {
    const { id: eventId } = req.params;
    const { limit = 50, offset = 0 } = req.query;

    const comments = await EventComment.find({ event: eventId })
      .populate('user', 'name avatarUrl')
      .sort({ createdAt: -1 })
      .limit(parseInt(limit, 10))
      .skip(parseInt(offset, 10));

    res.json({
      success: true,
      count: comments.length,
      comments,
    });
  } catch (error) {
    console.error('getEventComments error:', error);
    res.status(500).json({
      success: false,
      message: 'Unable to load comments',
      error: error.message,
    });
  }
};

export const createEventComment = async (req, res) => {
  try {
    const { id: eventId } = req.params;
    const { content } = req.body;

    if (!content || !content.trim()) {
      return res.status(400).json({
        success: false,
        message: 'Comment content is required',
      });
    }

    const event = await Event.findById(eventId);
    if (!event) {
      return res.status(404).json({
        success: false,
        message: 'Event not found',
      });
    }

    const comment = await EventComment.create({
      event: eventId,
      user: req.user._id,
      content: content.trim(),
    });

    await Event.findByIdAndUpdate(eventId, { $inc: { commentCount: 1 } });

    await comment.populate('user', 'name avatarUrl');

    res.status(201).json({
      success: true,
      message: 'Comment added',
      comment,
    });
  } catch (error) {
    console.error('createEventComment error:', error);
    res.status(500).json({
      success: false,
      message: 'Unable to add comment',
      error: error.message,
    });
  }
};

export const deleteEventComment = async (req, res) => {
  try {
    const { id: eventId, commentId } = req.params;

    const comment = await EventComment.findById(commentId);
    if (!comment || comment.event.toString() !== eventId) {
      return res.status(404).json({
        success: false,
        message: 'Comment not found',
      });
    }

    const isOwner = comment.user.toString() === req.user._id.toString();
    const isAdmin = req.user.role === 'admin';

    if (!isOwner && !isAdmin) {
      return res.status(403).json({
        success: false,
        message: 'You can only delete your own comments',
      });
    }

    await comment.deleteOne();
    await Event.findByIdAndUpdate(eventId, { $inc: { commentCount: -1 } });

    res.json({
      success: true,
      message: 'Comment deleted',
    });
  } catch (error) {
    console.error('deleteEventComment error:', error);
    res.status(500).json({
      success: false,
      message: 'Unable to delete comment',
      error: error.message,
    });
  }
};

