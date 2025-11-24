import Event from '../models/Event.js';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// @desc    Get all events
// @route   GET /api/v1/events
// @access  Public
export const getEvents = async (req, res, next) => {
  try {
    const {
      category,
      search,
      limit = 20,
      offset = 0,
      sort = 'startsAt',
    } = req.query;

    const query = {};

    if (category) {
      query.category = category;
    }

    if (search) {
      query.$text = { $search: search };
    }

    const events = await Event.find(query)
      .populate('createdBy', 'name email avatarUrl')
      .populate('attendees', 'name email avatarUrl')
      .sort(sort === 'startsAt' ? { startsAt: 1 } : { createdAt: -1 })
      .limit(parseInt(limit))
      .skip(parseInt(offset));

    const total = await Event.countDocuments(query);

    res.json({
      success: true,
      count: events.length,
      total,
      events,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get single event
// @route   GET /api/v1/events/:id
// @access  Public
export const getEvent = async (req, res, next) => {
  try {
    const event = await Event.findById(req.params.id)
      .populate('createdBy', 'name email avatarUrl bio')
      .populate('attendees', 'name email avatarUrl');

    if (!event) {
      return res.status(404).json({ message: 'Event not found' });
    }

    res.json({
      success: true,
      event,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Create event
// @route   POST /api/v1/events
// @access  Private
export const createEvent = async (req, res, next) => {
  try {
    const eventData = {
      ...req.body,
      createdBy: req.user._id,
    };

    // Handle image upload - prioritize file over form field
    if (req.file) {
      const uploadsDir = path.join(__dirname, '..', 'uploads');
      const filePath = path.join(uploadsDir, req.file.filename);
      
      // Verify file was actually saved
      if (fs.existsSync(filePath)) {
        eventData.imageUrl = `/uploads/${req.file.filename}`;
        console.log('Image uploaded and saved:', eventData.imageUrl);
      } else {
        console.error('File was not saved to disk:', req.file.filename);
        return res.status(500).json({ 
          success: false,
          message: 'Failed to save image file' 
        });
      }
    } else if (eventData.imageUrl && eventData.imageUrl.trim() !== '') {
      // Keep existing imageUrl from form if no new file
      console.log('Using existing imageUrl from form:', eventData.imageUrl);
    } else {
      console.log('No image file in request');
      // Remove empty imageUrl
      delete eventData.imageUrl;
    }

    // Parse JSON strings from multipart form data
    if (eventData.location && typeof eventData.location === 'string') {
      try {
        eventData.location = JSON.parse(eventData.location);
      } catch (e) {
        // If parsing fails, keep as is
      }
    }

    if (eventData.tags && typeof eventData.tags === 'string') {
      try {
        eventData.tags = JSON.parse(eventData.tags);
      } catch (e) {
        // If parsing fails, try splitting by comma
        eventData.tags = eventData.tags.split(',').map(t => t.trim()).filter(t => t);
      }
    }

    if (eventData.ticketTiers && typeof eventData.ticketTiers === 'string') {
      try {
        eventData.ticketTiers = JSON.parse(eventData.ticketTiers);
      } catch (e) {
        // If parsing fails, set to empty array
        eventData.ticketTiers = [];
      }
    }

    // Parse numeric fields
    if (eventData.capacity) {
      eventData.capacity = parseInt(eventData.capacity, 10);
    }

    if (eventData.rewardBoost) {
      eventData.rewardBoost = parseFloat(eventData.rewardBoost);
    }

    // Parse boolean fields
    if (eventData.isSponsored !== undefined) {
      eventData.isSponsored = eventData.isSponsored === 'true' || eventData.isSponsored === true;
    }

    const event = new Event(eventData);
    await event.save();

    await event.populate('createdBy', 'name email avatarUrl');

    res.status(201).json({
      success: true,
      event,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Update event
// @route   PUT /api/v1/events/:id
// @access  Private
export const updateEvent = async (req, res, next) => {
  try {
    let event = await Event.findById(req.params.id);

    if (!event) {
      return res.status(404).json({ message: 'Event not found' });
    }

    // Check if user is the creator
    if (event.createdBy.toString() !== req.user._id.toString() && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Not authorized to update this event' });
    }

    // Handle image upload - prioritize file over form field
    if (req.file) {
      const uploadsDir = path.join(__dirname, '..', 'uploads');
      const filePath = path.join(uploadsDir, req.file.filename);
      
      // Verify file was actually saved
      if (fs.existsSync(filePath)) {
        req.body.imageUrl = `/uploads/${req.file.filename}`;
        console.log('Image uploaded and saved for update:', req.body.imageUrl);
      } else {
        console.error('File was not saved to disk:', req.file.filename);
        return res.status(500).json({ 
          success: false,
          message: 'Failed to save image file' 
        });
      }
    } else if (req.body.imageUrl && req.body.imageUrl.trim() !== '' && req.body.imageUrl !== 'null') {
      // Keep existing imageUrl from form if no new file
      console.log('Keeping existing imageUrl from form:', req.body.imageUrl);
    } else {
      // Don't overwrite existing imageUrl with empty string
      console.log('No new image, keeping existing imageUrl');
      delete req.body.imageUrl;
    }

    // Parse JSON strings from multipart form data
    if (req.body.location && typeof req.body.location === 'string') {
      try {
        req.body.location = JSON.parse(req.body.location);
      } catch (e) {
        // If parsing fails, keep as is
      }
    }

    if (req.body.tags && typeof req.body.tags === 'string') {
      try {
        req.body.tags = JSON.parse(req.body.tags);
      } catch (e) {
        // If parsing fails, try splitting by comma
        req.body.tags = req.body.tags.split(',').map(t => t.trim()).filter(t => t);
      }
    }

    if (req.body.ticketTiers && typeof req.body.ticketTiers === 'string') {
      try {
        req.body.ticketTiers = JSON.parse(req.body.ticketTiers);
      } catch (e) {
        // If parsing fails, set to empty array
        req.body.ticketTiers = [];
      }
    }

    // Parse numeric fields
    if (req.body.capacity) {
      req.body.capacity = parseInt(req.body.capacity, 10);
    }

    if (req.body.rewardBoost) {
      req.body.rewardBoost = parseFloat(req.body.rewardBoost);
    }

    // Parse boolean fields
    if (req.body.isSponsored !== undefined) {
      req.body.isSponsored = req.body.isSponsored === 'true' || req.body.isSponsored === true;
    }

    event = await Event.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    ).populate('createdBy', 'name email avatarUrl');

    res.json({
      success: true,
      event,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Delete event
// @route   DELETE /api/v1/events/:id
// @access  Private
export const deleteEvent = async (req, res, next) => {
  try {
    const event = await Event.findById(req.params.id);

    if (!event) {
      return res.status(404).json({ message: 'Event not found' });
    }

    // Check if user is the creator or admin
    if (event.createdBy.toString() !== req.user._id.toString() && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Not authorized to delete this event' });
    }

    await Event.findByIdAndDelete(req.params.id);

    res.json({
      success: true,
      message: 'Event deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Join event
// @route   POST /api/v1/events/:id/join
// @access  Private
export const joinEvent = async (req, res, next) => {
  try {
    const event = await Event.findById(req.params.id);

    if (!event) {
      return res.status(404).json({ message: 'Event not found' });
    }

    // Check if already joined
    if (event.attendees.includes(req.user._id)) {
      return res.status(400).json({ message: 'Already joined this event' });
    }

    // Check capacity
    if (event.attendees.length >= event.capacity) {
      return res.status(400).json({ message: 'Event is at full capacity' });
    }

    event.attendees.push(req.user._id);
    await event.save();

    res.json({
      success: true,
      message: 'Joined event successfully',
      event,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Leave event
// @route   POST /api/v1/events/:id/leave
// @access  Private
export const leaveEvent = async (req, res, next) => {
  try {
    const event = await Event.findById(req.params.id);

    if (!event) {
      return res.status(404).json({ message: 'Event not found' });
    }

    event.attendees = event.attendees.filter(
      (attendeeId) => attendeeId.toString() !== req.user._id.toString()
    );
    await event.save();

    res.json({
      success: true,
      message: 'Left event successfully',
      event,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get event attendees
// @route   GET /api/v1/events/:id/attendees
// @access  Public
export const getEventAttendees = async (req, res, next) => {
  try {
    const event = await Event.findById(req.params.id)
      .populate('attendees', 'name email avatarUrl');

    if (!event) {
      return res.status(404).json({ message: 'Event not found' });
    }

    res.json({
      success: true,
      attendees: event.attendees,
    });
  } catch (error) {
    next(error);
  }
};

