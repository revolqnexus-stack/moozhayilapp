# How to Run the Mobile App

## 🚀 Run with Production API (Railway)

### Option 1: Android Emulator (Easiest)

1. **Launch Emulator:**
   ```bash
   flutter emulators --launch Moozhayil_Preview
   ```

2. **Wait 30 seconds** for emulator to fully boot

3. **Run App:**
   ```bash
   cd apps/mobile
   flutter run --dart-define=API_BASE_URL=https://moozhayil-gold-diamonds.up.railway.app/v1
   ```

4. **Select the Android device** when prompted

### Option 2: Physical Android Device

1. **Enable USB Debugging** on your Android phone:
   - Settings → About Phone → Tap "Build Number" 7 times
   - Settings → Developer Options → Enable "USB Debugging"

2. **Connect phone via USB**

3. **Run:**
   ```bash
   cd apps/mobile
   flutter run --dart-define=API_BASE_URL=https://moozhayil-gold-diamonds.up.railway.app/v1
   ```

### Option 3: Windows (Quick Preview)

```bash
cd apps/mobile
flutter run -d windows --dart-define=API_BASE_URL=https://moozhayil-gold-diamonds.up.railway.app/v1
```

## 📱 What You'll See

- **Splash Screen** with Moozhayil branding
- **Onboarding** flow (heritage jewellery brand story)
- **Login Screen** - use any Indian mobile number
- **OTP Screen** - enter `123456` (mock OTP in staging)
- **Home Screen** with:
  - Gold rate ticker
  - Category carousel
  - Featured products
  - Aura AI button
- **Bottom navigation:**
  - Home
  - Schemes (Aura, Crest, Dhanam)
  - Vault (wishlist)
  - Cart
  - Profile

## 🎨 What's Already Polished

✅ **Premium UI** - Warm ivory surfaces, oxblood burgundy, 22KT gold accents  
✅ **Luxury typography** - Cormorant Garamond + Inter (max w500)  
✅ **Jewellery-like animations** - Calm, precise, never bouncy  
✅ **11 specialized animations** - Payment success, add to cart, gold counting, etc.  
✅ **Complete navigation** - Bottom tabs, top app bar, navigation shell  
✅ **Mock data ready** - Works with mock providers (no real SMS/Payment needed)  
✅ **Production-ready** - Deep links, FCM, ProGuard, security headers  

## ⚙️ Environment Variables

The app is configured to use:
- **API:** https://moozhayil-gold-diamonds.up.railway.app/v1
- **NODE_ENV:** staging (allows mock providers)
- **Mock OTP:** 123456
- **No real SMS/Payment** required

## 🐛 Troubleshooting

### Emulator won't start?
```bash
# List emulators
flutter emulators

# Create new one if needed
flutter emulators --create --name Pixel_5
```

### Can't find device?
```bash
# Check connected devices
flutter devices

# Or specify device directly
flutter run -d windows
flutter run -d chrome
```

### Build errors?
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run --dart-define=API_BASE_URL=https://moozhayil-gold-diamonds.up.railway.app/v1
```

## 🎯 Quick Test Flow

1. **Open app** → See splash → Onboarding
2. **Login** with `+919876543210`
3. **Enter OTP**: `123456`
4. **Explore home** → Categories, products
5. **Try Aura** → AI assistant (gold insights, goal planning)
6. **Add to vault** → Wishlist products
7. **Create goal** → Start a savings scheme
8. **View profile** → Gold balance, KYC status

## 📊 Admin Panel

While testing the app, manage content from:
**https://moozhayil-gold-diamonds.vercel.app**

Login: `admin@moozhayil.com` / `Admin123!@#`

You can:
- Add products (needs categories first)
- Upload banners
- Manage gold rates
- View orders
- KYC reviews
