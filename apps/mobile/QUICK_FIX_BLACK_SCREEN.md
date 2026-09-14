# Quick Fix: Black Screen Issue

## The Problem

Your app has a **black screen** because it's trying to initialize Firebase, but Firebase isn't configured for local development.

## The Quick Fix (Choose One)

### Option 1: Run Without Firebase (Easiest)

The app's code is trying to initialize Firebase on startup. We need to make it optional.

**1. Check your current API config:**
```bash
cd apps\mobile\lib
# Look for config files
```

**2. Run with disabled push notifications:**
```bash
cd apps\mobile
flutter run --dart-define=API_BASE_URL=http://localhost:3080/v1 --dart-define=PUSH_ENABLED=false
```

If you get errors about Firebase, the code needs a small patch.

### Option 2: Set Up Firebase (Complete Solution)

**Step 1: Create Firebase Project**
1. Go to https://console.firebase.google.com/
2. Click "Add project" or use existing
3. Name it "Moozhayil Gold" or similar
4. Disable Google Analytics (optional, simpler for testing)

**Step 2: Add Android App**
1. In Firebase Console, click "Add app" → Android icon
2. Package name: Check your `AndroidManifest.xml` - it's probably `com.moozhayil.app`
3. Download `google-services.json`
4. Place it here: `apps\mobile\android\app\google-services.json`

**Step 3: Get Firebase Values**
In Firebase Console → Project Settings → General:
- Copy **Project ID**
- Under "Your apps" → Android app → Copy **App ID**
- Click "Web API Key" → Copy **API Key**
- Under "Cloud Messaging" tab → Copy **Sender ID**

**Step 4: Run with Firebase**
```bash
cd apps\mobile
flutter run --dart-define=API_BASE_URL=http://localhost:3080/v1 --dart-define=PUSH_ENABLED=true --dart-define=FIREBASE_PROJECT_ID=your-project-id --dart-define=FIREBASE_API_KEY=your-api-key --dart-define=FIREBASE_APP_ID=your-app-id --dart-define=FIREBASE_MESSAGING_SENDER_ID=your-sender-id
```

---

## Your Backend Isn't Running?

If your API isn't running on `http://localhost:3080`, you have two choices:

### A. Start Local Backend
```bash
# In a new terminal:
cd apps\api
npm install
npm run dev
```

### B. Use Railway (Your Deployed Backend)
```bash
# Check RAILWAY_ENV_VARIABLES.txt for your Railway URL, then:
cd apps\mobile
flutter run --dart-define=API_BASE_URL=https://your-app.railway.app/v1 --dart-define=PUSH_ENABLED=false
```

---

## Still Black Screen?

**Check Flutter Console Output:**
```bash
flutter run
# Look for error messages - they'll tell you exactly what's wrong
```

**Common Issues:**
1. **"Firebase not initialized"** → Use PUSH_ENABLED=false OR set up Firebase (Option 2)
2. **"Connection refused"** → Your backend isn't running
3. **"MissingPluginException"** → Run `flutter clean` then `flutter pub get`

**Nuclear Option (if nothing works):**
```bash
cd apps\mobile
flutter clean
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:3080/v1 --dart-define=PUSH_ENABLED=false
```

---

## Android Emulator Specific

If using Android emulator (not Windows desktop):
```bash
# Use 10.0.2.2 instead of localhost
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:3080/v1 --dart-define=PUSH_ENABLED=false
```

---

## What You Should See When It Works

1. App launches
2. You see a login/welcome screen
3. No crashes or black screen

If you get a "Can't connect to server" error **but the app shows UI**, that's actually progress! It means the app is working, just needs the backend.

---

## Quick Test Without Backend

The app needs a backend to work. But if you just want to verify Flutter is working:

```bash
# Create a test app
flutter create test_app
cd test_app
flutter run
```

If that works, your Flutter setup is fine. The black screen is specifically a Moozhayil app config issue.

---

## Next Steps After Fixing Black Screen

1. ✅ Fix black screen (this guide)
2. Make sure backend is running (Railway or local)
3. Test login flow
4. Set up Firebase properly for push notifications
5. Build release version
6. Submit to stores

**You don't need Docker, Kubernetes, or most of that complex stuff to just run the app!**
