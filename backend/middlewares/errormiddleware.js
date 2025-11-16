import { sendError } from "../utils/response.js";

/**
 * Global error handling middleware
 * Catches all errors and sends standardized error responses
 */

/**
 * Error handling middleware
 * @param {Error} err - Error object
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
export const errorHandler = (err, req, res, next) => {
  // Mongoose validation error
  if (err.name === "ValidationError") {
    const errors = Object.values(err.errors).map((e) => ({
      field: e.path,
      message: e.message
    }));
    return sendError(res, 400, "Validation failed", errors);
  }

  // Mongoose cast error (invalid ObjectId)
  if (err.name === "CastError") {
    return sendError(res, 400, "Invalid ID format");
  }

  // Mongoose duplicate key error
  if (err.code === 11000) {
    const field = Object.keys(err.keyPattern)[0];
    return sendError(res, 409, `${field} already exists`);
  }

  // JWT errors
  if (err.message === "Token expired") {
    return sendError(res, 401, "Token expired");
  }

  if (err.message === "Invalid token") {
    return sendError(res, 401, "Invalid token");
  }

  // Custom application errors with status code
  if (err.statusCode) {
    return sendError(res, err.statusCode, err.message, err.errors);
  }

  // Default error response
  console.error("Error:", err);
  return sendError(
    res,
    500,
    process.env.NODE_ENV === "production" ? "Internal server error" : err.message
  );
};

/**
 * Async handler wrapper
 * Wraps async route handlers to automatically catch errors
 * @param {Function} fn - Async function to wrap
 * @returns {Function} Wrapped function
 */
export const asyncHandler = (fn) => {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};

/**
 * 404 Not Found middleware
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
export const notFound = (req, res, next) => {
  return sendError(res, 404, `Route ${req.originalUrl} not found`);
};

