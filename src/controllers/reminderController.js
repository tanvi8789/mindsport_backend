import Reminder from '../models/reminder.model.js';
import mongoose from 'mongoose';

// @desc    Get all reminders for the logged-in user
// @route   GET /api/reminders
export const getReminders = async (req, res) => {
  try {
    const reminders = await Reminder.find({ user: req.user._id }).sort({ time: 1 });
    res.status(200).json(reminders);
  } catch (error) {
    console.error('Error getting reminders:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// @desc    Create a new reminder
// @route   POST /api/reminders
export const createReminder = async (req, res) => {
  try {
    const { title, time, days, isActive } = req.body;

    if (!title || !time) {
      return res.status(400).json({ message: 'Title and time are required' });
    }

    const reminder = new Reminder({
      user: req.user._id,
      title,
      time,
      days,
      isActive,
    });

    const createdReminder = await reminder.save();
    res.status(201).json(createdReminder);
  } catch (error) {
    console.error('Error creating reminder:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// @desc    Update an existing reminder (for title, time, days, or isActive toggle)
// @route   PUT /api/reminders/:id
export const updateReminder = async (req, res) => {
  try {
    const { title, time, days, isActive } = req.body;
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ message: 'Invalid reminder ID' });
    }

    const reminder = await Reminder.findById(id);

    if (!reminder) {
      return res.status(404).json({ message: 'Reminder not found' });
    }

    // Check if the reminder belongs to the user
    if (reminder.user.toString() !== req.user._id.toString()) {
      return res.status(401).json({ message: 'Not authorized' });
    }

    reminder.title = title ?? reminder.title;
    reminder.time = time ?? reminder.time;
    reminder.days = days ?? reminder.days;
    reminder.isActive = isActive ?? reminder.isActive;

    const updatedReminder = await reminder.save();
    res.status(200).json(updatedReminder);
  } catch (error) {
    console.error('Error updating reminder:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// @desc    Delete a reminder
// @route   DELETE /api/reminders/:id
export const deleteReminder = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ message: 'Invalid reminder ID' });
    }

    const reminder = await Reminder.findById(id);

    if (!reminder) {
      return res.status(404).json({ message: 'Reminder not found' });
    }

    if (reminder.user.toString() !== req.user._id.toString()) {
      return res.status(401).json({ message: 'Not authorized' });
    }

    await reminder.deleteOne(); // Use deleteOne() on the document
    res.status(200).json({ message: 'Reminder removed' });
  } catch (error) {
    console.error('Error deleting reminder:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// @desc    "Check off" a reminder for the day
// @route   POST /api/reminders/:id/complete
export const completeReminder = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ message: 'Invalid reminder ID' });
    }

    const reminder = await Reminder.findById(id);

    if (!reminder) {
      return res.status(404).json({ message: 'Reminder not found' });
    }

    if (reminder.user.toString() !== req.user._id.toString()) {
      return res.status(401).json({ message: 'Not authorized' });
    }

    // Set the last completed date to now
    reminder.lastCompleted = new Date();
    
    const updatedReminder = await reminder.save();
    console.log(`SUCCESS: Reminder ${id} marked complete for user ${req.user._id}`);
    res.status(200).json(updatedReminder);

  } catch (error) {
    console.error('Error completing reminder:', error);
    res.status(500).json({ message: 'Server error' });
  }
};
