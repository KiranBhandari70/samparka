import express from "express";
import * as commentController from "../controllers/commentscontroller.js";
import { authenticate, optionalAuthenticate } from "../middlewares/authmiddlewares.js";

const router = express.Router();

/**
 * Comment routes
 */

// Public routes (can be accessed without auth)
router.get("/event/:eventId", optionalAuthenticate, commentController.getEventComments);
router.get("/user/:userId", optionalAuthenticate, commentController.getCommentsByUser);
router.get("/:commentId", optionalAuthenticate, commentController.getCommentById);

// Protected routes (require authentication)
router.post("/", authenticate, commentController.createComment);
router.put("/:commentId", authenticate, commentController.updateComment);
router.delete("/:commentId", authenticate, commentController.deleteComment);

export default router;

