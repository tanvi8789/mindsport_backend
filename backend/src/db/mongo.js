import mongoose from "mongoose";

// This function handles the connection to your MongoDB Atlas database.
const connectDB = async () => {
  try {
    // It uses the secret MONGO_URI from your .env file.
    const connectionInstance = await mongoose.connect(process.env.MONGO_URI);
    
    // This success message is crucial for confirming the connection.
    console.log(`SUCCESS: MongoDB Connected at ${connectionInstance.connection.host}`);
    
  } catch (error) {
    // This will show a clear error if the connection fails.
    console.error("ERROR: MongoDB Connection Failed:", error);
    process.exit(1); // Exit the application if we can't connect to the DB
  }
};

// We export the function so it can be used in index.js
export default connectDB;
