// --- 1. IMPORTS ---
// We bring in all the necessary packages.
import express from "express";
import mongoose from "mongoose";
import cors from "cors";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import dotenv from "dotenv";

// --- 2. CONFIGURATION ---
// This MUST be at the very top to load our secret keys from the .env file.
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware to allow cross-origin requests (from your Flutter app) and to parse JSON.
app.use(cors());
app.use(express.json());

// --- 3. DATABASE CONNECTION ---
// We connect to the MongoDB Atlas database using the secret key from .env.
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log("SUCCESS: MongoDB Connected..."))
  .catch((err) => console.error("ERROR: MongoDB Connection Failed:", err));

// --- 4. DATABASE BLUEPRINT (MODEL) ---
// This is the structure for our user data.
// It matches the "Quick Fix" we discussed: only name, email, and password are required.
const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true, lowercase: true, trim: true },
  name: { type: String, required: true, trim: true },
  password: { type: String, required: true, minlength: 6 },
  // Optional fields
  sport: { type: String, required: false, trim: true },
  age: { type: Number, required: false },
  gender: { type: String, enum: ["Male", "Female"], required: false },
}, { timestamps: true });

const User = mongoose.model("User", userSchema); // Changed model name to "User" for clarity

// --- 5. API ROUTES (THE DOORS TO OUR SERVER) ---

// This function creates the JWT Token (the "keycard").
const createToken = (userId) => {
  return jwt.sign({ id: userId }, process.env.JWT_SECRET, { expiresIn: "3d" });
};

// ## REGISTER A NEW USER ##
app.post("/api/auth/register", async (req, res) => {
  try {
    const { name, email, password } = req.body;

    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: "User with this email already exists." });
    }

    // Hash the password for security
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create and save the new user
    const newUser = new User({ name, email, password: hashedPassword });
    await newUser.save();

    // Create their login token and send it back
    const token = createToken(newUser._id);
    res.status(201).json({ message: "User registered successfully", token });

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
        res.status(200).json({ message: "Logged in successfully", token });

    } catch (err) {
        console.error("Login Error:", err);
        res.status(500).json({ message: "Server error during login." });
    }
});


// --- 6. START THE SERVER ---
app.listen(PORT, () => {
  console.log(`Server is running and listening on http://localhost:${PORT}`);
});
