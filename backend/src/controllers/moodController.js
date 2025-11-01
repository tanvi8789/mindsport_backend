import Mood from '../models/mood.js';

/**
 * @description Creates a new mood entry or updates an existing one for the current day.
 * @route POST /api/v1/moods
 */
export const createOrUpdateMood = async (req, res) => {
  try {
    // 1. Get the user's ID, mood keyword, and reason from the request body.
    const { userId, mood, reason } = req.body;
    
    if (!userId || !mood) {
      return res.status(400).json({ message: "User ID and mood keyword are required." });
    }

    // 2. Determine the start and end of the current day in the server's timezone.
    const today = new Date();
    today.setHours(0, 0, 0, 0); // Start of today

    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1); // Start of tomorrow

    // 3. This is the core logic.
    // We try to find a mood document that matches the userId and was created today.
    // - If it finds one, it updates the 'mood' and 'reason'.
    // - If it doesn't find one, `upsert: true` creates a new document.
    // - `new: true` ensures the updated (or new) document is returned.
    const updatedMood = await Mood.findOneAndUpdate(
      {
        user: userId,
        createdAt: { $gte: today, $lt: tomorrow } // Query for today's entry
      },
      {
        $set: { mood: mood, reason: reason, user: userId } // Data to set on update or create
      },
      {
        upsert: true, // IMPORTANT: Create the document if it doesn't exist
        new: true,    // IMPORTANT: Return the new/updated document
        setDefaultsOnInsert: true
      }
    );

    console.log(`SUCCESS: Mood saved for user ${userId}. Mood: ${mood}`);

    res.status(200).json({
      message: "Mood saved successfully",
      data: updatedMood
    });

  } catch (error) {
    // This will catch validation errors from your model's enum
    console.error("Error in createOrUpdateMood:", error);
    res.status(500).json({ message: "Server error while saving mood", error: error.message });
  }
};
