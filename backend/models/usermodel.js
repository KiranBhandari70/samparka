const mongoose = require("mongoose");

const userSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    email: { type: String },
    phoneNumber: { type: String },
    passwordHash: { type: String },
    authProvider: { type: String, enum: ["google", "phone"], required: true },
    avatarUrl: { type: String },
    bio: { type: String },

    interests: [{ type: String }],

    location: {
      type: {
        type: String,
        default: "Point"
      },
      coordinates: {
        type: [Number],
        index: "2dsphere"
      }
    },

    verified: { type: Boolean, default: false },
    citizenshipDocUrl: { type: String },

    createdAt: { type: Date, default: Date.now },
    updatedAt: { type: Date, default: Date.now }
  },
  { timestamps: true }
);

userSchema.index({ email: 1 }, { unique: true });

module.exports = mongoose.model("User", userSchema);
