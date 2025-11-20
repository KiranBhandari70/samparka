import multer from "multer";
import path from "path";
import fs from "fs";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

/**
 * File upload utility
 * Handles file uploads using multer
 */

// Ensure uploads directory exists
const uploadsDir = path.join(__dirname, "../uploads");

if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// Configure storage
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    // Determine subdirectory based on file type
    let subDir = "general";
    
    if (file.fieldname === "avatar") {
      subDir = "avatars";
    } else if (file.fieldname === "eventImage") {
      subDir = "events";
    } else if (file.fieldname === "categoryIcon") {
      subDir = "categories";
    } else if (file.fieldname === "document") {
      subDir = "documents";
    } else if (file.fieldname === "attachment") {
      subDir = "attachments";
    }

    const dir = path.join(uploadsDir, subDir);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    cb(null, dir);
  },
  filename: (req, file, cb) => {
    // Generate unique filename
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    const ext = path.extname(file.originalname);
    const name = path.basename(file.originalname, ext);
    cb(null, `${name}-${uniqueSuffix}${ext}`);
  }
});

// File filter function
const fileFilter = (req, file, cb) => {
  // Allowed file types
  const allowedMimes = {
    image: ["image/jpeg", "image/jpg", "image/png", "image/gif", "image/webp"],
    document: [
      "application/pdf",
      "application/msword",
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    ],
    general: [
      "image/jpeg",
      "image/jpg",
      "image/png",
      "image/gif",
      "image/webp",
      "application/pdf"
    ]
  };

  // Determine allowed types based on field name
  let allowedTypes = allowedMimes.general;
  if (file.fieldname === "avatar" || file.fieldname === "eventImage" || file.fieldname === "categoryIcon") {
    allowedTypes = allowedMimes.image;
  } else if (file.fieldname === "document") {
    allowedTypes = allowedMimes.document;
  }

  if (allowedTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(
      new Error(
        `Invalid file type. Allowed types: ${allowedTypes.join(", ")}`
      ),
      false
    );
  }
};

// Configure multer
const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB limit
  }
});

/**
 * Single file upload middleware
 * @param {string} fieldName - Field name in the form
 * @returns {Function} Multer middleware
 */
export const uploadSingle = (fieldName = "file") => {
  return upload.single(fieldName);
};

/**
 * Multiple files upload middleware
 * @param {string} fieldName - Field name in the form
 * @param {number} maxCount - Maximum number of files
 * @returns {Function} Multer middleware
 */
export const uploadMultiple = (fieldName = "files", maxCount = 5) => {
  return upload.array(fieldName, maxCount);
};

/**
 * Multiple fields upload middleware
 * @param {Array} fields - Array of field configurations
 * @returns {Function} Multer middleware
 */
export const uploadFields = (fields) => {
  return upload.fields(fields);
};

/**
 * Get file URL from uploaded file
 * @param {Object} file - Multer file object
 * @returns {string} File URL
 */
export const getFileUrl = (file) => {
  if (!file) {
    return null;
  }

  // Extract relative path from absolute path
  const relativePath = file.path.replace(path.join(__dirname, "../"), "");
  
  // Convert to URL-friendly path
  return `/${relativePath.replace(/\\/g, "/")}`;
};

/**
 * Delete file from filesystem
 * @param {string} filePath - Path to the file
 * @returns {Promise<boolean>} Success status
 */
export const deleteFile = async (filePath) => {
  try {
    // If filePath is a URL, convert to filesystem path
    let fsPath = filePath;
    if (filePath.startsWith("/")) {
      fsPath = path.join(__dirname, "..", filePath);
    }

    if (fs.existsSync(fsPath)) {
      fs.unlinkSync(fsPath);
      return true;
    }
    return false;
  } catch (error) {
    console.error("Error deleting file:", error);
    return false;
  }
};

/**
 * Error handler for multer errors
 * @param {Error} error - Multer error
 * @returns {Object} Formatted error response
 */
export const handleUploadError = (error) => {
  if (error instanceof multer.MulterError) {
    if (error.code === "LIMIT_FILE_SIZE") {
      return {
        message: "File too large. Maximum size is 10MB",
        code: "FILE_TOO_LARGE"
      };
    }
    if (error.code === "LIMIT_FILE_COUNT") {
      return {
        message: "Too many files. Maximum is 5 files",
        code: "TOO_MANY_FILES"
      };
    }
    if (error.code === "LIMIT_UNEXPECTED_FILE") {
      return {
        message: "Unexpected file field",
        code: "UNEXPECTED_FILE"
      };
    }
  }

  return {
    message: error.message || "File upload error",
    code: "UPLOAD_ERROR"
  };
};

// Pre-configured upload middlewares for common use cases
export const uploadAvatar = uploadSingle("avatar");
export const uploadEventImage = uploadSingle("eventImage");
export const uploadCategoryIcon = uploadSingle("categoryIcon");
export const uploadDocument = uploadSingle("document");
export const uploadAttachments = uploadMultiple("attachment", 5);

export default upload;

