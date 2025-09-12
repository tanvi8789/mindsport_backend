// mood.js
import mongoose from 'mongoose';

const moodSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true
  },
  mood: {
    type: Number, // 1 to 5
    required: true,
    min: 1,
    max: 5
  },
  date: {
    type: Date, // Use MongoDB Date type
    required: true
  }
});

// Ensure one mood per user per day
moodSchema.index({ username: 1, date: 1 }, { unique: true });

const Mood = mongoose.model('Mood', moodSchema);

export default Mood;
