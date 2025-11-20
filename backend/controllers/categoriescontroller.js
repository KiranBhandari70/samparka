import * as categoryService from "../services/categoryservice.js";
import { sendSuccess, sendError } from "../utils/response.js";
import { asyncHandler } from "../middlewares/errormiddleware.js";

/**
 * Category controller
 * Handles category-related HTTP requests
 */

/**
 * Create a new category
 * POST /api/categories
 */
export const createCategory = asyncHandler(async (req, res) => {
  const { name, iconUrl } = req.body;

  if (!name) {
    return sendError(res, 400, "Category name is required");
  }

  const category = await categoryService.createCategory({ name, iconUrl });
  return sendSuccess(res, 201, "Category created successfully", category);
});

/**
 * Get all categories
 * GET /api/categories
 */
export const getAllCategories = asyncHandler(async (req, res) => {
  const categories = await categoryService.getAllCategories();
  return sendSuccess(res, 200, "Categories retrieved successfully", categories);
});

/**
 * Get category by ID
 * GET /api/categories/:categoryId
 */
export const getCategoryById = asyncHandler(async (req, res) => {
  const { categoryId } = req.params;
  const category = await categoryService.getCategoryById(categoryId);
  return sendSuccess(res, 200, "Category retrieved successfully", category);
});

/**
 * Update category
 * PUT /api/categories/:categoryId
 */
export const updateCategory = asyncHandler(async (req, res) => {
  const { categoryId } = req.params;
  const updatedCategory = await categoryService.updateCategory(categoryId, req.body);
  return sendSuccess(res, 200, "Category updated successfully", updatedCategory);
});

/**
 * Delete category
 * DELETE /api/categories/:categoryId
 */
export const deleteCategory = asyncHandler(async (req, res) => {
  const { categoryId } = req.params;
  const result = await categoryService.deleteCategory(categoryId);
  return sendSuccess(res, 200, result.message);
});

/**
 * Search categories
 * GET /api/categories/search
 */
export const searchCategories = asyncHandler(async (req, res) => {
  const { q } = req.query;

  if (!q) {
    return sendError(res, 400, "Search query is required");
  }

  const categories = await categoryService.searchCategories(q);
  return sendSuccess(res, 200, "Categories retrieved successfully", categories);
});

