import jwt from "jsonwebtoken";
import config from "../config/config.js";

/**
 * Token generator utility
 * Handles JWT token creation and verification
 */

/**
 * Generate JWT access token
 * @param {string|Object} payload - User ID or payload object
 * @returns {string} JWT token
 */
export const generateToken = (payload) => {
  if (!config.JWT_SECRET) {
    throw new Error("JWT_SECRET is not configured");
  }

  const tokenPayload = typeof payload === "string" ? { userId: payload } : payload;
  const expiresIn = config.JWT_EXPIRATION || "7d";

  return jwt.sign(tokenPayload, config.JWT_SECRET, {
    expiresIn
  });
};

/**
 * Verify JWT token
 * @param {string} token - JWT token to verify
 * @returns {Object} Decoded token payload
 * @throws {Error} If token is invalid or expired
 */
export const verifyToken = (token) => {
  if (!config.JWT_SECRET) {
    throw new Error("JWT_SECRET is not configured");
  }

  try {
    return jwt.verify(token, config.JWT_SECRET);
  } catch (error) {
    if (error.name === "TokenExpiredError") {
      throw new Error("Token expired");
    } else if (error.name === "JsonWebTokenError") {
      throw new Error("Invalid token");
    }
    throw error;
  }
};

/**
 * Decode JWT token without verification
 * @param {string} token - JWT token to decode
 * @returns {Object} Decoded token payload
 */
export const decodeToken = (token) => {
  return jwt.decode(token);
};

/**
 * Extract token from Authorization header
 * @param {string} authHeader - Authorization header value
 * @returns {string|null} Extracted token or null
 */
export const extractTokenFromHeader = (authHeader) => {
  if (!authHeader) {
    return null;
  }

  const parts = authHeader.split(" ");
  if (parts.length !== 2 || parts[0] !== "Bearer") {
    return null;
  }

  return parts[1];
};

