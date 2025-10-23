import express from "express";
const router = express.Router();

import { 
    registerUser, 
    loginUser, 
    getUserProfile, 
    updateUserProfile // This was the missing piece
} from "../controllers/userController.js";

// Import the controller functions and the new auth middleware
//import { registerUser, loginUser, getUserProfile } from "../controllers/userController.js";
import authMiddleware from "../middleware/auth.js";

// Public routes
router.post("/register", registerUser);
router.post("/login", loginUser);

// Protected route
// When a request comes to '/me', it first goes through authMiddleware.
// If the token is valid, it then proceeds to the getUserProfile function.
router.get("/me", authMiddleware, getUserProfile);
router.get("/me", authMiddleware, getUserProfile);
// 2. Add the new PUT route for updating the profile.
// We use 'PUT' as it's the standard HTTP verb for updating an entire resource.
router.put("/me", authMiddleware, updateUserProfile);


export default router;
