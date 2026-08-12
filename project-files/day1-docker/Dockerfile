# --- Stage 1: Build & Dependencies ---
FROM node:18-alpine3.19 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev

# --- Stage 2: Final Production Runtime ---
FROM node:18-alpine3.19 AS runner
WORKDIR /app

# Skip Copy app code
COPY . .

# Drop to non-root user for security
USER node

EXPOSE 3000
CMD ["node", "server.js"]