# Test Ultra Black Friday Businesses Script

This script generates 100 test businesses and uploads them to Firestore for testing the Ultra Black Friday feature.

## Option 1: Firebase Cloud Function (Easiest - Recommended! ⭐)

**No local setup needed!** Just deploy and call via HTTP.

### Setup:

1. **Deploy the function:**
```bash
cd functions
npm install
npm run build
firebase deploy --only functions:generateTestUltraBlackBusinesses
```

2. **Call the function:**
   - After deployment, you'll get a URL like:
   - `https://us-central1-culture-connection-d442f.cloudfunctions.net/generateTestUltraBlackBusinesses`
   - Just open that URL in your browser or call it with curl/Postman
   - Or call it from Firebase Console → Functions → Click the function → "Test function"

**That's it!** The function runs in the cloud and generates all 100 businesses automatically.

## Option 2: Node.js Script (Local)

The Node.js script is simpler and doesn't require Flutter SDK setup.

### Setup:

1. Install Node.js dependencies:
```bash
npm install firebase-admin
```

2. Get your Firebase service account key:
   - Go to Firebase Console → Project Settings → Service Accounts
   - Click "Generate New Private Key"
   - Save the JSON file as `serviceAccountKey.json` in the project root

3. Run the script:
```bash
node scripts/test_ultrablackbusinesses.js
```

## Option 2: Dart/Flutter Script

If you prefer using Dart:

```bash
dart run scripts/test_ultrablackbusinesses.dart
```

**Note:** Make sure you have Flutter/Dart SDK installed and that your Firebase is properly configured. The script will initialize Flutter bindings and Firebase automatically.

## What It Does

1. Generates 100 unique test businesses with:
   - Random business names (e.g., "Elite Wellness Solutions", "Premium Fitness LLC")
   - Random owner names
   - Cincinnati addresses
   - Random categories and subcategories
   - Random deals with various discount types
   - All required fields populated

2. Uploads them to Firestore in the structure:
   ```
   Ultra Black Friday/
     └── {mainCategory}/  (e.g., "Health & Wellness")
         ├── Theme: "{mainCategory}"
         └── businesses/
             └── {businessId}/
                 └── {all business data}
   ```

## Generated Data

- **Business Names**: Random combinations of prefixes, types, and suffixes
- **Owner Names**: Random first and last names
- **Email**: Generated from owner name + index
- **Phone**: Random 513 area code numbers
- **Addresses**: Random Cincinnati addresses
- **Categories**: Distributed across all 10 main categories
- **Deals**: Random discount types (%, $, BOGO, etc.) with values
- **Codes**: 50-250 codes per business
- **Price Ranges**: Random from $ to $$$$$

## Notes

- All businesses have `appVisibility: true`
- Logo URLs are set to `null` (you can add real logos later)
- Social media links are randomly populated (70-80% chance)
- The script will show progress every 10 businesses
- At the end, it shows a summary of successes and errors

