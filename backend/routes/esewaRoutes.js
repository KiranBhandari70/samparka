import express from 'express';
import { createPayment, getPaymentHistory, getAllPayments } from '../controllers/esewaController.js';

const router = express.Router();

// Test endpoint
router.get('/test', (req, res) => {
  res.json({ success: true, message: 'Esewa API is working', timestamp: new Date().toISOString() });
});

router.post('/create', createPayment);
router.get('/history/:userId', getPaymentHistory);
router.get('/all', getAllPayments);

export default router;
