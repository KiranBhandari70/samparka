import { verifyToken, extractTokenFromHeader } from "../utils/jwt.js";
import { sendUnauthorized, sendForbidden } from "../utils/response.js";
import { asyncHandler } from "./errormiddleware.js";

/**
 * Authentication middleware
 * Validates JWT tokens and attaches user info to request
 */

/**
 * Verify JWT token from Authorization header
 * Attaches decoded token payload to req.user
 */
export const authenticate = asyncHandler(async (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return sendUnauthorized(res, "No authorization token provided");
  }

  const token = extractTokenFromHeader(authHeader);

  if (!token) {
    return sendUnauthorized(res, "Invalid authorization header format. Use: Bearer <token>");
  }

  try {
    const decoded = verifyToken(token);
    req.user = decoded;
    next();
  } catch (error) {
    if (error.message === "Token expired") {
      return sendUnauthorized(res, "Token expired. Please login again.");
    }
    if (error.message === "Invalid token") {
      return sendUnauthorized(res, "Invalid token");
    }
    return sendUnauthorized(res, "Authentication failed");
  }
});

/**
 * Optional authentication middleware
 * Tries to authenticate but doesn't fail if token is missing
 * Attaches decoded token to req.user if valid, otherwise req.user is undefined
 */
export const optionalAuthenticate = asyncHandler(async (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return next();
  }

  const token = extractTokenFromHeader(authHeader);

  if (!token) {
    return next();
  }

  try {
    const decoded = verifyToken(token);
    req.user = decoded;
    next();
  } catch (error) {
    // Silently fail for optional authentication
    next();
  }
});

/**
 * Verify that the authenticated user owns the resource
 * Checks if req.user.userId matches the userId parameter or body field
 */
export const verifyOwnership = (userIdField = "userId") => {
  return asyncHandler(async (req, res, next) => {
    if (!req.user || !req.user.userId) {
      return sendUnauthorized(res, "Authentication required");
    }

    const resourceUserId =
      req.params[userIdField] ||
      req.body[userIdField] ||
      req.query[userIdField] ||
      req.body.createdBy ||
      req.body.userId;

    if (!resourceUserId) {
      return sendForbidden(res, "User ID not found in request");
    }

    if (req.user.userId.toString() !== resourceUserId.toString()) {
      return sendForbidden(res, "You don't have permission to access this resource");
    }

    next();
  });
};

/**
 * Check if user is admin or owns the resource
 * Requires admin role or matching userId
 */
export const requireAdminOrOwner = (userIdField = "userId") => {
  return asyncHandler(async (req, res, next) => {
    if (!req.user || !req.user.userId) {
      return sendUnauthorized(res, "Authentication required");
    }

    // If user is admin, allow access
    if (req.user.role === "admin") {
      return next();
    }

    // Otherwise check ownership
    const resourceUserId =
      req.params[userIdField] ||
      req.body[userIdField] ||
      req.query[userIdField] ||
      req.body.createdBy ||
      req.body.userId;

    if (!resourceUserId) {
      return sendForbidden(res, "User ID not found in request");
    }

    if (req.user.userId.toString() !== resourceUserId.toString()) {
      return sendForbidden(res, "You don't have permission to access this resource");
    }

    next();
  });
};

