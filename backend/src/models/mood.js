import mongoose from "mongoose";

const moodSchema = new mongoose.Schema({
  // This structure is perfect. It links to a user via their permanent ObjectId.
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User', // This MUST match the model name (e.g., mongoose.model("User", ...))
    required: true,
  },

  // --- CHANGE #1: From Emoji to Keyword ---
  // We're storing a clean keyword for easy data analysis.
  // The `enum` ensures only these predefined values can be saved.
  mood: {
    type: String,
    required: true,
    enum: ['excited', 'happy', 'neutral', 'sad', 'angry'],
    trim: true,
  },
  
  // --- CHANGE #2: Added a 'reason' field ---
  // This allows the user to optionally add context to their mood.
  reason: {
    type: String,
    trim: true,
    default: ''
  },

  sleep: {
    type: Number,
    min: 1,
    max: 10,
    required: false, // Optional for now to prevent breaking old data
    default: 5
  },
  physical: {
    type: Number,
    min: 1,
    max: 10,
    required: false,
    default: 5
  }

  // --- CHANGE #3: Removed the explicit 'date' field ---
  // The `{ timestamps: true }` option below automatically adds `createdAt`
  // and `updatedAt` fields. Using `createdAt` is the standard way to
  // know when an entry was made, and it simplifies your frontend code.

}, { timestamps: true });


// Note: The unique index on `date` has been removed. The "one entry per day"
// rule is better handled in your controller logic before saving.


const Mood = mongoose.model("Mood", moodSchema);

export default Mood;
