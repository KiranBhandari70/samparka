import express from "express";
import * as userController from "../controllers/userscontroller.js";
import { authenticate, optionalAuthenticate } from "../middlewares/authmiddlewares.js";

const router = express.Router();

/**
 * User routes
 */

// Public routes (can be accessed without auth, but auth adds context)
router.get("/", optionalAuthenticate, userController.getAllUsers);
router.get("/nearby", optionalAuthenticate, userController.getNearbyUsers);
router.get("/:userId", optionalAuthenticate, userController.getUserById);
router.get("/:userId/stats", optionalAuthenticate, userController.getUserStats);

// Protected routes (require authentication)
router.put("/:userId", authenticate, userController.updateUser);
router.delete("/:userId", authenticate, userController.deleteUser);

export default router;

