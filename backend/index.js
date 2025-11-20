// Load environment variables first
import dotenv from "dotenv";
dotenv.config();

import express from "express";
import cors from "cors";
import morgan from "morgan";
import db from "./config/db.js";
import config from "./config/config.js";
import { errorHandler, notFound } from "./middlewares/errormiddleware.js";

// Import routes
import authRoutes from "./routes/authroutes.js";
import userRoutes from "./routes/usersroutes.js";
import categoryRoutes from "./routes/categoriesroutes.js";
import eventRoutes from "./routes/eventsroutes.js";
import commentRoutes from "./routes/commentsroutes.js";
import groupRoutes from "./routes/groupsroutes.js";
import chatRoutes from "./routes/chatsroutes.js";

// Initialize Express app
const app = express();

// Middleware
app.use(cors());
app.use(morgan("dev"));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check endpoint
app.get("/health", (req, res) => {
  res.status(200).json({
    success: true,
    message: "Server is running",
    timestamp: new Date().toISOString()
  });
});

// API routes
app.use("/api/auth", authRoutes);
app.use("/api/users", userRoutes);
app.use("/api/categories", categoryRoutes);
app.use("/api/events", eventRoutes);
app.use("/api/comments", commentRoutes);
app.use("/api/groups", groupRoutes);
app.use("/api/chats", chatRoutes);

// 404 handler
app.use(notFound);

// Error handling middleware (must be last)
app.use(errorHandler);

// Start server
const PORT = config.PORT || 5000;

const startServer = async () => {
  try {
    // Connect to database
    await db.connect();

    // Start listening
    app.listen(PORT, () => {
      console.log(`Server is running on port ${PORT}`);
      console.log(`Environment: ${process.env.NODE_ENV || "development"}`);
    });
  } catch (error) {
    console.error("Failed to start server:", error);
    process.exit(1);
  }
};

// Handle unhandled promise rejections
process.on("unhandledRejection", (err) => {
  console.error("Unhandled Promise Rejection:", err);
  // Close server & exit process
  process.exit(1);
});

// Handle uncaught exceptions
process.on("uncaughtException", (err) => {
  console.error("Uncaught Exception:", err);
  process.exit(1);
});

// Graceful shutdown
process.on("SIGTERM", async () => {
  console.log("SIGTERM signal received: closing HTTP server");
  await db.disconnect();
  process.exit(0);
});

process.on("SIGINT", async () => {
  console.log("SIGINT signal received: closing HTTP server");
  await db.disconnect();
  process.exit(0);
});

// Start the server
startServer();

export default app;

