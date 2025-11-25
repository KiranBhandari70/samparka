import mongoose from 'mongoose';

const paymentSchema = new mongoose.Schema({
  pid: { type: String, required: true, unique: true },
  refId: { type: String, required: true },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  eventId: { type: mongoose.Schema.Types.ObjectId, ref: 'Event', required: true },
  amount: { type: Number, required: true },
  status: { type: String, enum: ['pending', 'success', 'failed'], default: 'pending' },
}, { timestamps: true });

const Payment = mongoose.model('Payment', paymentSchema);

export default Payment;
