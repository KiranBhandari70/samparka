const mongoose = require("mongoose");

const chatMessageSchema = new mongoose.Schema({
  senderId: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
  text: { type: String },
  sentAt: { type: Date, default: Date.now },
  seen: { type: Boolean, default: false }
});

const userChatSchema = new mongoose.Schema({
  participants: [
    { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true }
  ],
  messages: [chatMessageSchema],
  lastMessage: { type: String },
  updatedAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model("UserChat", userChatSchema);
