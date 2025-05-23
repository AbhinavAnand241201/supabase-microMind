const express = require('express');
const router = express.Router();
const Journal = require('../models/Journal');
const auth = require('../middleware/auth');

// Create a new journal entry
router.post('/', auth, async (req, res) => {
  try {
    const { content } = req.body;
    const journal = new Journal({
      content,
      userId: req.user._id
    });

    await journal.save();
    res.status(201).json(journal);
  } catch (error) {
    res.status(500).json({ message: 'Error creating journal entry' });
  }
});

// Get all journal entries for the authenticated user
router.get('/', auth, async (req, res) => {
  try {
    const entries = await Journal.find({ userId: req.user._id })
      .sort({ createdAt: -1 });
    res.json(entries);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching journal entries' });
  }
});

module.exports = router; 