# Firebase Storage CORS Configuration

## The Problem

If logo uploads are stuck at 0% progress, it's likely a **CORS (Cross-Origin Resource Sharing) issue**. Firebase Storage needs to be configured to allow uploads from your Squarespace domain.

## Solution: Configure CORS in Firebase Storage

### Step 1: Create a CORS Configuration File

Create a file called `cors.json` with the following content:

```json
[
  {
    "origin": ["*"],
    "method": ["GET", "POST", "PUT", "DELETE", "HEAD"],
    "maxAgeSeconds": 3600,
    "responseHeader": ["Content-Type", "Authorization", "Content-Length", "User-Agent", "x-goog-resumable"]
  }
]
```

**OR** if you want to restrict to specific domains (more secure):

```json
[
  {
    "origin": [
      "https://your-squarespace-site.squarespace.com",
      "https://*.squarespace.com"
    ],
    "method": ["GET", "POST", "PUT", "DELETE", "HEAD"],
    "maxAgeSeconds": 3600,
    "responseHeader": ["Content-Type", "Authorization", "Content-Length", "User-Agent", "x-goog-resumable"]
  }
]
```

### Step 2: Apply CORS Configuration

You need to use the `gsutil` tool (Google Cloud Storage command-line tool) to apply this configuration.

#### Option A: Using Google Cloud Shell (Easiest)

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your Firebase project: `culture-connection-d442f`
3. Click the "Cloud Shell" icon (top right, looks like `>_`)
4. In the Cloud Shell, create the `cors.json` file:
   ```bash
   nano cors.json
   ```
   (Paste the JSON content, then press Ctrl+X, Y, Enter to save)

5. Apply the CORS configuration:
   ```bash
   gsutil cors set cors.json gs://culture-connection-d442f.appspot.com
   ```

6. Verify it worked:
   ```bash
   gsutil cors get gs://culture-connection-d442f.appspot.com
   ```

#### Option B: Using Local gsutil

1. Install [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
2. Authenticate:
   ```bash
   gcloud auth login
   ```
3. Set your project:
   ```bash
   gcloud config set project culture-connection-d442f
   ```
4. Create `cors.json` file (same content as above)
5. Apply CORS:
   ```bash
   gsutil cors set cors.json gs://culture-connection-d442f.appspot.com
   ```

### Step 3: Test the Upload

After applying CORS configuration:
1. Wait 1-2 minutes for changes to propagate
2. Try uploading a logo again from your Squarespace form
3. Check browser console (F12) for any remaining errors

## Alternative: Use Firebase Admin SDK (Backend Upload)

If CORS configuration doesn't work, you could:
1. Upload the logo to a temporary location (your server)
2. Use a Firebase Cloud Function to move it to Storage
3. This bypasses CORS but requires backend infrastructure

## Troubleshooting

- **Still stuck at 0%?** Check browser Network tab (F12 > Network) for failed requests
- **403 Forbidden?** Check Firebase Storage rules allow writes to `BusinessLogos/`
- **CORS errors in console?** Make sure you applied the CORS config correctly
- **Works in some browsers but not others?** Browser security policies may differ

## Current Storage Rules (for reference)

Your current rules should allow:
```
match /BusinessLogos/{allPaths=**} {
  allow read, write;
}
```

Make sure these rules are active in Firebase Console > Storage > Rules.


