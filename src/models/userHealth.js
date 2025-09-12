// models/userHealth.js
import mongoose from "mongoose";

const userHealthSchema = new mongoose.Schema(
  {
    userId: {
      type: String, // use string if you want custom user IDs like "0001"
      required: true,
    },
    fatigueLevel: {
      type: Number,
      min: 0,
      max: 10,
      required: true,
    },
    sleepHours: {
      type: Number,
      min: 0,
      max: 24,
      required: true,
    },
    sleepQuality: {
      type: Number,
      min: 0,
      max: 10,
      required: true,
    },
    stress: {
      type: Number,
      min: 0,
      max: 10,
      required: true,
    },
    date: {
      type: Date, // store as Date object
      required: true,
    },
  },
  {
    versionKey: false, // remove __v
    timestamps: false, // remove createdAt and updatedAt
  }
);

// Ensure only one entry per user per day
userHealthSchema.index({ userId: 1, date: 1 }, { unique: true });

const UserHealth = mongoose.model("UserHealth", userHealthSchema);

export default UserHealth;
