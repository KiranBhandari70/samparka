import mongoose from "mongoose";
import config from "./config.js";

const db = {};

db.connect = async () => {
  try {
    await mongoose.connect(config.MONGODB_URI, {
      dbName: "SamparkaDB",
    });

    console.log("🔥 Database connected successfully");
  } catch (error) {
    console.error("❌ Database connection failed:", error.message);
    process.exit(1);
  }
};

db.disconnect = async () => {
  try {
    await mongoose.connection.close();
    console.log("⚡ Database disconnected successfully");
  } catch (error) {
    console.error("❌ Database disconnection failed:", error.message);
  }
};

export default db;
