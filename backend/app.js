const express = require("express");
const cors = require("cors");
const mongoose = require("mongoose");
const helmet = require("helmet");
const noteRoutes = require("./routes/noteRoutes");
const rateLimit = require("express-rate-limit");
const mongoSanitize = require("express-mongo-sanitize");
const xss = require("xss-clean");

const morgan = require("morgan");

const app = express();

console.log(process.env.NODE_ENV);
if (process.env.NODE_ENV === "development") {
  app.use(morgan("dev"));
}

// Middleware
app.use(cors({ origin: '*' }));
 app.use(express.json());

app.use(helmet());

// const limiter = rateLimit({
//   max: 300,
//   windowMs: 60 * 60 * 1000,
//   message: "Too many requests from this ip, please try again in an hour!",
// });

// app.use("/api", limiter);

app.use(mongoSanitize());
app.use(xss());

// Routes
app.use("/api/notes", noteRoutes);

module.exports = app;
