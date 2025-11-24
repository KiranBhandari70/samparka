import express from 'express';
import {
  getEvents,
  getEvent,
  createEvent,
  updateEvent,
  deleteEvent,
  joinEvent,
  leaveEvent,
  getEventAttendees,
} from '../controllers/eventController.js';

import { authenticate } from '../middleware/auth.js';
import { upload } from '../middleware/upload.js';   // <-- FIXED

const router = express.Router();

// GET all events
router.get('/', getEvents);

// GET single event
router.get('/:id', getEvent);

// CREATE event
router.post('/', authenticate, upload.single('image'), createEvent);

// UPDATE event
router.put('/:id', authenticate, upload.single('image'), updateEvent);

// DELETE
router.delete('/:id', authenticate, deleteEvent);

// JOIN event
router.post('/:id/join', authenticate, joinEvent);

// LEAVE event
router.post('/:id/leave', authenticate, leaveEvent);

// EVENT ATTENDEES
router.get('/:id/attendees', getEventAttendees);

export default router;
