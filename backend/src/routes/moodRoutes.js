import { Router } from 'express';
import { createOrUpdateMood, getMoodHistory } from '../controllers/mood.controller.js';
// --- THIS WAS MISSING ---
import { protect } from '../middleware/auth.js'; 

const router = Router();

// POST /api/moods -> Save today's mood
router.route('/').post(createOrUpdateMood);

// GET /api/moods/history -> Get all past moods
// Now 'protect' is defined and this will work
router.route('/history').get(protect, getMoodHistory);

export default router;