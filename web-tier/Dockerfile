# Step 1: Build React app (Frontend)
FROM node:18 AS build

WORKDIR /app
COPY package.json ./
RUN npm install
COPY . .
RUN npm run build

# Step 2: Set up Nginx to serve the built React app
FROM nginx:alpine

# Copy the built React files to Nginx's HTML directory
COPY --from=build /app/build /usr/share/nginx/html

# Copy custom Nginx config (nginx.conf) to the main Nginx configuration directory
COPY nginx.conf /etc/nginx/nginx.conf

# Copy default.conf to the conf.d directory (server-specific configuration)
COPY default.conf /etc/nginx/conf.d/default.conf

# Expose port 80 for HTTP traffic
EXPOSE 80

# Start Nginx to serve the React app
CMD ["nginx", "-g", "daemon off;"]
