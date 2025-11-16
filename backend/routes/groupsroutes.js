import express from "express";
import * as groupController from "../controllers/groupscontroller.js";
import { authenticate, optionalAuthenticate } from "../middlewares/authmiddlewares.js";

const router = express.Router();

/**
 * Group routes
 */

// Public routes (can be accessed without auth)
router.get("/", optionalAuthenticate, groupController.getAllGroups);
router.get("/user/:userId", optionalAuthenticate, groupController.getGroupsByUser);
router.get("/:groupId", optionalAuthenticate, groupController.getGroupById);

// Protected routes (require authentication)
router.post("/", authenticate, groupController.createGroup);
router.put("/:groupId", authenticate, groupController.updateGroup);
router.delete("/:groupId", authenticate, groupController.deleteGroup);
router.post("/:groupId/join", authenticate, groupController.joinGroup);
router.post("/:groupId/leave", authenticate, groupController.leaveGroup);

// Group message routes
router.post("/:groupId/messages", authenticate, groupController.createGroupMessage);
router.get("/:groupId/messages", authenticate, groupController.getGroupMessages);

export default router;

