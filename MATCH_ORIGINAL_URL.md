# Match Original Cloud Run URL

## The Problem

- Original URL: `https://ticketmastersearch-z66sdcydda-uc.a.run.app`
- New Firebase Function: `https://us-central1-culture-connection-d442f.cloudfunctions.net/ticketmastersearch`
- Cloud Run URL hashes are **auto-generated and cannot be controlled**

## Solution Options

### Option 1: Deploy Proxy to Cloud Run (Recommended - Best Chance)

Deploy a Cloud Run service that proxies to your Firebase Function:

1. **Go to Cloud Run Console:**
   - https://console.cloud.google.com/run?project=culture-connection-d442f

2. **Click "CREATE SERVICE"**

3. **Service Configuration:**
   - Service name: `ticketmastersearch` (must match exactly)
   - Region: `us-central1`
   - Choose "Deploy from source"

4. **Upload the proxy code:**
   - Upload the `functions` folder
   - Set entry point: `node cloud-run-proxy.js`
   - Or use the Dockerfile with `cloud-run-proxy.js`

5. **Deploy:**
   - The URL will be similar but hash will be different
   - Format: `https://ticketmastersearch-REGION-HASH.a.run.app`

**Note:** The hash will still be different, so this won't match the exact original URL.

### Option 2: Use Cloud Load Balancer with Custom Domain (Exact Match)

This is the only way to get the EXACT same URL:

1. Create a Cloud Load Balancer
2. Configure a custom domain that matches the original URL structure
3. Point it to your Firebase Function
4. Requires DNS configuration

**This is complex and may not be worth it.**

### Option 3: Update Flutter Code (Simplest)

Since you can't control the Cloud Run hash, the simplest solution is to update the Flutter code:

1. Update `lib/services/events_service.dart` to use the Firebase Function URL
2. Deploy app update
3. Works immediately

### Option 4: Deploy Standalone Server (Not Proxy)

Deploy the standalone server (`cloud-run-server.js`) directly to Cloud Run:

1. Go to Cloud Run Console
2. Create service: `ticketmastersearch`
3. Deploy `cloud-run-server.js` with the Dockerfile
4. Add secret: `TICKETMASTER_API_KEY`
5. URL will be different but service name matches

## Recommended Approach

Since Cloud Run URL hashes **cannot be controlled**, your best options are:

1. **Immediate:** Update Flutter code to use Firebase Function URL (already done)
2. **Future:** Deploy standalone server to Cloud Run with service name `ticketmastersearch` for better URL structure

The original URL hash (`z66sdcydda`) is gone forever and cannot be recreated.

