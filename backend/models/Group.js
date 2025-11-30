import mongoose from 'mongoose';

const groupLocationSchema = new mongoose.Schema(
  {
    type: {
      type: String,
      enum: ['Point'],
      default: 'Point',
    },
    coordinates: {
      type: [Number],
      required: true,
    },
    placeName: {
      type: String,
    },
  },
  { _id: false }
);

const groupSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Group name is required'],
      trim: true,
    },
    description: {
      type: String,
      maxlength: [1000, 'Description cannot exceed 1000 characters'],
    },
    keyword: {
      type: String,
      required: true,
      unique: true, // Prevent duplicate keyword errors
      trim: true,
    },
    keywords: {
      type: [String],
      default: [],
    },
    imageUrl: {
      type: String,
      default: '',
    },
    location: {
      type: groupLocationSchema,
    },
    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    members: {
      type: [mongoose.Schema.Types.ObjectId],
      ref: 'User',
      default: [],
    },
  },
  {
    timestamps: true,
  }
);

// Index for geospatial queries
groupSchema.index({ 'location.coordinates': '2dsphere' });

// Index for keywords array (optional, can help with search)
groupSchema.index({ keywords: 1 });

// Text index for search
groupSchema.index({ name: 'text', description: 'text', keywords: 'text' });

// Virtual for member count
groupSchema.virtual('memberCount').get(function () {
  return this.members ? this.members.length : 0;
});

// Ensure virtuals are included in JSON
groupSchema.set('toJSON', { virtuals: true });

const Group = mongoose.model('Group', groupSchema);

export default Group;
