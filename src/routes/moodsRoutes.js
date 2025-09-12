import express from "express";

const router = express.Router();

import { AddMood , GetMood} from "../controllers/moodsController.js";

router.post("/add", AddMood);
router.get("/get" , GetMood)

export default router;