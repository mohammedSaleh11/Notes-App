const express = require("express");
const {
  getNotes,
  getNoteById,
  createNote,
  updateNote,
  deleteNote,
} = require("../controllers/noteController");

const router = express.Router();

// Route for getting all notes
router.get("/", getNotes);

// Route for getting a single note by ID
router.get("/:id", getNoteById);

// Route for creating a new note
router.post("/", createNote);

// Route for updating an existing note
router.patch("/:id", updateNote);

// Route for deleting a note
router.delete("/:id", deleteNote);
module.exports = router;
