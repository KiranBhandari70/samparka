import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import path from 'path';
import { fileURLToPath } from 'url';
import connectDB from './config/database.js';
import { config } from './config/env.js';
import { errorHandler, notFound } from './middleware/errorHandler.js';

// Routes
import authRoutes from './routes/authRoutes.js';
import userRoutes from './routes/userRoutes.js';
import eventRoutes from './routes/eventRoutes.js';
import groupRoutes from './routes/groupRoutes.js';
import categoryRoutes from './routes/categoryRoutes.js';
import searchRoutes from './routes/searchRoutes.js';
import esewaRoutes from './routes/esewaRoutes.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Connect to database
connectDB();

const app = express();

// Middleware
app.use(cors({
  origin: config.corsOrigin,
  credentials: true,
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan('dev'));

// Serve static files from uploads directory
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Health check (optional)
app.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'Server is running',
    timestamp: new Date().toISOString(),
  });
});

// 🔥 Default root route to fix "Not Found - /"
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'Samparka Backend is Live 🚀',
    timestamp: new Date().toISOString()
  });
});

// API Routes
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/user', userRoutes);
app.use('/api/v1/events', eventRoutes);
app.use('/api/v1/groups', groupRoutes);
app.use('/api/v1/categories', categoryRoutes);
app.use('/api/v1/search', searchRoutes);
app.use('/api/v1/users', userRoutes);
app.use('/api/v1/esewa', esewaRoutes);

// Error handling middleware (must be last)
app.use(notFound);
app.use(errorHandler);

const PORT = config.port;

app.listen(PORT, () => {
  console.log(`Server running in ${config.nodeEnv} mode on port ${PORT}`);
});
