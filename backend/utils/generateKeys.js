const crypto = require("crypto");

// Generate a 32-byte (256-bit) secret key
const secret = crypto.randomBytes(32).toString("hex");

console.log(secret);
