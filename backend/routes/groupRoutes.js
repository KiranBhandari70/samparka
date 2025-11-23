import express from 'express';
import {
  getGroups,
  getGroup,
  createGroup,
  updateGroup,
  deleteGroup,
  joinGroup,
  leaveGroup,
  getGroupMembers,
  getGroupMessages,
  sendGroupMessage,
} from '../controllers/groupController.js';
import { authenticate } from '../middleware/auth.js';

const router = express.Router();

router.get('/', getGroups);
router.get('/:id', getGroup);
router.post('/', authenticate, createGroup);
router.put('/:id', authenticate, updateGroup);
router.delete('/:id', authenticate, deleteGroup);
router.post('/:id/join', authenticate, joinGroup);
router.post('/:id/leave', authenticate, leaveGroup);
router.get('/:id/members', getGroupMembers);
router.get('/:id/messages', authenticate, getGroupMessages);
router.post('/:id/messages', authenticate, sendGroupMessage);

export default router;

