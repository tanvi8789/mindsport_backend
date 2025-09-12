import User from "../models/user.js";  // your User model
import bcrypt from "bcrypt";

export const registerUser = async (req, res) => {
  try {
    const { userId, name, email, sport, age, gender, password } = req.body;

    // 2️⃣ Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // 3️⃣ Create new user instance
    const newUser = new User({
      userId,
      name,
      email,
      sport,
      age,
      gender,
      password: hashedPassword,  // store hashed password
    });

    // 4️⃣ Save to MongoDB
    await newUser.save();

    // 5️⃣ Send response
    console.log(`${name} registered successfully`);
    res.status(201).json({ message: "User registered successfully" });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
};


export const loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;

    // 1️⃣ Find user by email
    const user = await User.findOne({ email });
    if (!user) return res.status(400).json({ error: "User not found" });

    // 2️⃣ Compare password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(400).json({ error: "Incorrect password" });

    // 3️⃣ Password is correct
    console.log(`${user.name} logged in successfully`);
    res.json({ message: "Logged in successfully" });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
};