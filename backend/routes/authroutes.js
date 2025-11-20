import express from "express";
import * as authController from "../controllers/authcontroller.js";
import { authenticate } from "../middlewares/authmiddlewares.js";

const router = express.Router();

/**
 * Authentication routes
 */

// Public routes
router.post("/register", authController.register);
router.post("/login", authController.login);
router.post("/google", authController.googleLogin);

// Protected routes (require authentication)
router.get("/me", authenticate, authController.getMe);
router.put("/profile", authenticate, authController.updateProfile);
router.post("/verification", authenticate, authController.submitVerification);
router.get("/verification/status", authenticate, authController.getVerificationStatus);

export default router;

