# Use the official Node.js runtime as the base image
FROM node:18-alpine

# Set the working directory inside the container
WORKDIR /app

# Install system dependencies (if needed for certain npm packages)
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    git

# Copy package.json and package-lock.json (if available)
COPY package*.json ./

# Install dependencies (fixed: removed deprecated --only=production flag)
RUN npm ci --omit=dev

# Copy the rest of the application code
COPY . .

# Create a non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S botuser -u 1001 -G nodejs

# Change ownership of the app directory to the bot user
RUN chown -R botuser:nodejs /app

# Switch to the non-root user
USER botuser

# Expose the port (adjust if your bot uses webhooks)
EXPOSE 3000

# Health check (optional - adjust the URL/command based on your bot)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node --version || exit 1

# Set environment variables (these should be overridden at runtime)
ENV NODE_ENV=production
ENV PORT=3000

# Start the bot
CMD ["npm", "start"]
