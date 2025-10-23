import express from "express";
import cors from 'cors';
import userRoutes from "./routes/userRoutes.js";
import moodRoutes from "./routes/moodRoutes.js"; // 1. IMPORT THE NEW ROUTES

const app = express();

// ... (your existing middleware configuration) ...
app.use(cors({ origin: process.env.CORS_ORIGIN || "*" }));
app.use(express.json());
app.use(express.urlencoded({extended: true}));


// --- API ROUTES ---
app.use("/api/auth", userRoutes);
app.use("/api/moods", moodRoutes); // 2. TELL THE APP TO USE THEM

app.get("/", (req, res) => {
  res.send("MindSport API is running...");
});

export default app;
