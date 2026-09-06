# ==========================================
# Stage 1: Build React/Vite application
# ==========================================
FROM node:20-alpine AS build

WORKDIR /app

# Copy dependency files first for Docker layer caching
COPY package*.json ./

# Install dependencies
RUN npm ci && npm cache clean --force

# Copy application source
COPY . .

# Build production application
RUN npm run build


# ==========================================
# Stage 2: Production Nginx
# ==========================================
FROM nginx:alpine

# Update Alpine packages to the latest security versions
RUN apk update && \
    apk upgrade --no-cache

# Create non-root user/group
RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup

# Remove default Nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf

# Copy production build
COPY --from=build /app/dist /usr/share/nginx/html

# Give non-root user ownership of required directories
RUN chown -R appuser:appgroup \
        /usr/share/nginx/html \
        /var/cache/nginx \
        /var/run \
        /var/log/nginx

# Run Nginx as non-root
USER appuser

# Application listens on 8080
EXPOSE 8080

# Start Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
