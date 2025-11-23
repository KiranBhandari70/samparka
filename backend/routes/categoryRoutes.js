import express from 'express';
import {
  getCategories,
  createCategory,
} from '../controllers/categoryController.js';
import { authenticate } from '../middleware/auth.js';
import { authorize } from '../middleware/auth.js';

const router = express.Router();

router.get('/', getCategories);
router.post('/', authenticate, authorize('admin'), createCategory);

export default router;

