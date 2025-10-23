import dotenv from "dotenv";
import path from 'path';
import { fileURLToPath } from 'url';

// This reliably finds and loads your .env file.
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
dotenv.config({ path: path.resolve(__dirname, '../.env') });

// Now, we can safely import the rest of our app.
import app from "./app.js";
import connectDB from "./db/mongo.js";

// --- THIS IS THE FIX ---
// 1. We read the secret key here, after dotenv has loaded it.
const mongoURI = process.env.MONGO_URI;

// 2. We add a clear error check. If this fails, your .env file is the problem.
if (!mongoURI) {
  console.error("ERROR: MONGO_URI is not defined in your .env file!");
  process.exit(1);
}

// 3. We call connectDB and pass the secret key directly as an argument.
connectDB(mongoURI)
  .then(() => {
    const PORT = process.env.PORT || 3000;
    app.listen(PORT,'0.0.0.0', () => {
      console.log(`Server is running and listening on http://localhost:${PORT}`);
    });
  })
  .catch((err) => {
    console.log("Initial MongoDB connection failed! Server will not start.", err);
  });

