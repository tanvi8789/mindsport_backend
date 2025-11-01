import UserHealth from "../models/userHealth.js";

// Add or Update User Health (daily upsert)
export const AddOrUpdateUserHealth = async (req, res) => {
  try {
    const { userId, fatigueLevel, sleepHours, sleepQuality, stress } = req.body;

    if (
      !userId ||
      fatigueLevel === undefined ||
      sleepHours === undefined ||
      sleepQuality === undefined ||
      stress === undefined
    ) {
      return res.status(400).json({ error: "All fields are required" });
    }

    // Normalize date to midnight (one record per day)
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Upsert: find entry for this user & date, update if exists, otherwise create
    const healthEntry = await UserHealth.findOneAndUpdate(
      { userId, date: today },
      { fatigueLevel, sleepHours, sleepQuality, stress, date: today },
      { new: true, upsert: true, runValidators: true }
    );

    res.status(200).json({
      message: "Health data saved successfully",
      data: healthEntry,
    });
  } catch (error) {
    console.error("Error adding/updating user health:", error);
    res.status(500).json({ error: "Server error" });
  }
};

// Get User Health Data for a Specific Month
export const GetUserHealthByMonth = async (req, res) => {
  try {
    const { userId, year, month } = req.body;

    if (!userId || !year || !month) {
      return res.status(400).json({ error: "userId, year, and month are required" });
    }

    // Define start and end of the month
    const startDate = new Date(year, month - 1, 1);
    const endDate = new Date(year, month, 0, 23, 59, 59, 999);

    // Fetch records for that user and month
    const records = await UserHealth.find({
      userId,
      date: { $gte: startDate, $lte: endDate },
    }).lean();

    // Format response { "1-9-2025": {...}, "2-9-2025": {...}, ... }
    const result = {};

    // Initialize all days of the month with null
    const daysInMonth = new Date(year, month, 0).getDate();
    for (let d = 1; d <= daysInMonth; d++) {
      result[`${d}-${month}-${year}`] = null;
    }

    // Fill in actual records
    records.forEach((record) => {
      const dateObj = new Date(record.date);
      const key = `${dateObj.getDate()}-${dateObj.getMonth() + 1}-${dateObj.getFullYear()}`;
      result[key] = {
        fatigueLevel: record.fatigueLevel,
        sleepHours: record.sleepHours,
        sleepQuality: record.sleepQuality,
        stress: record.stress,
      };
    });

    res.status(200).json(result);
  } catch (error) {
    console.error("Error fetching user health data:", error);
    res.status(500).json({ error: "Server error" });
  }
};
