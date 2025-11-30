import express from 'express';
import {
  getAllOffers,
  getBusinessOffers,
  createOffer,
  updateOffer,
  deleteOffer,
  redeemOffer,
  getOfferCategories,
} from '../controllers/offerController.js';
import { upload } from '../middleware/upload.js';
import { authenticate, authorize } from '../middleware/auth.js';

const router = express.Router();

// Public routes
router.get('/', getAllOffers); // Get all active offers
router.get('/categories', getOfferCategories); // Get offer categories

// Business routes (require business account)
router.get('/business/:businessId', getBusinessOffers); // Get offers by business
router.post(
  '/',
  authenticate,
  authorize('business', 'admin'),
  upload.single('image'),
  createOffer
); // Create offer
router.put(
  '/:offerId',
  authenticate,
  authorize('business', 'admin'),
  upload.single('image'),
  updateOffer
); // Update offer
router.delete(
  '/:offerId',
  authenticate,
  authorize('business', 'admin'),
  deleteOffer
); // Delete offer

// User routes
router.post('/:offerId/redeem', authenticate, redeemOffer); // Redeem offer

export default router;
