# Simple Deployment Guide - No CLI Installation Needed

## You Already Have Everything You Need!

The original service was likely deployed via the Google Cloud Console web interface. You can update it the same way - no command line tools needed.

## Step 1: Check if the Service Exists

1. Go to: https://console.cloud.google.com/run?project=culture-connection-d442f
2. Look for a service named `ticketmastersearch`
3. If you see it, click on it to see the details

## Step 2: Set Up the Ticketmaster API Key Secret

1. Go to: https://console.cloud.google.com/security/secret-manager?project=culture-connection-d442f
2. Click "CREATE SECRET"
3. Name: `TICKETMASTER_API_KEY`
4. Secret value: Paste your Ticketmaster API key
5. Click "CREATE SECRET"

## Step 3: Update the Existing Service (Keeps Same URL!)

If the service exists:

1. Go back to Cloud Run: https://console.cloud.google.com/run?project=culture-connection-d442f
2. Click on `ticketmastersearch`
3. Click "EDIT & DEPLOY NEW REVISION"
4. Scroll down to "Container" section
5. Under "Container image URL", you can either:
   - **Option A**: Connect to a source repository (GitHub, etc.)
   - **Option B**: Use "Deploy from source" and upload the `functions` folder
6. Set the entry point: `node cloud-run-server.js`
7. Scroll to "Variables & Secrets" tab
8. Click "ADD SECRET"
9. Select `TICKETMASTER_API_KEY` from the dropdown
10. Set memory to 512 MiB
11. Set timeout to 60 seconds
12. Click "DEPLOY"

**The URL will remain exactly the same!**

## Step 4: If the Service Doesn't Exist

If you don't see the service:

1. Click "CREATE SERVICE"
2. Service name: `ticketmastersearch`
3. Region: `us-central1`
4. Choose "Deploy from source"
5. Upload the `functions` folder
6. Set entry point: `node cloud-run-server.js`
7. Add secret: `TICKETMASTER_API_KEY`
8. Memory: 512 MiB
9. Timeout: 60 seconds
10. Check "Allow unauthenticated invocations"
11. Click "CREATE"

**Note**: If creating a new service, the URL will have a different hash. You'll need to update the Flutter app code in `lib/services/events_service.dart` with the new URL.

## That's It!

No command line tools needed. Everything can be done through the web interface, just like the original deployment was likely done.

