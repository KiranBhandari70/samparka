# Google Sign-In Setup Guide

## Error 12500 Fix

The error `com.google.android.gms.common.api.ApiException:12500` means Google Sign-In is not properly configured. Follow these steps:

### Step 1: Get Your SHA-1 Fingerprint

1. Open terminal/command prompt in your project root
2. Run this command:

**For Windows:**
```bash
cd android
gradlew signingReport
```

**For Mac/Linux:**
```bash
cd android
./gradlew signingReport
```

3. Look for the SHA-1 fingerprint in the output (it will look like: `A1:B2:C3:...`)
4. Copy the SHA-1 fingerprint

### Step 2: Add SHA-1 to Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `samparka-44552`
3. Go to **Project Settings** (gear icon)
4. Scroll down to **Your apps** section
5. Click on your Android app (`com.Samparka.samparka`)
6. Click **Add fingerprint**
7. Paste your SHA-1 fingerprint
8. Click **Save**

### Step 3: Get Web Client ID

1. In Firebase Console, go to **Project Settings**
2. Scroll to **Your apps** section
3. Click on your Android app
4. Look for **OAuth 2.0 Client IDs** section
5. Find the **Web client** (it should have a name like "Web client (auto created by Google Service)")
6. Copy the **Client ID** (it looks like: `123456789-abc...xyz.apps.googleusercontent.com`)

**OR** if you don't see it:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select project: `samparka-44552`
3. Go to **APIs & Services** > **Credentials**
4. Find **OAuth 2.0 Client IDs**
5. Look for **Web client** or create one if it doesn't exist
6. Copy the **Client ID**

### Step 4: Update Your Code

1. Open `lib/presentation/pages/auth/auth_page.dart`
2. Find this line (around line 47):
   ```dart
   serverClientId: null, // Will be set from environment or Firebase config
   ```
3. Replace `null` with your Web Client ID:
   ```dart
   serverClientId: 'YOUR_WEB_CLIENT_ID_HERE.apps.googleusercontent.com',
   ```

### Step 5: Rebuild the App

1. Stop the app completely
2. Clean the build:
   ```bash
   flutter clean
   ```
3. Get dependencies:
   ```bash
   flutter pub get
   ```
4. Rebuild and run:
   ```bash
   flutter run
   ```

### Step 6: Verify OAuth Client Configuration

Make sure in Firebase Console:
- Your Android app has the correct package name: `com.Samparka.samparka`
- SHA-1 fingerprint is added
- OAuth 2.0 Client ID (Web client) exists

### Troubleshooting

If you still get errors:

1. **Check package name matches**: 
   - `android/app/build.gradle.kts`: `applicationId = "com.Samparka.samparka"`
   - Firebase Console: Should match exactly

2. **Verify google-services.json**:
   - File should be in `android/app/google-services.json`
   - Should contain your project info

3. **Check backend configuration**:
   - Make sure your backend has the same Web Client ID in environment variables
   - Check `backend/.env` or environment config

4. **Try signing out first**:
   ```dart
   await GoogleSignIn().signOut();
   ```

### Quick Test

After setup, test with:
```dart
final GoogleSignIn googleSignIn = GoogleSignIn(
  serverClientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
);
final account = await googleSignIn.signIn();
```

If this works, your configuration is correct!

