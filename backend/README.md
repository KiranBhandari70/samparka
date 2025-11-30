# Samparka Backend API

A RESTful API backend for the Samparka social event platform, built with Node.js, Express, and MongoDB.

## Features

- User authentication (Email/Password & Google OAuth)
- Event management (CRUD operations)
- Group management with messaging
- Category management
- Search functionality
- File upload support
- JWT-based authentication
- Geospatial queries for location-based features

## Tech Stack

- **Node.js** - Runtime environment
- **Express.js** - Web framework
- **MongoDB** - Database
- **Mongoose** - ODM for MongoDB
- **JWT** - Authentication
- **Multer** - File upload handling
- **bcryptjs** - Password hashing

## Project Structure

```
backend/
├── config/          # Configuration files
│   ├── database.js  # MongoDB connection
│   └── env.js       # Environment variables
├── controllers/     # Route controllers
│   ├── authController.js
│   ├── userController.js
│   ├── eventController.js
│   ├── groupController.js
│   └── categoryController.js
├── middleware/      # Custom middleware
│   ├── auth.js      # Authentication middleware
│   ├── errorHandler.js
│   └── upload.js    # File upload middleware
├── models/          # Mongoose models
│   ├── User.js
│   ├── Event.js
│   ├── Group.js
│   ├── GroupMessage.js
│   └── Category.js
├── routes/          # API routes
│   ├── authRoutes.js
│   ├── userRoutes.js
│   ├── eventRoutes.js
│   ├── groupRoutes.js
│   ├── categoryRoutes.js
│   └── searchRoutes.js
├── utils/           # Utility functions
│   └── generateToken.js
├── uploads/         # Uploaded files directory
├── index.js         # Main server file
└── package.json
```

## Setup

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Create `.env` file:**
   ```env
   PORT=5000
   NODE_ENV=development
   CORS_ORIGIN=*
   MONGODB_URI=mongodb://localhost:27017/samparka
   JWT_SECRET=your-secret-key-change-in-production
   JWT_EXPIRES_IN=7d
   GOOGLE_CLIENT_ID=your-google-client-id
   GOOGLE_CLIENT_SECRET=your-google-client-secret
   ```

3. **Start MongoDB:**
   Make sure MongoDB is running on your system.

4. **Run the server:**
   ```bash
   npm run dev    # Development mode with nodemon
   npm start      # Production mode
   ```

## API Endpoints

### Authentication
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - Login user
- `POST /api/v1/auth/google` - Google OAuth login
- `GET /api/v1/auth/me` - Get current user (Protected)
- `POST /api/v1/auth/refresh` - Refresh token (Protected)
- `POST /api/v1/auth/logout` - Logout (Protected)
- `POST /api/v1/auth/forgot-password` - Request password reset
- `POST /api/v1/auth/reset-password` - Reset password
- `POST /api/v1/auth/verify-email` - Verify email

### Users
- `GET /api/v1/user/profile` - Get user profile (Protected)
- `PUT /api/v1/user/profile` - Update user profile (Protected)
- `POST /api/v1/user/avatar` - Upload avatar (Protected)
- `PUT /api/v1/user/interests` - Update interests (Protected)
- `GET /api/v1/user/:userId/events` - Get user's events

### Events
- `GET /api/v1/events` - Get all events (with filters)
- `GET /api/v1/events/:id` - Get single event
- `POST /api/v1/events` - Create event (Protected)
- `PUT /api/v1/events/:id` - Update event (Protected)
- `DELETE /api/v1/events/:id` - Delete event (Protected)
- `POST /api/v1/events/:id/join` - Join event (Protected)
- `POST /api/v1/events/:id/leave` - Leave event (Protected)
- `GET /api/v1/events/:id/attendees` - Get event attendees

### Groups
- `GET /api/v1/groups` - Get all groups (with filters)
- `GET /api/v1/groups/:id` - Get single group
- `POST /api/v1/groups` - Create group (Protected)
- `PUT /api/v1/groups/:id` - Update group (Protected)
- `DELETE /api/v1/groups/:id` - Delete group (Protected)
- `POST /api/v1/groups/:id/join` - Join group (Protected)
- `POST /api/v1/groups/:id/leave` - Leave group (Protected)
- `GET /api/v1/groups/:id/members` - Get group members
- `GET /api/v1/groups/:id/messages` - Get group messages (Protected)
- `POST /api/v1/groups/:id/messages` - Send message (Protected)

### Categories
- `GET /api/v1/categories` - Get all categories
- `POST /api/v1/categories` - Create category (Admin only)

### Search
- `GET /api/v1/search/events?q=query` - Search events
- `GET /api/v1/search/groups?q=query` - Search groups
- `GET /api/v1/search/users?q=query` - Search users

## Authentication

Most protected routes require a JWT token in the Authorization header:
```
Authorization: Bearer <token>
```

## Response Format

All API responses follow this format:
```json
{
  "success": true,
  "data": { ... }
}
```

Error responses:
```json
{
  "success": false,
  "message": "Error message"
}
```

## Models

### User
- Authentication (email/password or Google OAuth)
- Profile information (name, bio, avatar, location)
- Interests and preferences
- Role-based access (member, admin, business)
- Reward balance
- Verification status

### Event
- Event details (title, description, category)
- Date/time and location (GeoJSON)
- Capacity and ticket tiers
- Attendees management
- Reward boost

### Group
- Group information (name, description, keyword)
- Location (GeoJSON)
- Members management
- Messages

### GroupMessage
- Message content
- Sender information
- Attachments support

### Category
- Category name and icon

## Development

The backend uses ES6 modules. Make sure your `package.json` has `"type": "module"`.

## License

ISC

