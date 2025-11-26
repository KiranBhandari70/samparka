import Payment from '../models/paymentModel.js';
import Event from '../models/Event.js';
import axios from 'axios';
import { config } from '../config/env.js';

const ESEWA_MERCHANT_CODE = config.esewaMerchantCode;
const ESEWA_VERIFY_URL = config.esewaVerifyUrl;

export const createPayment = async (req, res) => {
  try {
    const { userId, eventId, amount, refId, pid, ticketCount = 1, tierLabel } = req.body;
    
    console.log('Payment request received:', { userId, eventId, amount, refId, pid, ticketCount, tierLabel });
    
    if (!userId || !eventId || !amount || !refId || !pid) {
      console.log('Missing required fields:', { userId: !!userId, eventId: !!eventId, amount: !!amount, refId: !!refId, pid: !!pid });
      return res.status(400).json({ success: false, message: 'Missing required fields' });
    }

    // 1️⃣ Create payment with pending status
    console.log('Creating payment record...');
    const payment = await Payment.create({
      pid,
      refId,
      userId,
      eventId,
      amount,
      ticketCount,
      tierLabel,
      status: 'pending',
    });
    console.log('Payment record created:', payment._id);

    // 2️⃣ eSewa verification
    console.log('Starting eSewa verification...');
    const params = new URLSearchParams();
    params.append('amt', Number(amount).toFixed(2));
    params.append('scd', ESEWA_MERCHANT_CODE);
    params.append('pid', pid);
    params.append('rid', refId);

    console.log('eSewa verification params:', {
      amt: Number(amount).toFixed(2),
      scd: ESEWA_MERCHANT_CODE,
      pid,
      rid: refId,
      url: ESEWA_VERIFY_URL
    });

    let success = false;
    let verificationError = null;

    // For development/testing, we'll assume success if we have all required fields
    // In production, you should enable the actual eSewa verification
    const isDevelopment = process.env.NODE_ENV === 'development';
    
    if (isDevelopment) {
      console.log('Development mode: Skipping eSewa verification');
      success = true; // Assume success for development
    } else {
      try {
        const response = await axios.post(ESEWA_VERIFY_URL, params.toString(), {
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
          timeout: 10000, // 10 second timeout
        });
        const data = response.data;
        console.log('eSewa verification response:', data);
        success = typeof data === 'string' && data.toLowerCase().includes('success');
        console.log('Verification result:', success);
      } catch (err) {
        console.error('eSewa verify error:', err.message);
        verificationError = err.message;
      }
    }

    // 3️⃣ Update payment status
    console.log('Updating payment status to:', success ? 'success' : 'failed');
    payment.status = success ? 'success' : 'failed';
    await payment.save();
    console.log('Payment status updated');

    // 4️⃣ Update event attendees and attendeeDetails
    if (success) {
      console.log('Payment successful, updating event attendees...');
      const event = await Event.findById(eventId);
      if (event) {
        // Add user to old attendees array if not present
        if (!event.attendees.some(u => u.toString() === userId.toString())) {
          event.attendees.push(userId);
          console.log('User added to attendees');
        }

        // Add detailed purchase
        event.attendeeDetails.push({
          user: userId,
          tierLabel,
          quantity: ticketCount,
          amountPaid: amount,
        });

        await event.save();
        console.log('Event updated with attendee details');
      } else {
        console.error('Event not found:', eventId);
      }
    } else {
      console.log('Payment failed, not updating event');
    }

    const responseData = { 
      success, 
      payment: {
        id: payment._id,
        status: payment.status,
        amount: payment.amount,
        ticketCount: payment.ticketCount,
        tierLabel: payment.tierLabel
      },
      verificationError
    };

    console.log('Sending response:', responseData);
    return res.status(201).json(responseData);
  } catch (err) {
    console.error('createPayment error:', err);
    return res.status(500).json({ success: false, message: 'Server error', error: err.message });
  }
};

// Get payment history for a user
export const getPaymentHistory = async (req, res) => {
  try {
    const { userId } = req.params;
    
    const payments = await Payment.find({ userId })
      .populate('eventId', 'title imageUrl date')
      .sort({ createdAt: -1 });
    
    return res.status(200).json({ success: true, payments });
  } catch (err) {
    console.error('getPaymentHistory error:', err);
    return res.status(500).json({ success: false, message: 'Server error', error: err.message });
  }
};

// Get all payments (admin)
export const getAllPayments = async (req, res) => {
  try {
    const payments = await Payment.find()
      .populate('userId', 'name email')
      .populate('eventId', 'title imageUrl date')
      .sort({ createdAt: -1 });
    
    return res.status(200).json({ success: true, payments });
  } catch (err) {
    console.error('getAllPayments error:', err);
    return res.status(500).json({ success: false, message: 'Server error', error: err.message });
  }
};