import express from "express";
import * as chatController from "../controllers/chatscontroller.js";
import { authenticate } from "../middlewares/authmiddlewares.js";

const router = express.Router();

/**
 * Chat routes
 * All routes require authentication
 */

router.post("/", authenticate, chatController.getOrCreateChat);
router.get("/", authenticate, chatController.getUserChats);
router.get("/:chatId", authenticate, chatController.getChatById);
router.delete("/:chatId", authenticate, chatController.deleteChat);

// Chat message routes
router.post("/:chatId/messages", authenticate, chatController.sendMessage);
router.get("/:chatId/messages", authenticate, chatController.getChatMessages);
router.put("/:chatId/seen", authenticate, chatController.markMessagesAsSeen);

export default router;

