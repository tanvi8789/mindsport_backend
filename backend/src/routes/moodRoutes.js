import { Router } from 'express';
import { createOrUpdateMood } from '../controllers/moodController.js';

const router = Router();

router.route('/').post(createOrUpdateMood);

export default router;