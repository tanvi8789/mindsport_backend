import { Router } from 'express';
import {
  registerUser,
  loginUser,
  getUserProfile,
  updateUserProfile
} from '../controllers/userController.js'; // Uses your 'userController.js'
import { protect } from '../middleware/auth.js'; // Uses your 

const router = Router();

// Public routes
router.post('/register', registerUser);
router.post('/login', loginUser);

// Protected routes (require a token)
// These routes will first run the 'protect' middleware
router.get('/me', protect, getUserProfile);
router.put('/me', protect, updateUserProfile); // The PUT route is now correctly defined

export default router;

