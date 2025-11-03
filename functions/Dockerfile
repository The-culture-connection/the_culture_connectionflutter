# Dockerfile for Cloud Run deployment
FROM node:20

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy the server file
COPY cloud-run-server.js ./

# Expose the port Cloud Run expects
EXPOSE 8080

# Start the server
CMD ["node", "cloud-run-server.js"]

