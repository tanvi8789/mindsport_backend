import Mood from "../models/moods.js";

export const AddMood = async (req, res) =>{
  try {
    const { userId, date, mood } = req.body;

    if (!userId || !date || mood === undefined) {
      return res.status(400).json({ error: 'userId, date, and mood are required' });
    }

    // Convert incoming date string to MongoDB Date
    const moodDate = new Date(date);
    // Normalize date to UTC midnight to avoid duplicates due to time differences
    moodDate.setUTCHours(0, 0, 0, 0);

    // Check if a mood entry already exists for this user on this date
    let moodEntry = await Mood.findOne({ userId, date: moodDate });

    if (moodEntry) {
      // Update existing entry
      moodEntry.mood = mood;
      await moodEntry.save();
      return res.status(200).json({ message: 'Mood updated successfully', mood: moodEntry });
    }

    // Create new mood entry
    moodEntry = new Mood({ userId, mood, date: moodDate });
    await moodEntry.save();

    res.status(201).json({ message: 'Mood added successfully', mood: moodEntry });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });

  }
};

export const GetMood = async (req, res) => {
  try {
    const { userId, date } = req.body;

    if (!userId || !date) {
      return res.status(400).json({ error: "userId and date are required" });
    }

    // Parse incoming date
    const inputDate = new Date(date);
    const year = inputDate.getUTCFullYear();
    const month = inputDate.getUTCMonth(); // 0-indexed

    // Start and end of month
    const startDate = new Date(Date.UTC(year, month, 1));
    const endDate = new Date(Date.UTC(year, month + 1, 1));

    // Fetch all moods for the month
    const moodsData = await Mood.find({
      userId,
      date: { $gte: startDate, $lt: endDate }
    }).sort({ date: 1 });

    if (!moodsData.length) {
      return res.status(404).json({ message: "No moods found for this month" });
    }

    // Transform into a single object: { "2025-09-01": 5, "2025-09-02": 4 }
    const moods = {};
    moodsData.forEach(entry => {
      const key = entry.date.toISOString().split("T")[0]; // YYYY-MM-DD
      moods[key] = entry.mood;
    });

    res.status(200).json({ moods });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
};

