# Deploy Ticketmaster Function to Cloud Run (Exact URL Match)

## ⚠️ Important Note About Cloud Run URLs

Cloud Run service URLs have the format: `https://SERVICE-NAME-REGION-HASH.a.run.app`
The hash part (`z66sdcydda`) is auto-generated per revision and **cannot be exactly controlled**.

**However**, if the original Cloud Run service still exists (even if it's not working), you can:
1. Update it with new code - the URL will remain the same
2. Or create a new service with the same name - the hash will be different but close

## Goal
Deploy the function to Cloud Run so it works at a URL that matches the original service name.
The original URL was: `https://ticketmastersearch-z66sdcydda-uc.a.run.app`

**If the original service still exists**, updating it will keep the exact same URL.
**If it was deleted**, you'll need to deploy a new service which will have a different hash.

## Method: Deploy Directly to Cloud Run

Since Firebase Functions v2 deploy to Cloud Run but with auto-generated names, we'll deploy directly to Cloud Run with the exact service name.

### Step 1: Prepare the Standalone Server

A standalone Express server is already created in `functions/cloud-run-server.js`.
This server matches the exact behavior of the original function and can be deployed directly to Cloud Run.

### Step 2: Set the Ticketmaster API Key Secret

```bash
# Set the secret in Google Cloud Secret Manager
echo -n "YOUR_TICKETMASTER_API_KEY" | gcloud secrets create TICKETMASTER_API_KEY --data-file=-
```

Or if the secret already exists:
```bash
echo -n "YOUR_TICKETMASTER_API_KEY" | gcloud secrets versions add TICKETMASTER_API_KEY --data-file=-
```

### Step 3: Deploy to Cloud Run

```bash
cd functions

# Install dependencies (if not already installed)
npm install

# Deploy to Cloud Run with exact service name
# Option A: If the original service still exists (UPDATE - keeps same URL)
gcloud run services update ticketmastersearch \
  --region us-central1 \
  --source . \
  --update-secrets TICKETMASTER_API_KEY=TICKETMASTER_API_KEY:latest \
  --memory 512Mi \
  --timeout 60 \
  --allow-unauthenticated

# Option B: If the service was deleted (CREATE NEW - URL will have different hash)
gcloud run deploy ticketmastersearch \
  --source . \
  --region us-central1 \
  --platform managed \
  --allow-unauthenticated \
  --set-secrets TICKETMASTER_API_KEY=TICKETMASTER_API_KEY:latest \
  --memory 512Mi \
  --timeout 60 \
  --max-instances 10
```

**Important:** When using `--source .`, Cloud Run will look for a `Dockerfile` or use buildpacks. 
Since we have `cloud-run-server.js`, we need to either:
1. Create a `Dockerfile`, or
2. Use `--source` with a buildpack that detects Node.js

**Recommended:** Create a simple `Dockerfile` in the `functions` directory:

### Step 4: Deploy with Dockerfile

```bash
cd functions

# Deploy using the Dockerfile
gcloud run deploy ticketmastersearch \
  --source . \
  --region us-central1 \
  --platform managed \
  --allow-unauthenticated \
  --set-secrets TICKETMASTER_API_KEY=TICKETMASTER_API_KEY:latest \
  --memory 512Mi \
  --timeout 60
```

### Step 5: Verify the URL

After deployment, check the service URL:
```bash
gcloud run services describe ticketmastersearch --region us-central1 --format="value(status.url)"
```

**If the original service still exists and you updated it**, the URL will remain exactly the same: `https://ticketmastersearch-z66sdcydda-uc.a.run.app`

**If you created a new service**, the URL will be similar but with a different hash. In this case, you'll need to update the Flutter app code, OR use one of these alternatives:
1. Set up a custom domain in Cloud Run
2. Use Firebase Hosting with rewrites
3. Create a Cloud Load Balancer with a static IP

## Alternative: Use Firebase Hosting with Custom Domain

If you can't match the exact Cloud Run URL, configure Firebase Hosting:

1. Set up a custom domain in Firebase Hosting
2. Configure rewrites to proxy to the function
3. Point the custom domain to match the original URL structure

## Quick Solution: Update Existing Cloud Run Service

If the original Cloud Run service still exists but is just not working:

1. Go to Google Cloud Console → Cloud Run
2. Find service: `ticketmastersearch`
3. Deploy new revision with your function code
4. The URL will remain the same

