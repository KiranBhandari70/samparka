const mongoose = require("mongoose");

const groupSchema = new mongoose.Schema({
  name: { type: String, required: true },
  description: { type: String },
  keyword: { type: String, required: true },

  location: {
    type: {
      type: String,
      default: "Point"
    },
    coordinates: {
      type: [Number],
      index: "2dsphere"
    },
    placeName: { type: String }
  },

  createdBy: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },

  members: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }],
  memberCount: { type: Number, default: 0 },

  createdAt: { type: Date, default: Date.now }
});

groupSchema.index({ keyword: 1 });

module.exports = mongoose.model("Group", groupSchema);
