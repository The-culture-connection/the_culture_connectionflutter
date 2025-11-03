# Ticketmaster Search Function Deployment Guide

## Overview
The Ticketmaster search functionality has been moved from a Cloud Run service to a Firebase Function for easier management.

## Steps to Deploy

### 1. Get Your Ticketmaster API Key
1. Go to [Ticketmaster Developer Portal](https://developer.ticketmaster.com/)
2. Sign up or log in
3. Create a new application
4. Copy your API key

### 2. Set the Secret
Set the Ticketmaster API key as a secret:

```bash
cd functions
firebase functions:secrets:set TICKETMASTER_API_KEY
# When prompted, paste your Ticketmaster API key
```

### 3. Build and Deploy
```bash
cd functions
npm install
npm run build
firebase deploy --only functions:ticketmastersearch
```

**Important:** When deploying, Firebase will ask you to grant access to the secret. Type `y` to confirm.

### 4. Verify Deployment
After deployment, you should see:
```
✔  functions[ticketmastersearch(us-central1)] Successful create operation.
Function URL: https://us-central1-culture-connection-d442f.cloudfunctions.net/ticketmastersearch
```

**Note:** The function name is `ticketmastersearch` (lowercase) to match the original Cloud Run service endpoint name.

## Testing
You can test the function directly in your browser:
```
https://us-central1-culture-connection-d442f.cloudfunctions.net/ticketmastersearch?city=New+York,NY&size=10
```

Or with coordinates:
```
https://us-central1-culture-connection-d442f.cloudfunctions.net/ticketmastersearch?lat=40.7128&lng=-74.0060&radius=25&size=10
```

## Response Format
The function returns events in the exact format expected by the iOS/Flutter app:
```json
{
  "events": [
    {
      "id": "...",
      "title": "...",
      "startsAt": "...",
      "timezone": "...",
      "venue": "...",
      "address": "...",
      "url": "..."
    }
  ],
  "page": {
    "size": 25,
    "totalElements": 100,
    "totalPages": 4,
    "number": 0
  }
}
```

## Troubleshooting

### Error: "Ticketmaster API key not configured"
- Make sure you set the environment variable correctly
- For secrets: Use `firebase functions:secrets:set TICKETMASTER_API_KEY`
- For config: Use `firebase functions:config:set ticketmaster.api_key="YOUR_KEY"`

### Error: 403 from Ticketmaster API
- Check that your API key is valid
- Ensure your Ticketmaster account is active
- Check rate limits on your Ticketmaster account

### Function timeout
- The function has a 60-second timeout
- Large result sets may take longer - consider reducing the `size` parameter

