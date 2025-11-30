import mongoose from 'mongoose';

const categorySchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Category name is required'],
      unique: true,
      trim: true,
      enum: ['music', 'art', 'sports', 'tech', 'social', 'food', 'wellness', 'others'],
    },
    iconUrl: {
      type: String,
    },
  },
  {
    timestamps: true,
  }
);

const Category = mongoose.model('Category', categorySchema);

export default Category;

