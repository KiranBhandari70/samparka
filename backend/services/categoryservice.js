import Category from "../models/categoriesmodel.js";

/**
 * Category service
 * Handles category-related business logic
 */

/**
 * Create a new category
 * @param {Object} categoryData - Category data
 * @returns {Object} Created category
 */
export const createCategory = async (categoryData) => {
  const { name, iconUrl } = categoryData;

  // Check if category already exists
  const existingCategory = await Category.findOne({ name: { $regex: new RegExp(`^${name}$`, "i") } });

  if (existingCategory) {
    const error = new Error("Category already exists");
    error.statusCode = 409;
    throw error;
  }

  const category = new Category({
    name,
    iconUrl
  });

  await category.save();

  return category;
};

/**
 * Get all categories
 * @returns {Array} All categories
 */
export const getAllCategories = async () => {
  const categories = await Category.find().sort({ name: 1 });

  return categories;
};

/**
 * Get category by ID
 * @param {string} categoryId - Category ID
 * @returns {Object} Category object
 */
export const getCategoryById = async (categoryId) => {
  const category = await Category.findById(categoryId);

  if (!category) {
    const error = new Error("Category not found");
    error.statusCode = 404;
    throw error;
  }

  return category;
};

/**
 * Update category
 * @param {string} categoryId - Category ID
 * @param {Object} updateData - Update data
 * @returns {Object} Updated category
 */
export const updateCategory = async (categoryId, updateData) => {
  const category = await Category.findById(categoryId);

  if (!category) {
    const error = new Error("Category not found");
    error.statusCode = 404;
    throw error;
  }

  // Check if name is being updated and already exists
  if (updateData.name && updateData.name !== category.name) {
    const existingCategory = await Category.findOne({
      name: { $regex: new RegExp(`^${updateData.name}$`, "i") },
      _id: { $ne: categoryId }
    });

    if (existingCategory) {
      const error = new Error("Category name already exists");
      error.statusCode = 409;
      throw error;
    }
  }

  // Update fields
  if (updateData.name !== undefined) {
    category.name = updateData.name;
  }
  if (updateData.iconUrl !== undefined) {
    category.iconUrl = updateData.iconUrl;
  }

  await category.save();

  return category;
};

/**
 * Delete category
 * @param {string} categoryId - Category ID
 * @returns {Object} Deletion result
 */
export const deleteCategory = async (categoryId) => {
  const category = await Category.findByIdAndDelete(categoryId);

  if (!category) {
    const error = new Error("Category not found");
    error.statusCode = 404;
    throw error;
  }

  return { message: "Category deleted successfully" };
};

/**
 * Search categories by name
 * @param {string} searchTerm - Search term
 * @returns {Array} Matching categories
 */
export const searchCategories = async (searchTerm) => {
  const categories = await Category.find({
    name: { $regex: searchTerm, $options: "i" }
  }).sort({ name: 1 });

  return categories;
};

