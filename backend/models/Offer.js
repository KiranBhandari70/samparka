import mongoose from 'mongoose';

const offerSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Offer title is required'],
    trim: true,
    maxlength: [100, 'Title cannot exceed 100 characters'],
  },
  description: {
    type: String,
    required: [true, 'Offer description is required'],
    maxlength: [500, 'Description cannot exceed 500 characters'],
  },
  businessName: {
    type: String,
    required: [true, 'Business name is required'],
    trim: true,
  },
  category: {
    type: String,
    enum: ['food', 'retail', 'entertainment', 'services', 'health', 'travel', 'others'],
    default: 'others',
  },
  discountType: {
    type: String,
    enum: ['percentage', 'fixed_amount', 'free_item', 'buy_one_get_one'],
    required: true,
  },
  discountValue: {
    type: Number,
    required: true,
    min: 0,
  },
  pointsRequired: {
    type: Number,
    required: [true, 'Points required is mandatory'],
    min: [1, 'Points required must be at least 1'],
  },
  imageUrl: {
    type: String,
  },
  termsAndConditions: {
    type: String,
    maxlength: [1000, 'Terms and conditions cannot exceed 1000 characters'],
  },
  validFrom: {
    type: Date,
    default: Date.now,
  },
  validUntil: {
    type: Date,
    required: [true, 'Expiry date is required'],
  },
  maxRedemptions: {
    type: Number,
    default: null, // null means unlimited
    min: 1,
  },
  currentRedemptions: {
    type: Number,
    default: 0,
    min: 0,
  },
  isActive: {
    type: Boolean,
    default: true,
  },
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  location: {
    type: {
      type: String,
      enum: ['Point'],
      default: 'Point',
    },
    coordinates: {
      type: [Number], // [longitude, latitude]
      default: [0, 0],
    },
    address: String,
    city: String,
  },
  contactInfo: {
    phone: String,
    email: String,
    website: String,
  },
}, {
  timestamps: true,
});

// Indexes
offerSchema.index({ 'location.coordinates': '2dsphere' });
offerSchema.index({ category: 1, isActive: 1 });
offerSchema.index({ pointsRequired: 1 });
offerSchema.index({ validUntil: 1 });
offerSchema.index({ createdBy: 1 });

// Virtual for checking if offer is expired
offerSchema.virtual('isExpired').get(function() {
  return this.validUntil < new Date();
});

// Virtual for checking if offer is available (not expired and not maxed out)
offerSchema.virtual('isAvailable').get(function() {
  if (!this.isActive || this.isExpired) return false;
  if (this.maxRedemptions && this.currentRedemptions >= this.maxRedemptions) return false;
  return true;
});

// Virtual for discount display text
offerSchema.virtual('discountText').get(function() {
  switch (this.discountType) {
    case 'percentage':
      return `${this.discountValue}% OFF`;
    case 'fixed_amount':
      return `NPR ${this.discountValue} OFF`;
    case 'free_item':
      return 'Free Item';
    case 'buy_one_get_one':
      return 'Buy 1 Get 1';
    default:
      return 'Special Offer';
  }
});

// Ensure virtuals are included in JSON
offerSchema.set('toJSON', { virtuals: true });

export default mongoose.model('Offer', offerSchema);
