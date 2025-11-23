import Event from '../models/Event.js';

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

    // Handle image upload
    if (req.file) {
      eventData.imageUrl = `/uploads/${req.file.filename}`;
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

    // Handle image upload
    if (req.file) {
      req.body.imageUrl = `/uploads/${req.file.filename}`;
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

