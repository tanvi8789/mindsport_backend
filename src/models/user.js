import mongoose from "mongoose"

//Schema
const userSchema = new mongoose.Schema(
  {
    userId: {
      type: String,
      required: true,
      unique: true,
      trim: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
      match: [/^\S+@\S+\.\S+$/, "Please enter a valid email"],
    },
    name: {
      type: String,
      required: true,
      trim: true,
    },
    sport: {
      type: String,
      required: true,
      trim: true,
    },
    age: {
      type: Number,
      required: true,
      min: 1,
    },
    gender: {
      type: String,
      enum: ["Male", "Female"], // restricts values
      required: true,
    },
    password: {
      type: String,
      required: true,
      minlength: 8, // you can adjust
    },
  },
  { timestamps: true }
);

const User = mongoose.model("user" , userSchema);

export default User

