import Ticket from '../models/Ticket.js';
import Event from '../models/Event.js';
import Payment from '../models/paymentModel.js';

// @desc    Get all tickets for a user
// @route   GET /api/v1/tickets/user/:userId
// @access  Private
export const getUserTickets = async (req, res, next) => {
  try {
    const { userId } = req.params;

    console.log('Fetching tickets for user:', userId);

    const tickets = await Ticket.find({ userId, status: { $ne: 'cancelled' } })
      .populate({
        path: 'eventId',
        select: 'title description imageUrl startsAt endsAt location category capacity',
        populate: {
          path: 'createdBy',
          select: 'name avatarUrl',
        },
      })
      .populate('paymentId', 'amount refId createdAt')
      .sort({ createdAt: -1 });

    console.log(`Found ${tickets.length} tickets for user ${userId}`);

    res.json({
      success: true,
      tickets,
      count: tickets.length,
    });
  } catch (error) {
    console.error('Error fetching user tickets:', error);
    next(error);
  }
};

// @desc    Get a single ticket by ID
// @route   GET /api/v1/tickets/:ticketId
// @access  Private
export const getTicketById = async (req, res, next) => {
  try {
    const { ticketId } = req.params;

    const ticket = await Ticket.findById(ticketId)
      .populate({
        path: 'eventId',
        populate: {
          path: 'createdBy',
          select: 'name avatarUrl',
        },
      })
      .populate('paymentId', 'amount refId createdAt')
      .populate('userId', 'name email');

    if (!ticket) {
      return res.status(404).json({
        success: false,
        message: 'Ticket not found',
      });
    }

    res.json({
      success: true,
      ticket,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Cancel a ticket
// @route   PATCH /api/v1/tickets/:ticketId/cancel
// @access  Private
export const cancelTicket = async (req, res, next) => {
  try {
    const { ticketId } = req.params;
    const { userId } = req.body; // User ID from auth middleware

    const ticket = await Ticket.findById(ticketId);

    if (!ticket) {
      return res.status(404).json({
        success: false,
        message: 'Ticket not found',
      });
    }

    // Verify ticket belongs to user
    if (ticket.userId.toString() !== userId) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to cancel this ticket',
      });
    }

    // Check if ticket can be cancelled (not used, not already cancelled)
    if (ticket.status === 'used') {
      return res.status(400).json({
        success: false,
        message: 'Cannot cancel a used ticket',
      });
    }

    if (ticket.status === 'cancelled') {
      return res.status(400).json({
        success: false,
        message: 'Ticket is already cancelled',
      });
    }

    ticket.status = 'cancelled';
    await ticket.save();

    res.json({
      success: true,
      message: 'Ticket cancelled successfully',
      ticket,
    });
  } catch (error) {
    next(error);
  }
};

