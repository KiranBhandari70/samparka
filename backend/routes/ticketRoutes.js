import express from 'express';
import { getUserTickets, getTicketById, cancelTicket } from '../controllers/ticketController.js';

const router = express.Router();

// Get all tickets for a user
router.get('/user/:userId', getUserTickets);

// Get a single ticket by ID
router.get('/:ticketId', getTicketById);

// Cancel a ticket
router.patch('/:ticketId/cancel', cancelTicket);

export default router;

