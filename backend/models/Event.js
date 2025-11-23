import mongoose from 'mongoose';

const ticketTierSchema = new mongoose.Schema({
  label: {
    type: String,
    required: true,
  },
  price: {
    type: Number,
    default: 0.0,
    min: 0,
  },
  currency: {
    type: String,
    default: 'NPR',
  },
  rewardPoints: {
    type: Number,
    min: 0,
  },
}, { _id: false });

const eventLocationSchema = new mongoose.Schema({
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
  address: {
    type: String,
  },
}, { _id: false });

const eventSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, 'Event title is required'],
      trim: true,
    },
    description: {
      type: String,
      maxlength: [2000, 'Description cannot exceed 2000 characters'],
    },
    category: {
      type: String,
      enum: ['music', 'art', 'sports', 'tech', 'social', 'food', 'wellness', 'others'],
      default: 'others',
    },
    startsAt: {
      type: Date,
      required: [true, 'Event start time is required'],
    },
    endsAt: {
      type: Date,
    },
    capacity: {
      type: Number,
      default: 50,
      min: [1, 'Capacity must be at least 1'],
    },
    imageUrl: {
      type: String,
    },
    tags: {
      type: [String],
      default: [],
    },
    ticketTiers: {
      type: [ticketTierSchema],
      default: [],
    },
    rewardBoost: {
      type: Number,
      default: 50.0,
      min: 0,
    },
    isSponsored: {
      type: Boolean,
      default: false,
    },
    location: {
      type: eventLocationSchema,
    },
    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    attendees: {
      type: [mongoose.Schema.Types.ObjectId],
      ref: 'User',
      default: [],
    },
    commentCount: {
      type: Number,
      default: 0,
    },
  },
  {
    timestamps: true,
  }
);

// Index for geospatial queries
eventSchema.index({ 'location.coordinates': '2dsphere' });

// Index for category and date queries
eventSchema.index({ category: 1, startsAt: 1 });
eventSchema.index({ startsAt: 1 });
eventSchema.index({ createdBy: 1 });

// Text index for search
eventSchema.index({ title: 'text', description: 'text', tags: 'text' });

// Virtual for attendee count
eventSchema.virtual('attendeeCount').get(function () {
  return this.attendees ? this.attendees.length : 0;
});

// Ensure virtuals are included in JSON
eventSchema.set('toJSON', { virtuals: true });

const Event = mongoose.model('Event', eventSchema);

export default Event;

