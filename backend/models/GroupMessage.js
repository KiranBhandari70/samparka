import mongoose from 'mongoose';

const groupMessageSchema = new mongoose.Schema(
  {
    groupId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Group',
      required: true,
    },
    senderId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    message: {
      type: String,
      required: [true, 'Message content is required'],
      trim: true,
      maxlength: [2000, 'Message cannot exceed 2000 characters'],
    },
    attachments: {
      type: [String],
      default: [],
    },
    sentAt: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: true,
  }
);

// Index for efficient queries
groupMessageSchema.index({ groupId: 1, sentAt: -1 });
groupMessageSchema.index({ senderId: 1 });

const GroupMessage = mongoose.model('GroupMessage', groupMessageSchema);

export default GroupMessage;

