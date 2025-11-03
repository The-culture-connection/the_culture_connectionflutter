# Test Firebase Function with curl

## Function URL
```
https://us-central1-culture-connection-d442f.cloudfunctions.net/ticketmastersearch
```

## Test Commands

### Test 1: Search by City
```bash
curl "https://us-central1-culture-connection-d442f.cloudfunctions.net/ticketmastersearch?city=New+York,NY&size=10"
```

### Test 2: Search by Coordinates
```bash
curl "https://us-central1-culture-connection-d442f.cloudfunctions.net/ticketmastersearch?lat=40.7128&lng=-74.0060&radius=25&size=10"
```

### Test 3: Search with Keyword
```bash
curl "https://us-central1-culture-connection-d442f.cloudfunctions.net/ticketmastersearch?city=Los+Angeles,CA&keyword=music&size=10"
```

### Test 4: Pretty Print JSON Response
```bash
curl "https://us-central1-culture-connection-d442f.cloudfunctions.net/ticketmastersearch?city=New+York,NY&size=5" | jq .
```

### Test 5: Verbose Output (See Headers)
```bash
curl -v "https://us-central1-culture-connection-d442f.cloudfunctions.net/ticketmastersearch?city=Chicago,IL&size=10"
```

## Expected Response Format

Success response:
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
    "size": 10,
    "totalElements": 100,
    "totalPages": 10,
    "number": 0
  }
}
```

Error response (if secret not configured):
```json
{
  "events": [],
  "error": "Server not configured"
}
```

## Quick Test in Browser

You can also test directly in your browser:
```
https://us-central1-culture-connection-d442f.cloudfunctions.net/ticketmastersearch?city=New+York,NY&size=10
```

