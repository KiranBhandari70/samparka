import express from "express";
import * as categoryController from "../controllers/categoriescontroller.js";

const router = express.Router();

/**
 * Category routes
 */

// Public routes
router.get("/", categoryController.getAllCategories);
router.get("/search", categoryController.searchCategories);
router.get("/:categoryId", categoryController.getCategoryById);

// Admin routes (you can add authentication middleware later)
router.post("/", categoryController.createCategory);
router.put("/:categoryId", categoryController.updateCategory);
router.delete("/:categoryId", categoryController.deleteCategory);

export default router;

