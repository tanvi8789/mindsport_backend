// --- 1. IMPORTS ---
import express from "express";
import mongoose from "mongoose";
import cors from "cors";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import dotenv from "dotenv";
import moodRoutes from "./routes/moodRoutes.js";
import User from './models/user.model.js';
import { protect } from './middleware/auth.js';
import reminderRoutes from './routes/reminderRoutes.js';

// --- 2. CONFIGURATION ---
dotenv.config();
const app = express();
const PORT = process.env.PORT || 3000;
const MONGO_URI = process.env.MONGO_URI;

// Middleware
app.use(cors());
app.use(express.json());

// --- 4. DATABASE BLUEPRINT (MODEL) ---
// (This is correctly moved to its own file)

// --- 5. API ROUTES ---
const createToken = (userId) => {
  return jwt.sign({ id: userId }, process.env.JWT_SECRET, { expiresIn: "3d" });
};

// ## REGISTER A NEW USER ##
app.post("/api/auth/register", async (req, res) => {
  try {
    const { name, email, password } = req.body;
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: "User with this email already exists." });
    }
    const hashedPassword = await bcrypt.hash(password, 10);
    const newUser = new User({ name, email, password: hashedPassword });
    await newUser.save();
    const token = createToken(newUser._id);
    res.status(201).json({ message: "User registered successfully", token, user: { id: newUser._id, name: newUser.name, email: newUser.email } });
  } catch (err) {
    console.error("Registration Error:", err);
    res.status(500).json({ message: "Server error during registration." });
  }
});

// ## LOGIN AN EXISTING USER ##
app.post("/api/auth/login", async (req, res) => {
    try {
        const { email, password } = req.body;
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(400).json({ message: "Invalid credentials." });
        }
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(400).json({ message: "Invalid credentials." });
        }
        const token = createToken(user._id);
        // Send back user data along with the token
        res.status(200).json({ message: "Logged in successfully", token, user: { id: user._id, name: user.name, email: user.email } });
    } catch (err) {
        console.error("Login Error:", err);
        res.status(500).json({ message: "Server error during login." });
    }
});

// --- THIS IS THE MISSING ROUTE ---
// ## GET CURRENT LOGGED IN USER'S DATA ##
// We use our 'protect' middleware as a gatekeeper.
// It will first check the token, find the user, and attach it to `req.user`.
app.get("/api/auth/me", protect, (req, res) => {
  // The 'protect' middleware has already done the work.
  // We just send back the user object it found.
  res.status(200).json(req.user);
});

app.use("/api/moods", moodRoutes);
app.use("/api/reminders", reminderRoutes);


// --- 3. & 6. DATABASE CONNECTION & SERVER START (THE FIX) ---
if (!MONGO_URI) {
  console.error("FATAL ERROR: MONGO_URI is not defined in environment variables.");
  process.exit(1);
}

console.log("Attempting to connect to MongoDB...");
mongoose.connect(MONGO_URI)
  .then(() => {
    console.log("SUCCESS: MongoDB Connected.");
    
    // Only start the server if the DB connects
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`Server is running and listening on port ${PORT}`);
    });
  })
  .catch((err) => {
    console.error("FATAL ERROR: MongoDB Connection Failed:", err);
    process.exit(1); // Exit the app with a failure code
  });
