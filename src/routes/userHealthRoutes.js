import express from "express";

const router = express.Router();

import { AddOrUpdateUserHealth , GetUserHealthByMonth } from "../controllers/userHealthController.js";

router.post("/add", AddOrUpdateUserHealth);
router.get("/get" , GetUserHealthByMonth);

export default router;