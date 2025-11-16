import express from "express";
import * as eventController from "../controllers/eventscontroller.js";
import { authenticate, optionalAuthenticate } from "../middlewares/authmiddlewares.js";

const router = express.Router();

/**
 * Event routes
 */

// Public routes (can be accessed without auth)
router.get("/", optionalAuthenticate, eventController.getAllEvents);
router.get("/user/:userId", optionalAuthenticate, eventController.getEventsByUser);
router.get("/:eventId", optionalAuthenticate, eventController.getEventById);

// Protected routes (require authentication)
router.post("/", authenticate, eventController.createEvent);
router.put("/:eventId", authenticate, eventController.updateEvent);
router.delete("/:eventId", authenticate, eventController.deleteEvent);
router.post("/:eventId/join", authenticate, eventController.joinEvent);
router.post("/:eventId/leave", authenticate, eventController.leaveEvent);

export default router;

