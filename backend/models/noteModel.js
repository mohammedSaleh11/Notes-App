const mongoose = require("mongoose");
const mongooseFieldEncryption =
  require("mongoose-field-encryption").fieldEncryption;
const crypto = require("crypto");

const noteSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
  },
  content: {
    type: String,
    required: false,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  updatedAt: {
    type: Date,
    default: Date.now,
  },
});

const secret = process.env.ENCRYPTION_SECRET;

noteSchema.plugin(mongooseFieldEncryption, {
  fields: ["title", "content"], // Specify the fields to be encrypted
  secret: secret, // Use the generated secret key
  saltGenerator: function () {
    return crypto.randomBytes(12).toString("base64").slice(0, 16); // Generate a dynamic salt
  },
});

module.exports = mongoose.model("Note", noteSchema);
