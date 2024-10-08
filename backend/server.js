const dotenv = require("dotenv");

dotenv.config({ path: "./config.env" });
const app = require("./app");
const mongoose = require("mongoose");

const PORT = process.env.PORT || 5000;

// Connect to MongoDB
try {
  const DB = process.env.DATABASE.replace(
    "<PASSWORD>",
    process.env.DATABASE_PASSWORD
  );
  console.log(DB);
  mongoose.connect(DB).then(() => {
    console.log("db connection successful!");
  });
} catch (err) {
  console.error("mongoDb connection error!!", err.message);
  process.exit(1);
}
// Start the server
app.listen(PORT, '0.0.0.0',() => {
  console.log(`Server is running on port ${PORT}`);
});
