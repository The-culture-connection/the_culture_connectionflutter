# Function Deployment - URL Information

## ✅ Function Successfully Deployed!

Your Firebase Function is deployed and accessible at:

**Firebase Function URL:**
```
https://us-central1-culture-connection-d442f.cloudfunctions.net/ticketmastersearch
```

## ⚠️ URL Mismatch Issue

Your Flutter app is currently hardcoded to use:
```
https://ticketmastersearch-z66sdcydda-uc.a.run.app
```

## Solution Options

### Option 1: Update Flutter Code (Simplest - New App Versions)

Update `lib/services/events_service.dart` to use the Firebase Function URL:

```dart
static const String _baseUrl = 'https://us-central1-culture-connection-d442f.cloudfunctions.net/ticketmastersearch';
```

**Note:** This will require users to update the app.

### Option 2: Find Cloud Run URL (Keeps Existing App Working)

Firebase Functions v2 automatically deploy to Cloud Run. Check if there's a Cloud Run URL:

1. Go to: https://console.cloud.google.com/run?project=culture-connection-d442f
2. Look for a service named `ticketmastersearch`
3. If it exists, the Cloud Run URL should be displayed there

The Cloud Run URL format is usually:
```
https://ticketmastersearch-REGION-HASH.a.run.app
```

### Option 3: Test the Function First

Test if the function works with the current Flutter URL:

Try calling:
```
https://us-central1-culture-connection-d442f.cloudfunctions.net/ticketmastersearch?city=New+York,NY&size=10
```

If it works, you can update the Flutter code to use this URL.

## Testing the Function

You can test the function in your browser:

**With city:**
```
https://us-central1-culture-connection-d442f.cloudfunctions.net/ticketmastersearch?city=New+York,NY&size=10
```

**With coordinates:**
```
https://us-central1-culture-connection-d442f.cloudfunctions.net/ticketmastersearch?lat=40.7128&lng=-74.0060&radius=25&size=10
```

**With keyword:**
```
https://us-central1-culture-connection-d442f.cloudfunctions.net/ticketmastersearch?city=New+York,NY&keyword=music&size=10
```

