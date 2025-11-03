// Standalone Cloud Run server for Ticketmaster search
// Deploy this directly to Cloud Run to maintain the exact original URL
// This is a Node.js Express server that can be deployed to Cloud Run

const express = require('express');
const cors = require('cors');

const app = express();

// Enable CORS
app.use(cors({
  origin: '*',
  methods: ['GET', 'OPTIONS'],
  allowedHeaders: ['Content-Type'],
}));

// Ticketmaster search endpoint - root path matches original Cloud Run service
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

    const apiKey = process.env.TICKETMASTER_API_KEY;
    if (!apiKey) {
      console.error("❌ TICKETMASTER_API_KEY not configured");
      return res.json({
        events: [],
        error: "Server not configured",
      });
    }

    const {city, lat, lng, radius, size = "25", keyword} = req.query;

    // Build Ticketmaster API URL
    const baseUrl = "https://app.ticketmaster.com/discovery/v2/events.json";
    const params = new URLSearchParams();
    params.set("apikey", apiKey);
    params.set("size", String(size));
    params.set("sort", "date,asc");
    params.set("startDateTime", new Date().toISOString());

    if (keyword && String(keyword).trim()) {
      params.set("keyword", String(keyword).trim());
    }

    if (city) {
      params.set("city", String(city).trim());
    } else if (lat && lng) {
      params.set("geoPoint", `${lng},${lat}`);
      const radiusKm = radius ? Math.round(parseFloat(radius) * 1.609) : 40;
      params.set("radius", String(radiusKm));
      params.set("unit", "km");
    } else {
      return res.json({ events: [] });
    }

    const url = `${baseUrl}?${params.toString()}`;
    console.log(`🎫 Ticketmaster API request: ${url.replace(apiKey, "***")}`);

    const response = await fetch(url);
    if (!response.ok) {
      const errorText = await response.text();
      console.error(`❌ Ticketmaster API error: ${response.status} - ${errorText}`);
      return res.json({ events: [] });
    }

    const data = await response.json();

    const events = (data._embedded?.events || []).map(event => {
      const venue = event._embedded?.venues?.[0];
      const startDate = event.dates?.start;

      let formattedAddress = null;
      if (venue?.address?.line1) {
        const parts = [
          venue.address.line1,
          venue.city?.name,
          venue.state?.stateCode,
          venue.postalCode,
        ].filter(Boolean);
        formattedAddress = parts.join(", ");
      }

      let startsAtValue = null;
      if (startDate?.dateTime) {
        startsAtValue = startDate.dateTime;
      } else if (startDate?.localDate) {
        startsAtValue = `${startDate.localDate}T00:00:00`;
      }

      return {
        id: event.id || "",
        title: event.name || null,
        startsAt: startsAtValue,
        timezone: startDate?.timezone || null,
        venue: venue?.name || null,
        address: formattedAddress,
        url: event.url || null,
      };
    });

    const pageInfo = data.page ? {
      size: data.page.size || null,
      totalElements: data.page.totalElements || null,
      totalPages: data.page.totalPages || null,
      number: data.page.number || null,
    } : null;

    console.log(`✅ Ticketmaster API returned ${events.length} events`);

    res.set("Cache-Control", "public, max-age=3600, s-maxage=7200");
    res.set("Access-Control-Allow-Origin", "*");

    return res.json({
      events: events,
      ...(pageInfo && {page: pageInfo}),
    });
  } catch (error) {
    console.error("❌ Ticketmaster function error:", error);
    return res.json({ events: [] });
  }
});

// Note: The root path '/' handles all requests to match the original Cloud Run service
// Query parameters are handled in the route above

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`Ticketmaster search service running on port ${PORT}`);
});

module.exports = app;

