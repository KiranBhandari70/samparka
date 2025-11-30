import dotenv from 'dotenv';

dotenv.config();

export const config = {
  port: process.env.PORT || 5000,
  mongodbUri: process.env.MONGODB_URI || 'mongodb://localhost:27017/samparka',
  jwtSecret: process.env.JWT_SECRET || 'your-secret-key-change-in-production',
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '7d',
  nodeEnv: process.env.NODE_ENV || 'development',
  corsOrigin: process.env.CORS_ORIGIN || '*',
  // Google OAuth
  googleClientId: process.env.GOOGLE_CLIENT_ID || '',
  googleClientSecret: process.env.GOOGLE_CLIENT_SECRET || '',
  // Email (for password reset)
  emailHost: process.env.EMAIL_HOST || '',
  emailPort: process.env.EMAIL_PORT || 587,
  emailUser: process.env.EMAIL_USER || '',
  emailPassword: process.env.EMAIL_PASSWORD || '',
  // File upload
  uploadPath: process.env.UPLOAD_PATH || './uploads',
  maxFileSize: process.env.MAX_FILE_SIZE || 5242880, // 5MB
  // Esewa Payment
  esewaMerchantCode: process.env.ESEWA_MERCHANT_CODE || 'EPAYTEST',
  esewaVerifyUrl: process.env.ESEWA_VERIFY_URL || 'https://uat.esewa.com.np/epay/transrec',
  // Admin account (for initial seeding)
  adminEmail: process.env.ADMIN_EMAIL || 'admin@samparka.com',
  adminPassword: process.env.ADMIN_PASSWORD || 'Admin@12345',
};

