import Payment from '../models/paymentModel.js';
import Event from '../models/Event.js';
import axios from 'axios';

const ESEWA_MERCHANT_CODE = process.env.ESEWA_MERCHANT_CODE
const ESEWA_SECRET_KEY = process.env.ESEWA_SECRET_KEY
const ESEWA_VERIFY_URL = process.env.ESEWA_VERIFY_URL

export const createPayment = async (req, res) => {
  try {
    const { userId, eventId, amount, refId } = req.body;
    if (!userId || !eventId || !amount || !refId) {
      return res.status(400).json({ success: false, message: 'Missing fields' });
    }

    const pid = 'PID' + Date.now();

    const payment = await Payment.create({
      pid,
      refId,
      userId,
      eventId,
      amount,
      status: 'pending',
    });

    res.status(201).json({ success: true, payment });
  } catch (err) {
    console.error('createPayment error:', err);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

export const verifyPayment = async (req, res) => {
  try {
    const { pid, refId } = req.body;

    const payment = await Payment.findOne({ pid, refId });
    if (!payment) {
      return res.status(404).json({ success: false, message: 'Payment not found' });
    }

    // Prepare form data
    const params = new URLSearchParams();
    params.append('amt', payment.amount.toFixed(2));
    params.append('scd', ESEWA_MERCHANT_CODE);
    params.append('pid', payment.pid);
    params.append('rid', payment.refId);

    // Make verification request to eSewa sandbox
    const response = await axios.post(ESEWA_VERIFY_URL, params.toString(), {
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    });

    const data = response.data;

    const success = typeof data === 'string' && data.includes('Success');

    payment.status = success ? 'success' : 'failed';
    await payment.save();

    if (success) {
      // On success, add user as attendee to event
      const event = await Event.findById(payment.eventId);
      if (event && !event.attendees.includes(payment.userId)) {
        event.attendees.push(payment.userId);
        await event.save();
      }
    }

    res.status(200).json({ success, payment });
  } catch (err) {
    console.error('verifyPayment error:', err);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};
