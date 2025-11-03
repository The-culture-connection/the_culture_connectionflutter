# Deploy to Match Original URL (Web Console Method)

## Important Reality Check

⚠️ **Cloud Run URL hashes are auto-generated and cannot be controlled.**

The original URL hash (`z66sdcydda`) is **gone forever** and cannot be recreated. However, we can deploy a service with the same name to get a similar URL structure.

## Step-by-Step: Deploy to Cloud Run via Web Console

### Step 1: Set Up Secret

1. Go to: https://console.cloud.google.com/security/secret-manager?project=culture-connection-d442f
2. Click "CREATE SECRET" (if it doesn't exist)
3. Name: `TICKETMASTER_API_KEY`
4. Paste your API key
5. Click "CREATE SECRET"

### Step 2: Deploy Standalone Server to Cloud Run

1. **Go to Cloud Run:**
   - https://console.cloud.google.com/run?project=culture-connection-d442f

2. **Click "CREATE SERVICE"**

3. **Service Configuration:**
   - **Service name:** `ticketmastersearch` (must match exactly)
   - **Region:** `us-central1`
   - **Authentication:** Allow unauthenticated invocations ✅

4. **Container:**
   - Choose "Deploy from source"
   - Upload the `functions` folder
   - **Entry point:** `node cloud-run-server.js`
   - **Runtime:** Node.js 20

5. **Variables & Secrets:**
   - Click "ADD SECRET"
   - Select: `TICKETMASTER_API_KEY`
   - Version: `latest`
   - Mount as: Environment variable
   - Variable name: `TICKETMASTER_API_KEY`

6. **Container Settings:**
   - Memory: 512 MiB
   - Timeout: 60 seconds

7. **Click "CREATE"**

### Step 3: Get the New URL

After deployment:
- The service URL will be displayed
- Format: `https://ticketmastersearch-REGION-HASH.a.run.app`
- The hash will be different from the original, but similar structure

### Step 4: Update Flutter Code (If Needed)

Since the hash is different, you have two options:

**Option A:** Update Flutter code with new URL (requires app update)
```dart
static const String _baseUrl = 'https://ticketmastersearch-NEW-HASH-uc.a.run.app';
```

**Option B:** Use Firebase Function URL (already updated)
```dart
static const String _baseUrl = 'https://us-central1-culture-connection-d442f.cloudfunctions.net/ticketmastersearch';
```

## Alternative: Use Firebase Function Directly

Since you can't get the exact original URL, the simplest solution is to:

1. **Keep the Flutter code as-is** (already using Firebase Function URL)
2. **The Firebase Function works** - just needs the secret configured properly
3. **Users need to update the app** - but this is unavoidable since the original service is gone

## Why the Original URL Can't Be Matched

Cloud Run generates URL hashes based on:
- Service creation timestamp
- Region
- Project configuration
- Internal routing

These cannot be controlled or recreated. Once a service is deleted, its hash is gone forever.

## Recommendation

**Use the Firebase Function URL** (already updated in Flutter code):
- ✅ Works immediately
- ✅ No additional deployment needed
- ✅ Simpler architecture
- ❌ Requires app update (unavoidable since original service is gone)

