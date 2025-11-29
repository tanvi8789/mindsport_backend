import { Router } from 'express';
import { createOrUpdateMood } from '../controllers/moodController.js';
import { protect } from '../middleware/auth.js'; 

const router = Router();

router.route('/').post(createOrUpdateMood);
router.route('/history').get(protect, getMoodHistory);

export default router;