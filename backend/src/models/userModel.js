import mongoose from 'mongoose';

const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true, lowercase: true, trim: true },
  name: { type: String, required: true, trim: true },
  password: { type: String, required: true, minlength: 6 },
  sport: { type: String, required: false, trim: true },
  age: { type: Number, required: false },
  gender: { type: String, enum: ["Male", "Female"], required: false },
  wellnessGoals: { 
    type: [String], // An array of strings
    default: [] 
  },
}, { timestamps: true });

// This creates the index that was failing on your *email* field
userSchema.index({ email: 1 }, { unique: true });

const User = mongoose.model("User", userSchema);

export default User;