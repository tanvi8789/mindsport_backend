import express from "express";
import cors from 'cors';

import userRoutes from "./routes/userRoutes.js"

import moodRoutes from "./routes/moodsRoutes.js"

import userHealthRoutes from "./routes/userHealthRoutes.js"

import { fileURLToPath } from "url";
import path from "path";

const app = express();

// Get __dirname in ES module
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

//basic configuration
app.use(express.json()) //middleware
app.use(express.urlencoded({extended: true , limit:"16kb"}))
app.use(express.static("public"))

//cors configurations
app.use(cors({
    origin: process.env.CORS_ORIGIN?.split(",") || "http://localhost:5173",
    credentials:true,
    methods: ["GET" , "POST" , "PUT" , "PATH" , "DELETE" , "OPTIONS"],
    allowedHeaders : ["Authorization" , "Content-Type"]
}));

app.get("/", (req, res) => {
  // Go one folder up (..), then into views/
  res.sendFile(path.join(__dirname, "..", "views", "index.html"));
});

app.use("/api/users", userRoutes);
app.use("/api/moods" , moodRoutes);
app.use("/api/userHealth" , userHealthRoutes);

export default app;
