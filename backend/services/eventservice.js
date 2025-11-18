import Event from "../models/eventsmodel.js";
import EventComment from "../models/event_commentsmodel.js";

/**
 * Event service
 * Handles event-related business logic
 */

/**
 * Create a new event
 * @param {Object} eventData - Event data
 * @returns {Object} Created event
 */
export const createEvent = async (eventData) => {
  const event = new Event({
    title: eventData.title,
    description: eventData.description,
    category: eventData.category,
    date: eventData.date,
    day: eventData.day,
    time: eventData.time,
    cost: eventData.cost,
    imageUrl: eventData.imageUrl,
    location: eventData.location,
    createdBy: eventData.createdBy,
    attendees: eventData.attendees || []
  });

  await event.save();

  // Populate creator
  await event.populate("createdBy", "name avatarUrl");

  return event;
};

/**
 * Get all events with pagination and filters
 * @param {Object} options - Query options
 * @returns {Object} Events and pagination info
 */
export const getAllEvents = async (options = {}) => {
  const { page = 1, limit = 20, category, search, dateFrom, dateTo, createdBy, longitude, latitude, maxDistance } = options;

  const query = {};

  // Filter by category
  if (category) {
    query.category = category;
  }

  // Filter by creator
  if (createdBy) {
    query.createdBy = createdBy;
  }

  // Search by title or description
  if (search) {
    query.$or = [
      { title: { $regex: search, $options: "i" } },
      { description: { $regex: search, $options: "i" } }
    ];
  }

  // Filter by date range
  if (dateFrom || dateTo) {
    query.date = {};
    if (dateFrom) {
      query.date.$gte = new Date(dateFrom);
    }
    if (dateTo) {
      query.date.$lte = new Date(dateTo);
    }
  }

  // Filter by location (nearby events)
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

  const [events, total] = await Promise.all([
    Event.find(query)
      .populate("createdBy", "name avatarUrl")
      .populate("attendees", "name avatarUrl")
      .skip(skip)
      .limit(limitNum)
      .sort({ date: 1, createdAt: -1 }),
    Event.countDocuments(query)
  ]);

  return {
    events,
    pagination: {
      page: parseInt(page),
      limit: limitNum,
      total,
      pages: Math.ceil(total / limitNum)
    }
  };
};

/**
 * Get event by ID
 * @param {string} eventId - Event ID
 * @returns {Object} Event object
 */
export const getEventById = async (eventId) => {
  const event = await Event.findById(eventId)
    .populate("createdBy", "name avatarUrl email")
    .populate("attendees", "name avatarUrl");

  if (!event) {
    const error = new Error("Event not found");
    error.statusCode = 404;
    throw error;
  }

  return event;
};

/**
 * Update event
 * @param {string} eventId - Event ID
 * @param {string} userId - User ID (for ownership check)
 * @param {Object} updateData - Update data
 * @returns {Object} Updated event
 */
export const updateEvent = async (eventId, userId, updateData) => {
  const event = await Event.findById(eventId);

  if (!event) {
    const error = new Error("Event not found");
    error.statusCode = 404;
    throw error;
  }

  // Check ownership
  if (event.createdBy.toString() !== userId.toString()) {
    const error = new Error("You don't have permission to update this event");
    error.statusCode = 403;
    throw error;
  }

  // Update allowed fields
  const allowedFields = ["title", "description", "category", "date", "day", "time", "cost", "imageUrl", "location"];
  allowedFields.forEach((field) => {
    if (updateData[field] !== undefined) {
      event[field] = updateData[field];
    }
  });

  await event.save();

  // Populate creator
  await event.populate("createdBy", "name avatarUrl");

  return event;
};

/**
 * Delete event
 * @param {string} eventId - Event ID
 * @param {string} userId - User ID (for ownership check)
 * @returns {Object} Deletion result
 */
export const deleteEvent = async (eventId, userId) => {
  const event = await Event.findById(eventId);

  if (!event) {
    const error = new Error("Event not found");
    error.statusCode = 404;
    throw error;
  }

  // Check ownership
  if (event.createdBy.toString() !== userId.toString()) {
    const error = new Error("You don't have permission to delete this event");
    error.statusCode = 403;
    throw error;
  }

  // Delete associated comments
  await EventComment.deleteMany({ eventId });

  await Event.findByIdAndDelete(eventId);

  return { message: "Event deleted successfully" };
};

/**
 * Join event (add user to attendees)
 * @param {string} eventId - Event ID
 * @param {string} userId - User ID
 * @returns {Object} Updated event
 */
export const joinEvent = async (eventId, userId) => {
  const event = await Event.findById(eventId);

  if (!event) {
    const error = new Error("Event not found");
    error.statusCode = 404;
    throw error;
  }

  // Check if user is already an attendee
  if (event.attendees.includes(userId)) {
    const error = new Error("User is already an attendee");
    error.statusCode = 409;
    throw error;
  }

  // Add user to attendees
  event.attendees.push(userId);
  await event.save();

  // Populate attendees
  await event.populate("attendees", "name avatarUrl");

  return event;
};

/**
 * Leave event (remove user from attendees)
 * @param {string} eventId - Event ID
 * @param {string} userId - User ID
 * @returns {Object} Updated event
 */
export const leaveEvent = async (eventId, userId) => {
  const event = await Event.findById(eventId);

  if (!event) {
    const error = new Error("Event not found");
    error.statusCode = 404;
    throw error;
  }

  // Remove user from attendees
  event.attendees = event.attendees.filter((attendeeId) => attendeeId.toString() !== userId.toString());
  await event.save();

  // Populate attendees
  await event.populate("attendees", "name avatarUrl");

  return event;
};

/**
 * Get events by user
 * @param {string} userId - User ID
 * @param {string} type - Type of events ('created' or 'attending')
 * @returns {Array} User events
 */
export const getEventsByUser = async (userId, type = "created") => {
  const query = type === "created" ? { createdBy: userId } : { attendees: userId };

  const events = await Event.find(query)
    .populate("createdBy", "name avatarUrl")
    .populate("attendees", "name avatarUrl")
    .sort({ date: 1 });

  return events;
};

