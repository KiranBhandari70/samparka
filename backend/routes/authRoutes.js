import express from 'express';
import {
  register,
  login,
  googleLogin,
  getMe,
  refreshToken,
  logout,
} from '../controllers/authController.js';
import { authenticate } from '../middleware/auth.js';

const router = express.Router();

router.post('/register', register);
router.post('/login', login);
router.post('/google', googleLogin);
router.get('/me', authenticate, getMe);
router.post('/refresh', authenticate, refreshToken);
router.post('/logout', authenticate, logout);

export default router;

