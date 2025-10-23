import mongoose from "mongoose";

const userSchema = new mongoose.Schema(
  {
    // --- Core Authentication Fields ---
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
      match: [/^\S+@\S+\.\S+$/, "Please enter a valid email"],
    },
    name: {
      type: String,
      required: true,
      trim: true,
    },
    password: {
      type: String,
      required: true,
      minlength: 6,
    },

    // --- Optional User Profile Fields ---
    // These are not required at sign-up and can be added by the user later.
    sport: {
      type: String,
      trim: true,
      default: '', // Provide a default empty string
    },
    age: {
      type: Number,
      min: 1,
    },
    gender: {
      type: String,
      // The enum is expanded to be more inclusive for the profile page.
      enum: ["Male", "Female", "Other", "Prefer not to say"],
    },
    height: {
      type: Number, // Stored in cm
    },
    weight: {
      type: Number, // Stored in kg
    },
  },
  { timestamps: true }
);

// We use "User" (uppercase) as the model name, which is a common convention
// and matches the controller logic we've built.
const User = mongoose.model("User", userSchema);

export default User;

