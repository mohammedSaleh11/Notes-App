const Note = require("../models/noteModel");
const APIFeatures = require("../utils/apiFeatures");

// Get all notes
exports.getNotes = async (req, res) => {
  try {
    // Step 1: Create a query based on the incoming request
    const queryObj = { ...req.query }; // Create a shallow copy of req.query

    // Step 3: Create APIFeatures instance with the baseQuery
    const features = new APIFeatures(Note.find(), req.query)
      .sort()       // Apply sorting
      .limitFields(); // Apply field limiting

    // Step 4: Fetch all filtered notes
    let notes = await features.query;

    // Step 5: Additional filtering by title if provided
    if (queryObj.title) {
      notes = notes.filter(note => 
        note.title.toLowerCase().includes(queryObj.title.toLowerCase())
      ); // Case-insensitive title filtering
    }

    // Step 6: Handle pagination after filtering
    const page = req.query.page * 1 || 1;
    const limit = req.query.limit * 1 || 100;
    const skip = (page - 1) * limit;

    // Step 7: Paginate the results
    const paginatedNotes = notes.slice(skip, skip + limit);

    res.status(200).json({
      status: "success",
      requestedAt: req.requestTime,
      results: paginatedNotes.length,
      data: {
        data: paginatedNotes,
      },
    });
  } catch (error) {
    console.error("Error fetching notes:", error); // Log the error
    res.status(500).json({ message: "Error fetching notes", error: error.message });
  }
};


// Get a single note by ID
exports.getNoteById = async (req, res) => {
  try {
    const note = await Note.findById(req.params.id);
    if (!note) {
      return res.status(404).json({ message: "Note not found" });
    }
    res.status(200).json(note);
  } catch (error) {
    res.status(500).json({ message: "Error fetching note", error });
  }
};

// Create a new note
exports.createNote = async (req, res) => {
  const { title, content } = req.body;
  try {
    const newNote = new Note({
      title,
      content,
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    const savedNote = await newNote.save();
    console.log("test3");
    res.status(201).json(savedNote);
  } catch (error) {
    console.error("Error saving the note:", error);
    res
      .status(500)
      .json({ message: "Error creating note", error: error.message });
  }
};

// Update an existing note
exports.updateNote = async (req, res) => {
  try {
    const updatedNote = await Note.findByIdAndUpdate(
      req.params.id,
      {
        title: req.body.title,
        content: req.body.content,
        updatedAt: new Date(),
      },
      // eslint-disable-next-line prettier/prettier
      { new: true }
    );
    if (!updatedNote) {
      return res.status(404).json({ message: "Note not found" });
    }
    res.status(200).json(updatedNote);
  } catch (error) {
    res.status(500).json({ message: "Error updating note", error });
  }
};

// Delete a note
exports.deleteNote = async (req, res) => {
  try {
    const deletedNote = await Note.findByIdAndDelete(req.params.id);
    if (!deletedNote) {
      return res.status(404).json({ message: "Note not found" });
    }
    res.status(200).json({ message: "Note deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: "Error deleting note", error });
  }
};
