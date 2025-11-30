import mongoose from 'mongoose';

const ticketSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  eventId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Event',
    required: true,
  },
  paymentId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Payment',
    required: true,
  },
  ticketCount: {
    type: Number,
    default: 1,
    min: 1,
  },
  tierLabel: {
    type: String,
    required: true,
  },
  amountPaid: {
    type: Number,
    required: true,
    min: 0,
  },
  ticketNumber: {
    type: String,
    unique: true,
    required: true, // Will be generated in pre-validate hook or set explicitly
  },
  qrCode: {
    type: String,
  },
  status: {
    type: String,
    enum: ['active', 'used', 'cancelled'],
    default: 'active',
  },
}, {
  timestamps: true,
});

// Index for efficient queries
ticketSchema.index({ userId: 1, createdAt: -1 });
ticketSchema.index({ eventId: 1 });
ticketSchema.index({ ticketNumber: 1 });

// Generate ticket number before saving (runs before validation)
ticketSchema.pre('validate', function(next) {
  if (this.isNew && !this.ticketNumber) {
    try {
      // Generate unique ticket number: TKT + timestamp + random
      // Using timestamp + random ensures uniqueness (collision probability is extremely low)
      const timestamp = Date.now().toString(36).toUpperCase();
      const random = Math.random().toString(36).substring(2, 8).toUpperCase();
      const microTime = process.hrtime.bigint().toString(36).toUpperCase();
      this.ticketNumber = `TKT-${timestamp}-${random}-${microTime.slice(-4)}`;
    } catch (error) {
      // Fallback: simple timestamp-based number
      console.error('Error generating ticket number in pre-validate hook:', error);
      this.ticketNumber = `TKT-${Date.now()}-${Math.random().toString(36).substring(2, 8).toUpperCase()}`;
    }
  }
  next();
});

export default mongoose.model('Ticket', ticketSchema);

