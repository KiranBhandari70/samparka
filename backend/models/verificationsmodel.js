const mongoose = require("mongoose");

const verificationSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  citizenshipNumber: { type: String },
  documentUrl: { type: String },
  status: { type: String, enum: ["pending", "approved", "rejected"], default: "pending" },
  verifiedAt: { type: Date }
});

module.exports = mongoose.model("Verification", verificationSchema);
