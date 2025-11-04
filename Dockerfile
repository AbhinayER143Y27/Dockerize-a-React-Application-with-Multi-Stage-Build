# --- Stage 1: The Builder ---
# We use an Alpine Node image for a smaller build environment
FROM node:18-alpine AS builder

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json FIRST
# This leverages Docker's layer caching.
# 'npm install' only re-runs if these files change.
COPY package.json package-lock.json ./
RUN npm install

# Copy the rest of your source code
COPY . .

# Run the production build
RUN npm run build

# --- Stage 2: The Server ---
# We use a tiny, fast, and secure Nginx server
FROM nginx:1.25-alpine

# Copy *only* the optimized build artifacts from Stage 1
COPY --from=builder /app/build /usr/share/nginx/html

# Copy our custom Nginx config to handle React Router
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80 for the Nginx server
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
