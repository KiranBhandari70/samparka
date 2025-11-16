import mongoose from "mongoose";

const eventSchema = new mongoose.Schema(
  {
    title: { type: String, required: true },
    description: { type: String },
    category: { type: String },
    date: { type: Date, required: true },
    day: { type: String },
    time: { type: String },
    cost: { type: Number },
    imageUrl: { type: String },

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

    attendees: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }],

    commentCount: { type: Number, default: 0 }
  },
  { timestamps: true }
);

eventSchema.index({ category: 1 });
eventSchema.index({ date: 1 });

export default mongoose.model("Event", eventSchema);
