import mongoose from 'mongoose';

const reminderSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  title: {
    type: String,
    required: [true, 'Reminder title is required'],
    trim: true,
  },
  time: {
    type: String, // Storing as "HH:mm" (e.g., "08:00" or "18:30")
    required: [true, 'Reminder time is required'],
  },
  days: {
    type: [String], // e.g., ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']
    default: [], // Empty array means it's a one-time reminder
  },
  isActive: {
    type: Boolean, // This is for the on/off toggle
    default: true,
  },
  // This is the key to your "check off" feature.
  // We just store the last date it was completed.
  lastCompleted: {
    type: Date,
    default: null,
  },
}, { timestamps: true });

const Reminder = mongoose.model('Reminder', reminderSchema);

export default Reminder;
