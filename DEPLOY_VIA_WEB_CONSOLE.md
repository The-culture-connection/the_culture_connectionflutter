# Deploy Ticketmaster Function via Google Cloud Console (Web Interface)

**No CLI installation needed!** Deploy everything via the web interface, just like the original service was likely deployed.

## Step 1: Check if Service Exists

1. Go to: https://console.cloud.google.com/run?project=culture-connection-d442f
2. Look for a service named `ticketmastersearch`
3. If you see it, note the URL - it should match: `https://ticketmastersearch-z66sdcydda-uc.a.run.app`

## Step 2: Set Up Secret (Ticketmaster API Key)

1. Go to: https://console.cloud.google.com/security/secret-manager?project=culture-connection-d442f
2. Click "CREATE SECRET"
3. Name: `TICKETMASTER_API_KEY`
4. Secret value: Your Ticketmaster API key
5. Click "CREATE SECRET"

## Step 3: Deploy Service

### Option A: Update Existing Service (Keeps Same URL)

If the service exists:
1. Go to Cloud Run: https://console.cloud.google.com/run?project=culture-connection-d442f
2. Click on `ticketmastersearch`
3. Click "EDIT & DEPLOY NEW REVISION"
4. Under "Source", choose one of:
   - **Upload a container**: If you've built a Docker image
   - **Cloud Build**: Connect to a source repository
   - **Deploy from source**: Upload the code directly
5. For "Deploy from source":
   - Upload the `functions` folder
   - Set entry point: `node cloud-run-server.js`
6. Under "Variables & Secrets":
   - Add secret: `TICKETMASTER_API_KEY` → Select the secret you created
7. Set Memory: 512 MiB
8. Set Timeout: 60 seconds
9. Click "DEPLOY"

### Option B: Create New Service

If the service doesn't exist:
1. Go to Cloud Run: https://console.cloud.google.com/run?project=culture-connection-d442f
2. Click "CREATE SERVICE"
3. Service name: `ticketmastersearch`
4. Region: `us-central1`
5. Under "Source", choose "Deploy from source"
6. Upload the `functions` folder
7. Set entry point: `node cloud-run-server.js`
8. Under "Variables & Secrets":
   - Add secret: `TICKETMASTER_API_KEY` → Select the secret you created
9. Set Memory: 512 MiB
10. Set Timeout: 60 seconds
11. Under "Authentication": Check "Allow unauthenticated invocations"
12. Click "CREATE"

## Step 4: Verify URL

After deployment:
1. The service URL will be displayed
2. **If updating existing service**: URL should remain: `https://ticketmastersearch-z66sdcydda-uc.a.run.app`
3. **If creating new service**: URL will be similar but with different hash

## Step 5: Test the Service

In your browser, test:
```
https://YOUR-SERVICE-URL?city=New+York,NY&size=10
```

You should see a JSON response with events.

## Important Notes

- The `functions/cloud-run-server.js` file is ready to deploy
- Make sure `package.json` includes `express` and `cors` dependencies
- The Dockerfile is also available if you prefer containerized deployment

