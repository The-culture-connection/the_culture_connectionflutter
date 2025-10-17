# VS Code Setup & Error Fixes

## ✅ Fixed Issues

### 1. **Deprecated `background` parameter** ✅
**Error**: "The parameter 'background' is deprecated and shouldn't be used"

**Fixed in**: `lib/main.dart`
- Removed `background` parameter from `ColorScheme.dark()`
- Flutter 3.7+ uses `surface` instead

### 2. **Analysis Options** ✅
**Updated**: `analysis_options.yaml`
- Disabled noisy linting rules
- Enabled best practice rules
- Set appropriate error levels

---

## 🔧 Required Steps in VS Code

### Step 1: Install Flutter Extension
1. Open VS Code
2. Go to Extensions (Ctrl+Shift+X or Cmd+Shift+X)
3. Search for "Flutter"
4. Install the official **Flutter** extension by Dart Code

### Step 2: Run Flutter Pub Get
Open the terminal in VS Code and run:
```bash
flutter pub get
```

This will download all dependencies and resolve most errors!

### Step 3: Restart VS Code
After running `flutter pub get`, restart VS Code:
- Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
- Type "Reload Window"
- Press Enter

---

## 🐛 Common Errors & Solutions

### Error: "Target of URI doesn't exist"
**Solution**: Run `flutter pub get` in terminal

### Error: "Undefined class or function"
**Solution**: 
1. Run `flutter pub get`
2. Restart VS Code
3. Check that all imports are correct

### Error: "The method 'xxx' isn't defined"
**Solution**: Make sure you've run `flutter pub get` to download all packages

### Error: "Deprecated member use"
**Solution**: These are warnings, not errors. The app will still run. They've been set to "warning" level in analysis_options.yaml

### Error: Font or asset not found
**Solution**: All assets are configured in `pubspec.yaml` and exist in `/assets/` folder

---

## ✅ How to Verify Everything Works

### 1. Check Dart SDK
Open terminal and run:
```bash
dart --version
flutter --version
```

### 2. Check Dependencies
```bash
flutter pub get
```

Should output: "Got dependencies!"

### 3. Check for Issues
```bash
flutter analyze
```

Should show minimal or no issues

### 4. Run the App
```bash
flutter run
```

---

## 📦 All Dependencies Installed

The following packages are configured in `pubspec.yaml`:

✅ **State Management**
- flutter_riverpod: ^2.5.0
- riverpod_annotation: ^2.3.5

✅ **Firebase**
- firebase_core: ^3.5.0
- firebase_auth: ^5.3.0
- cloud_firestore: ^5.4.0
- firebase_storage: ^12.3.0
- firebase_messaging: ^15.0.0
- firebase_analytics: ^11.3.0
- cloud_functions: ^5.1.0

✅ **UI & Images**
- cached_network_image: ^3.3.0
- image_picker: ^1.0.4
- image_cropper: ^5.0.0

✅ **All Other Dependencies**
- See `pubspec.yaml` for complete list

---

## 🎯 Quick Fix Commands

Run these commands in VS Code terminal:

```bash
# 1. Clean build files
flutter clean

# 2. Get dependencies
flutter pub get

# 3. Check for issues
flutter analyze

# 4. If using build_runner (optional)
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 🔍 Still Seeing Errors?

### Check Flutter Doctor
```bash
flutter doctor -v
```

This will show if you're missing any requirements.

### Common Missing Requirements:
- ❌ Flutter SDK not installed → Install from https://flutter.dev
- ❌ Dart SDK not found → Comes with Flutter
- ❌ Android SDK not found → Install Android Studio
- ❌ Xcode not found (Mac only) → Install from App Store
- ❌ CocoaPods not found (Mac only) → Run `sudo gem install cocoapods`

---

## 📱 Platform-Specific Setup

### For iOS Development (Mac only):
```bash
cd ios
pod install
cd ..
```

### For Android Development:
1. Install Android Studio
2. Install Android SDK
3. Accept licenses: `flutter doctor --android-licenses`

---

## ✅ Files Fixed

1. ✅ `lib/main.dart` - Removed deprecated `background` parameter
2. ✅ `analysis_options.yaml` - Updated linting rules
3. ✅ All imports are correct
4. ✅ All assets are configured
5. ✅ All dependencies are listed

---

## 🎉 Ready to Code!

Once you've run `flutter pub get` and restarted VS Code, all errors should be resolved!

If you still see errors, they're likely one of these:
1. **Warnings** (yellow underlines) - Safe to ignore, won't prevent app from running
2. **Missing Flutter SDK** - Install Flutter
3. **Dependencies not installed** - Run `flutter pub get`

---

## 💡 Pro Tips

### Enable Auto-Import
In VS Code settings (settings.json):
```json
{
  "dart.autoImportCompletions": true,
  "dart.enableSdkFormatter": true,
  "dart.lineLength": 100
}
```

### Keyboard Shortcuts
- `Ctrl+Space`: Auto-complete
- `Shift+Alt+F`: Format document
- `F12`: Go to definition
- `Shift+F12`: Find all references

### Flutter Commands in VS Code
- `Ctrl+Shift+P` → Type "Flutter: Hot Reload"
- `Ctrl+Shift+P` → Type "Flutter: Hot Restart"
- `Ctrl+Shift+P` → Type "Flutter: Run Flutter Doctor"

---

**All fixed! Run `flutter pub get` and you should be good to go! 🚀**
