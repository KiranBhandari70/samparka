import * as eventService from "../services/eventservice.js";
import { sendSuccess, sendError } from "../utils/response.js";
import { asyncHandler } from "../middlewares/errormiddleware.js";

/**
 * Event controller
 * Handles event-related HTTP requests
 */

/**
 * Create a new event
 * POST /api/events
 */
export const createEvent = asyncHandler(async (req, res) => {
  if (!req.user || !req.user.userId) {
    return sendError(res, 401, "Authentication required");
  }

  const { title, date } = req.body;

  if (!title || !date) {
    return sendError(res, 400, "Title and date are required");
  }

  const eventData = {
    ...req.body,
    createdBy: req.user.userId
  };

  const event = await eventService.createEvent(eventData);
  return sendSuccess(res, 201, "Event created successfully", event);
});

/**
 * Get all events with pagination and filters
 * GET /api/events
 */
export const getAllEvents = asyncHandler(async (req, res) => {
  const { page, limit, category, search, dateFrom, dateTo, createdBy, longitude, latitude, maxDistance } = req.query;

  const options = {
    page,
    limit,
    category,
    search,
    dateFrom,
    dateTo,
    createdBy,
    longitude,
    latitude,
    maxDistance
  };

  const result = await eventService.getAllEvents(options);
  return sendSuccess(res, 200, "Events retrieved successfully", result.events, result.pagination);
});

/**
 * Get event by ID
 * GET /api/events/:eventId
 */
export const getEventById = asyncHandler(async (req, res) => {
  const { eventId } = req.params;
  const event = await eventService.getEventById(eventId);
  return sendSuccess(res, 200, "Event retrieved successfully", event);
});

/**
 * Update event
 * PUT /api/events/:eventId
 */
export const updateEvent = asyncHandler(async (req, res) => {
  if (!req.user || !req.user.userId) {
    return sendError(res, 401, "Authentication required");
  }

  const { eventId } = req.params;
  const updatedEvent = await eventService.updateEvent(eventId, req.user.userId, req.body);
  return sendSuccess(res, 200, "Event updated successfully", updatedEvent);
});

/**
 * Delete event
 * DELETE /api/events/:eventId
 */
export const deleteEvent = asyncHandler(async (req, res) => {
  if (!req.user || !req.user.userId) {
    return sendError(res, 401, "Authentication required");
  }

  const { eventId } = req.params;
  const result = await eventService.deleteEvent(eventId, req.user.userId);
  return sendSuccess(res, 200, result.message);
});

/**
 * Join event
 * POST /api/events/:eventId/join
 */
export const joinEvent = asyncHandler(async (req, res) => {
  if (!req.user || !req.user.userId) {
    return sendError(res, 401, "Authentication required");
  }

  const { eventId } = req.params;
  const updatedEvent = await eventService.joinEvent(eventId, req.user.userId);
  return sendSuccess(res, 200, "Joined event successfully", updatedEvent);
});

/**
 * Leave event
 * POST /api/events/:eventId/leave
 */
export const leaveEvent = asyncHandler(async (req, res) => {
  if (!req.user || !req.user.userId) {
    return sendError(res, 401, "Authentication required");
  }

  const { eventId } = req.params;
  const updatedEvent = await eventService.leaveEvent(eventId, req.user.userId);
  return sendSuccess(res, 200, "Left event successfully", updatedEvent);
});

/**
 * Get events by user
 * GET /api/events/user/:userId
 */
export const getEventsByUser = asyncHandler(async (req, res) => {
  const { userId } = req.params;
  const { type = "created" } = req.query;

  if (!["created", "attending"].includes(type)) {
    return sendError(res, 400, "Type must be 'created' or 'attending'");
  }

  const events = await eventService.getEventsByUser(userId, type);
  return sendSuccess(res, 200, "User events retrieved successfully", events);
});

