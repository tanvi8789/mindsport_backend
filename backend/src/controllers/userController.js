import User from "../models/userModel.js";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";

// Helper function to create the JWT Token
const createToken = (userId) => {
  return jwt.sign({ id: userId }, process.env.JWT_SECRET, { expiresIn: "3d" });
};

// --- NEW FUNCTION TO GET USER PROFILE ---
export const getUserProfile = async (req, res) => {
    try {
        // The user's ID was attached to req.user by the authMiddleware
        // We find the user by that ID but exclude their hashed password from the result
        const user = await User.findById(req.user.id).select('-password');
        if (!user) {
            return res.status(404).json({ message: 'User not found.' });
        }
        res.status(200).json(user); // Send the user data back to the app
    } catch (err) {
        console.error("Get User Profile Error:", err);
        res.status(500).json({ message: "Server error." });
    }
};


// --- No changes to the functions below ---

export const registerUser = async (req, res) => {
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
    res.status(201).json({ message: "User registered successfully", token });
  } catch (err) {
    console.error("Registration Error:", err);
    res.status(500).json({ message: "Server error during registration." });
  }
};

export const loginUser = async (req, res) => {
    try {
        const { email, password } = req.body;
        const user = await User.findOne({ email });
        if (!user) return res.status(400).json({ message: "Invalid credentials." });
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) return res.status(400).json({ message: "Invalid credentials." });
        const token = createToken(user._id);
        res.status(200).json({ message: "Logged in successfully", token });
    } catch (err) {
        console.error("Login Error:", err);
        res.status(500).json({ message: "Server error during login." });
    }
};

export const updateUserProfile = async (req, res) => {
    try {
        const userId = req.user.id;
        const updates = req.body;
        
        const updatedUser = await User.findByIdAndUpdate(
            userId,
            { $set: updates },
            { new: true, runValidators: true } 
        ).select('-password');

        if (!updatedUser) {
            return res.status(404).json({ message: "User not found." });
        }

        // --- THIS IS THE FIX ---
        // We add this log to give you clear feedback in your terminal
        // that the function was executed successfully.
        console.log(`✅ Profile updated for user: ${updatedUser.name} (${updatedUser.email})`);

        res.status(200).json({ message: "Profile updated successfully", user: updatedUser });

    } catch (err) {
        console.error("Update Profile Error:", err);
        res.status(500).json({ message: "Server error while updating profile." });
    }
}