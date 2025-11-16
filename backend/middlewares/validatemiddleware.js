import { sendValidationError } from "../utils/response.js";

/**
 * Validation middleware
 * Validates request data against schemas
 */

/**
 * Generic validation middleware
 * @param {Function} validator - Validation function (e.g., from express-validator)
 * @returns {Function} Express middleware
 */
export const validate = (validator) => {
  return async (req, res, next) => {
    try {
      const result = await validator(req);
      if (result !== true) {
        // If validator returns validation result
        if (result.errors && result.errors.length > 0) {
          return sendValidationError(res, result.errors);
        }
      }
      next();
    } catch (error) {
      return sendValidationError(res, [{ message: error.message }]);
    }
  };
};

/**
 * Validate request body
 * @param {Function|Object} schema - Validation schema or validator function
 */
export const validateBody = (schema) => {
  return (req, res, next) => {
    try {
      // If schema is a function (e.g., Joi validator)
      if (typeof schema === "function") {
        const { error, value } = schema.validate(req.body, {
          abortEarly: false,
          stripUnknown: true
        });

        if (error) {
          const errors = error.details.map((detail) => ({
            field: detail.path.join("."),
            message: detail.message
          }));
          return sendValidationError(res, errors);
        }

        req.body = value;
        return next();
      }

      // If schema is an object with validate method
      if (schema && typeof schema.validate === "function") {
        const { error, value } = schema.validate(req.body);

        if (error) {
          const errors = error.details.map((detail) => ({
            field: detail.path.join("."),
            message: detail.message
          }));
          return sendValidationError(res, errors);
        }

        req.body = value;
        return next();
      }

      // Simple object validation
      const errors = [];
      for (const [key, rules] of Object.entries(schema)) {
        const value = req.body[key];

        if (rules.required && (value === undefined || value === null || value === "")) {
          errors.push({
            field: key,
            message: `${key} is required`
          });
        }

        if (value !== undefined && value !== null && rules.type) {
          const valueType = Array.isArray(value) ? "array" : typeof value;
          if (valueType !== rules.type) {
            errors.push({
              field: key,
              message: `${key} must be of type ${rules.type}`
            });
          }
        }

        if (value !== undefined && value !== null && rules.minLength && value.length < rules.minLength) {
          errors.push({
            field: key,
            message: `${key} must be at least ${rules.minLength} characters`
          });
        }

        if (value !== undefined && value !== null && rules.maxLength && value.length > rules.maxLength) {
          errors.push({
            field: key,
            message: `${key} must be at most ${rules.maxLength} characters`
          });
        }
      }

      if (errors.length > 0) {
        return sendValidationError(res, errors);
      }

      next();
    } catch (error) {
      return sendValidationError(res, [{ message: error.message }]);
    }
  };
};

/**
 * Validate request query parameters
 * @param {Object} schema - Validation schema
 */
export const validateQuery = (schema) => {
  return (req, res, next) => {
    try {
      const errors = [];
      for (const [key, rules] of Object.entries(schema)) {
        const value = req.query[key];

        if (rules.required && (value === undefined || value === null || value === "")) {
          errors.push({
            field: key,
            message: `${key} is required`
          });
        }

        if (value !== undefined && value !== null && rules.type) {
          const valueType = Array.isArray(value) ? "array" : typeof value;
          if (valueType !== rules.type) {
            errors.push({
              field: key,
              message: `${key} must be of type ${rules.type}`
            });
          }
        }
      }

      if (errors.length > 0) {
        return sendValidationError(res, errors);
      }

      next();
    } catch (error) {
      return sendValidationError(res, [{ message: error.message }]);
    }
  };
};

/**
 * Validate request parameters
 * @param {Object} schema - Validation schema
 */
export const validateParams = (schema) => {
  return (req, res, next) => {
    try {
      const errors = [];
      for (const [key, rules] of Object.entries(schema)) {
        const value = req.params[key];

        if (rules.required && (value === undefined || value === null || value === "")) {
          errors.push({
            field: key,
            message: `${key} is required`
          });
        }

        if (value !== undefined && value !== null && rules.type === "ObjectId") {
          const ObjectId = /^[0-9a-fA-F]{24}$/;
          if (!ObjectId.test(value)) {
            errors.push({
              field: key,
              message: `${key} must be a valid ObjectId`
            });
          }
        }
      }

      if (errors.length > 0) {
        return sendValidationError(res, errors);
      }

      next();
    } catch (error) {
      return sendValidationError(res, [{ message: error.message }]);
    }
  };
};

