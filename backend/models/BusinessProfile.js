import mongoose from 'mongoose';

const businessProfileSchema = new mongoose.Schema(
  {
    businessName: {
      type: String,
      required: [true, 'Business name is required'],
      trim: true,
    },
    businessType: {
      type: String,
      required: [true, 'Business type is required'],
      trim: true,
    },
    businessDescription: {
      type: String,
      required: [true, 'Business description is required'],
      maxlength: [1000, 'Description cannot exceed 1000 characters'],
    },
    businessAddress: {
      type: String,
      required: [true, 'Business address is required'],
      trim: true,
    },
    businessPhone: {
      type: String,
      required: [true, 'Business phone is required'],
      trim: true,
    },
    businessEmail: {
      type: String,
      trim: true,
      lowercase: true,
      match: [/^\S+@\S+\.\S+$/, 'Please provide a valid email'],
    },
    businessWebsite: {
      type: String,
      trim: true,
    },
    owner: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true, // One business profile per user
    },
  },
  {
    timestamps: true,
  }
);

// Index for owner to ensure uniqueness
businessProfileSchema.index({ owner: 1 }, { unique: true });

const BusinessProfile = mongoose.model('BusinessProfile', businessProfileSchema);

export default BusinessProfile;

