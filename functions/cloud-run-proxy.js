// Cloud Run Proxy Server
// This proxies requests to the Firebase Function so we can deploy to Cloud Run
// with the original service name

const express = require('express');
const cors = require('cors');
const https = require('https');

const app = express();

// Enable CORS
app.use(cors({
  origin: '*',
  methods: ['GET', 'OPTIONS'],
  allowedHeaders: ['Content-Type'],
}));

// Proxy endpoint - forwards to Firebase Function
app.get('/', async (req, res) => {
  try {
    // Handle CORS preflight
    if (req.method === "OPTIONS") {
      res.set("Access-Control-Allow-Origin", "*");
      res.set("Access-Control-Allow-Methods", "GET, OPTIONS");
      res.set("Access-Control-Allow-Headers", "Content-Type");
      return res.status(204).send("");
    }

    if (req.method !== "GET") {
      return res.status(405).send("Method Not Allowed");
    }

    // Forward request to Firebase Function
    const functionUrl = 'https://us-central1-culture-connection-d442f.cloudfunctions.net/ticketmastersearch';
    const queryString = new URLSearchParams(req.query).toString();
    const targetUrl = `${functionUrl}${queryString ? '?' + queryString : ''}`;

    console.log(`Proxying request to: ${targetUrl}`);

    // Make request to Firebase Function
    const response = await fetch(targetUrl);
    const data = await response.text();
    
    // Forward response
    res.set("Access-Control-Allow-Origin", "*");
    res.set("Cache-Control", "public, max-age=3600, s-maxage=7200");
    res.status(response.status).send(data);
  } catch (error) {
    console.error("❌ Proxy error:", error);
    return res.status(500).json({ 
      events: [],
      error: "Proxy error" 
    });
  }
});

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`Cloud Run proxy server running on port ${PORT}`);
  console.log(`Proxying to: https://us-central1-culture-connection-d442f.cloudfunctions.net/ticketmastersearch`);
});

module.exports = app;

