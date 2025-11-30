import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Name is required'],
      trim: true,
    },
    email: {
      type: String,
      required: [true, 'Email is required'],
      unique: true,
      lowercase: true,
      trim: true,
      match: [/^\S+@\S+\.\S+$/, 'Please provide a valid email'],
    },
    passwordHash: {
      type: String,
      select: false, // Don't return password by default
    },
    authProvider: {
      type: String,
      enum: ['email', 'google'],
      default: 'email',
    },
    age: {
      type: Number,
      min: [13, 'Age must be at least 13'],
    },
    interests: {
      type: [String],
      default: [],
    },
    bio: {
      type: String,
      maxlength: [500, 'Bio cannot exceed 500 characters'],
    },
    avatarUrl: {
      type: String,
    },
    locationLabel: {
      type: String,
    },
    location: {
      type: {
        type: String,
        enum: ['Point'],
        default: 'Point',
        required: true,
      },
      coordinates: {
        type: [Number], // [longitude, latitude]
        required: true,
        default: [0, 0], // optional default if not provided
      },
    },
    role: {
      type: String,
      enum: ['member', 'admin', 'business'],
      default: 'member',
    },
    verificationStatus: {
      type: String,
      enum: ['not_submitted', 'pending', 'approved', 'rejected'],
      default: 'not_submitted',
    },
    verified: {
      type: Boolean,
      default: false,
    },
    // Verification documents
    verificationData: {
      phoneNumber: {
        type: String,
        trim: true,
      },
      citizenshipFrontUrl: {
        type: String,
      },
      citizenshipBackUrl: {
        type: String,
      },
      submittedAt: {
        type: Date,
      },
      reviewedAt: {
        type: Date,
      },
      reviewedBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
      },
      rejectionReason: {
        type: String,
        maxlength: [500, 'Rejection reason cannot exceed 500 characters'],
      },
    },
    rewardBalance: {
      type: Number,
      default: 0.0,
      min: 0,
    },
    blocked: {
      type: Boolean,
      default: false,
    },
    businessProfile: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'BusinessProfile',
    },
  },
  {
    timestamps: true,
  }
);

// Index for geospatial queries
userSchema.index({ location: '2dsphere' });

// Index for email
userSchema.index({ email: 1 });

// Hash password before saving
userSchema.methods.hashPassword = async function (password) {
  const salt = await bcrypt.genSalt(10);
  this.passwordHash = await bcrypt.hash(password, salt);
  return this.passwordHash;
};

// Compare password
userSchema.methods.comparePassword = async function (password) {
  if (!this.passwordHash) return false;
  return await bcrypt.compare(password, this.passwordHash);
};

// Remove sensitive data when returning user
userSchema.methods.toJSON = function () {
  const obj = this.toObject();
  delete obj.passwordHash;
  return obj;
};

const User = mongoose.model('User', userSchema);

export default User;
