import multer from 'multer';
import path from 'path';
import { fileURLToPath } from 'url';
import { config } from '../config/env.js';
import fs from 'fs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Ensure uploads directory exists
const uploadsDir = path.join(__dirname, '..', 'uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// Storage
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadsDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  },
});

// File filter
const fileFilter = (req, file, cb) => {
  // Allowed file extensions
  const allowedExtensions = /\.(jpeg|jpg|png|gif|webp)$/i;
  
  // Allowed MIME types (including variations)
  const allowedMimeTypes = [
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/gif',
    'image/webp',
    'image/x-png', // Some systems use this
    'image/pjpeg', // Some systems use this
    'application/octet-stream', // Sometimes sent when MIME type is unknown but file is valid
  ];

  // Get file extension
  const ext = path.extname(file.originalname).toLowerCase();
  const isValidExt = allowedExtensions.test(ext);
  
  // Check MIME type (case insensitive)
  const mimetype = file.mimetype?.toLowerCase() || '';
  const isValidMime = allowedMimeTypes.includes(mimetype);
  
  // Also check if MIME type starts with 'image/' (covers most image types)
  const isImageMime = mimetype.startsWith('image/');

  // Log for debugging
  console.log('File upload check:', {
    filename: file.originalname,
    mimetype: file.mimetype,
    extension: ext,
    isValidExt,
    isValidMime,
    isImageMime,
  });

  // Accept if:
  // 1. Extension is valid, OR
  // 2. MIME type is valid, OR
  // 3. MIME type starts with 'image/' (covers most image types)
  if (isValidExt || isValidMime || isImageMime) {
    return cb(null, true);
  }

  cb(new Error(`Only image files are allowed. Received: ${file.mimetype || 'unknown'} with extension: ${ext || 'none'}`));
};

export const upload = multer({
  storage,
  limits: { fileSize: config.maxFileSize },
  fileFilter,
});
