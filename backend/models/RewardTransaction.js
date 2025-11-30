import mongoose from 'mongoose';

const rewardTransactionSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  type: {
    type: String,
    enum: ['earned', 'redeemed'],
    required: true,
  },
  source: {
    type: String,
    enum: ['ticket_purchase', 'event_attendance', 'event_hosting', 'partner_redemption', 'admin_adjustment'],
    required: true,
  },
  amount: {
    type: Number,
    required: true,
  },
  description: {
    type: String,
    required: true,
  },
  relatedEventId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Event',
  },
  relatedPaymentId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Payment',
  },
  metadata: {
    ticketAmount: Number,
    ticketCount: Number,
    tierLabel: String,
    partnerName: String,
    adminNote: String,
  },
}, {
  timestamps: true,
});

// Index for efficient queries
rewardTransactionSchema.index({ userId: 1, createdAt: -1 });
rewardTransactionSchema.index({ type: 1, source: 1 });

export default mongoose.model('RewardTransaction', rewardTransactionSchema);
