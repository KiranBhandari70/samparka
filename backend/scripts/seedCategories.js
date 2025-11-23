import mongoose from 'mongoose';
import dotenv from 'dotenv';
import Category from '../models/Category.js';
import connectDB from '../config/database.js';

dotenv.config();

const categories = [
  { name: 'music', iconUrl: null },
  { name: 'art', iconUrl: null },
  { name: 'sports', iconUrl: null },
  { name: 'tech', iconUrl: null },
  { name: 'social', iconUrl: null },
  { name: 'food', iconUrl: null },
  { name: 'wellness', iconUrl: null },
  { name: 'others', iconUrl: null },
];

const seedCategories = async () => {
  try {
    await connectDB();

    // Clear existing categories
    await Category.deleteMany({});

    // Insert categories
    const inserted = await Category.insertMany(categories);

    console.log(`✅ Seeded ${inserted.length} categories`);
    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding categories:', error);
    process.exit(1);
  }
};

seedCategories();

