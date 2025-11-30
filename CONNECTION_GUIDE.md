# Frontend-Backend Connection Guide

## ✅ What Has Been Done

### 1. **Token Storage Service**
- Created `lib/data/services/storage_service.dart` for storing JWT tokens
- Uses `shared_preferences` package for persistent storage

### 2. **API Client Updates**
- Updated `lib/data/network/api_client.dart` to automatically include JWT tokens in all requests
- Tokens are retrieved from storage and added to `Authorization: Bearer <token>` header

### 3. **Environment Configuration**
- Updated `lib/config/environment.dart` to use `http://localhost:5000` for local development
- Change this to your backend URL when deploying

### 4. **Authentication Service**
- Updated `lib/data/services/auth_service.dart` to:
  - Store tokens after login/register
  - Clear tokens on logout
  - Check token existence for authentication status

### 5. **Response Format Handling**
- Updated all repositories and services to handle backend response format:
  - Backend returns: `{ success: true, user: {...} }` or `{ success: true, events: [...] }`
  - Frontend now extracts the data correctly from these responses

## 🚀 Setup Instructions

### Backend Setup

1. **Install dependencies:**
   ```bash
   cd backend
   npm install
   ```

2. **Create/Update `.env` file:**
   ```env
   PORT=5000
   NODE_ENV=development
   CORS_ORIGIN=*
   MONGODB_URI=your-mongodb-connection-string
   JWT_SECRET=your-secret-key
   JWT_EXPIRES_IN=7d
   ```

3. **Start the backend:**
   ```bash
   npm run dev
   ```

### Frontend Setup

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Update API Base URL (if needed):**
   - Open `lib/config/environment.dart`
   - Change `apiBaseUrl` if your backend is not on `localhost:5000`
   - For Android emulator, use: `http://10.0.2.2:5000`
   - For iOS simulator, use: `http://localhost:5000`
   - For physical device, use your computer's IP: `http://192.168.x.x:5000`

3. **Run the app:**
   ```bash
   flutter run
   ```

## 📱 Testing the Connection

### Test Registration
1. Open the app
2. Go to registration screen
3. Enter email and password
4. Submit - should receive token and user data

### Test Login
1. Use registered credentials
2. Login - should receive token
3. Token is automatically stored and used for subsequent requests

### Test Protected Routes
1. After login, try accessing profile or creating events
2. Token should be automatically included in requests

## 🔧 Troubleshooting

### CORS Issues
- Make sure backend CORS_ORIGIN allows your frontend origin
- For development, set `CORS_ORIGIN=*` in backend `.env`

### Connection Refused
- Check backend is running on correct port
- Verify MongoDB connection
- Check firewall settings

### Token Not Working
- Check token is being stored: Look for `auth_token` in SharedPreferences
- Verify token format in backend response
- Check Authorization header is being sent

### Response Format Errors
- Backend should return: `{ success: true, data: {...} }`
- Frontend extracts data from `data` or `user`/`event`/`group` fields

## 📝 API Endpoints

All endpoints are prefixed with `/api/v1`:

- **Auth:** `/api/v1/auth/login`, `/api/v1/auth/register`, etc.
- **User:** `/api/v1/user/profile`, `/api/v1/user/avatar`, etc.
- **Events:** `/api/v1/events`, `/api/v1/events/:id`, etc.
- **Groups:** `/api/v1/groups`, `/api/v1/groups/:id`, etc.

## ✅ Connection Status

- ✅ Token storage implemented
- ✅ API client includes tokens automatically
- ✅ Auth service stores/clears tokens
- ✅ Response format handling updated
- ✅ Environment configured for local dev
- ✅ CORS configured
- ✅ All repositories updated

Your frontend and backend are now fully connected! 🎉

