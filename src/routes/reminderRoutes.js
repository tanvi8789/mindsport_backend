import express from 'express';
import {
  getReminders,
  createReminder,
  updateReminder,
  deleteReminder,
  completeReminder
} from '../controllers/reminderController.js';
import { protect } from '../middleware/auth.js';

const router = express.Router();

// All these routes are protected, meaning the user must be logged in.
router.use(protect);

// Routes for /api/reminders
router.route('/')
  .get(getReminders)
  .post(createReminder);

// Routes for /api/reminders/:id
router.route('/:id')
  .put(updateReminder)
  .delete(deleteReminder);

// Route for /api/reminders/:id/complete
router.route('/:id/complete')
  .post(completeReminder);

export default router;
