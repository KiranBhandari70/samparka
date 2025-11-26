import Offer from '../models/Offer.js';
import User from '../models/User.js';
import RewardService from '../services/rewardService.js';

// Get all active offers (for users to browse)
export const getAllOffers = async (req, res) => {
  try {
    const { category, minPoints, maxPoints, limit = 20, offset = 0 } = req.query;

    // Build filter
    const filter = { isActive: true, validUntil: { $gt: new Date() } };
    
    if (category && category !== 'all') {
      filter.category = category;
    }
    
    if (minPoints || maxPoints) {
      filter.pointsRequired = {};
      if (minPoints) filter.pointsRequired.$gte = parseInt(minPoints);
      if (maxPoints) filter.pointsRequired.$lte = parseInt(maxPoints);
    }

    const offers = await Offer.find(filter)
      .populate('createdBy', 'name avatarUrl')
      .sort({ createdAt: -1 })
      .limit(parseInt(limit))
      .skip(parseInt(offset));

    // Filter out expired and maxed out offers
    const availableOffers = offers.filter(offer => offer.isAvailable);

    return res.status(200).json({
      success: true,
      data: availableOffers,
      total: availableOffers.length,
    });
  } catch (error) {
    console.error('getAllOffers error:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message,
    });
  }
};

// Get offers created by a specific business
export const getBusinessOffers = async (req, res) => {
  try {
    const { businessId } = req.params;
    const { includeInactive = false } = req.query;

    const filter = { createdBy: businessId };
    if (!includeInactive) {
      filter.isActive = true;
    }

    const offers = await Offer.find(filter)
      .sort({ createdAt: -1 });

    return res.status(200).json({
      success: true,
      data: offers,
    });
  } catch (error) {
    console.error('getBusinessOffers error:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message,
    });
  }
};

// Create a new offer (business only)
export const createOffer = async (req, res) => {
  try {
    const {
      title,
      description,
      businessName,
      category,
      discountType,
      discountValue,
      pointsRequired,
      termsAndConditions,
      validUntil,
      maxRedemptions,
      location,
      contactInfo,
    } = req.body;

    const authenticatedUserId = req.user?._id?.toString() ?? req.body.userId;

    if (!authenticatedUserId) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required',
      });
    }

    // Verify user is a business or admin
    const user = req.user ?? (await User.findById(authenticatedUserId));
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    if (!['business', 'admin'].includes(user.role)) {
      return res.status(403).json({
        success: false,
        message: 'Only business accounts can create offers',
      });
    }

    // Handle image upload
    let imageUrl = null;
    if (req.file) {
      imageUrl = `/uploads/${req.file.filename}`;
    }

    // Parse location if provided
    let parsedLocation = null;
    if (location) {
      try {
        parsedLocation = typeof location === 'string' ? JSON.parse(location) : location;
      } catch (e) {
        console.log('Invalid location format:', e);
      }
    }

    // Parse contact info if provided
    let parsedContactInfo = null;
    if (contactInfo) {
      try {
        parsedContactInfo = typeof contactInfo === 'string' ? JSON.parse(contactInfo) : contactInfo;
      } catch (e) {
        console.log('Invalid contact info format:', e);
      }
    }

    const offer = await Offer.create({
      title,
      description,
      businessName,
      category,
      discountType,
      discountValue: parseFloat(discountValue),
      pointsRequired: parseInt(pointsRequired),
      imageUrl,
      termsAndConditions,
      validUntil: new Date(validUntil),
      maxRedemptions: maxRedemptions ? parseInt(maxRedemptions) : null,
      location: parsedLocation,
      contactInfo: parsedContactInfo,
      createdBy: authenticatedUserId,
    });

    const populatedOffer = await Offer.findById(offer._id)
      .populate('createdBy', 'name avatarUrl');

    return res.status(201).json({
      success: true,
      message: 'Offer created successfully',
      data: populatedOffer,
    });
  } catch (error) {
    console.error('createOffer error:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message,
    });
  }
};

// Update an offer (business only)
export const updateOffer = async (req, res) => {
  try {
    const { offerId } = req.params;
    const requestUserId = req.user?._id?.toString() ?? req.body.userId;

    const offer = await Offer.findById(offerId);
    if (!offer) {
      return res.status(404).json({
        success: false,
        message: 'Offer not found',
      });
    }

    if (!requestUserId) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required',
      });
    }

    const requester = req.user ?? (await User.findById(requestUserId));
    if (!requester) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    const isOwner = offer.createdBy.toString() === requestUserId.toString();
    const isAdmin = requester.role === 'admin';

    // Check if user owns this offer or is admin
    if (!isOwner && !isAdmin) {
      return res.status(403).json({
        success: false,
        message: 'You can only update your own offers',
      });
    }

    // Handle image upload
    if (req.file) {
      req.body.imageUrl = `/uploads/${req.file.filename}`;
    }

    // Parse JSON fields
    if (req.body.location && typeof req.body.location === 'string') {
      try {
        req.body.location = JSON.parse(req.body.location);
      } catch (e) {
        delete req.body.location;
      }
    }

    if (req.body.contactInfo && typeof req.body.contactInfo === 'string') {
      try {
        req.body.contactInfo = JSON.parse(req.body.contactInfo);
      } catch (e) {
        delete req.body.contactInfo;
      }
    }

    const updatedOffer = await Offer.findByIdAndUpdate(
      offerId,
      req.body,
      { new: true, runValidators: true }
    ).populate('createdBy', 'name avatarUrl');

    return res.status(200).json({
      success: true,
      message: 'Offer updated successfully',
      data: updatedOffer,
    });
  } catch (error) {
    console.error('updateOffer error:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message,
    });
  }
};

// Delete an offer (business only)
export const deleteOffer = async (req, res) => {
  try {
    const { offerId } = req.params;
    const requestUserId = req.user?._id?.toString() ?? req.body.userId;

    const offer = await Offer.findById(offerId);
    if (!offer) {
      return res.status(404).json({
        success: false,
        message: 'Offer not found',
      });
    }

    if (!requestUserId) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required',
      });
    }

    const requester = req.user ?? (await User.findById(requestUserId));
    if (!requester) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    const isOwner = offer.createdBy.toString() === requestUserId.toString();
    const isAdmin = requester.role === 'admin';

    // Check if user owns this offer or is admin
    if (!isOwner && !isAdmin) {
      return res.status(403).json({
        success: false,
        message: 'You can only delete your own offers',
      });
    }

    await Offer.findByIdAndDelete(offerId);

    return res.status(200).json({
      success: true,
      message: 'Offer deleted successfully',
    });
  } catch (error) {
    console.error('deleteOffer error:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message,
    });
  }
};

// Redeem an offer (user spends reward points)
export const redeemOffer = async (req, res) => {
  try {
    const { offerId } = req.params;
    const requestUserId = req.user?._id?.toString() ?? req.body.userId;

    if (!requestUserId) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required',
      });
    }

    const offer = await Offer.findById(offerId);
    if (!offer) {
      return res.status(404).json({
        success: false,
        message: 'Offer not found',
      });
    }

    // Check if offer is available
    if (!offer.isAvailable) {
      return res.status(400).json({
        success: false,
        message: 'This offer is no longer available',
      });
    }

    // Check if user has enough points
    const user = req.user ?? (await User.findById(requestUserId));
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    if (user.rewardBalance < offer.pointsRequired) {
      return res.status(400).json({
        success: false,
        message: 'Insufficient reward points',
        required: offer.pointsRequired,
        available: user.rewardBalance,
      });
    }

    // Redeem the offer
    const rewardResult = await RewardService.deductRewardPoints(
      requestUserId,
      offer.pointsRequired,
      'partner_redemption',
      `Redeemed ${offer.discountText} at ${offer.businessName}`,
      {
        partnerName: offer.businessName,
        offerDescription: offer.title,
      }
    );

    // Increment redemption count
    await Offer.findByIdAndUpdate(offerId, {
      $inc: { currentRedemptions: 1 },
    });

    return res.status(200).json({
      success: true,
      message: 'Offer redeemed successfully',
      data: {
        offer: {
          title: offer.title,
          businessName: offer.businessName,
          discountText: offer.discountText,
        },
        pointsDeducted: offer.pointsRequired,
        newBalance: rewardResult.newBalance,
        redemptionCode: `RDM-${Date.now()}-${offerId.toString().slice(-6).toUpperCase()}`,
      },
    });
  } catch (error) {
    console.error('redeemOffer error:', error);
    
    if (error.message === 'Insufficient reward balance') {
      return res.status(400).json({
        success: false,
        message: 'Insufficient reward points',
      });
    }

    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message,
    });
  }
};

// Get offer categories
export const getOfferCategories = async (req, res) => {
  try {
    const categories = [
      { value: 'food', label: 'Food & Dining' },
      { value: 'retail', label: 'Retail & Shopping' },
      { value: 'entertainment', label: 'Entertainment' },
      { value: 'services', label: 'Services' },
      { value: 'health', label: 'Health & Wellness' },
      { value: 'travel', label: 'Travel & Tourism' },
      { value: 'others', label: 'Others' },
    ];

    return res.status(200).json({
      success: true,
      data: categories,
    });
  } catch (error) {
    console.error('getOfferCategories error:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message,
    });
  }
};
