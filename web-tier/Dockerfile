# Step 1: Build React app (Frontend)
FROM node:18 AS build

WORKDIR /app

COPY package.json ./

RUN npm install

COPY . .

RUN npm run build


# Step 2: Set up Nginx to serve the built React app
FROM nginx:alpine

# Install envsubst (required for environment variable substitution)
RUN apk add --no-cache gettext

# Copy the built React files to Nginx's HTML directory
COPY --from=build /app/build /usr/share/nginx/html

# Copy custom Nginx config template (default.conf.template)
COPY default.conf.template /etc/nginx/conf.d/default.conf.template

# Copy nginx.conf to the main Nginx configuration directory
COPY nginx.conf /etc/nginx/nginx.conf

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose port 80 for HTTP traffic
EXPOSE 80

# Set the entrypoint to run the script which substitutes env variables and starts Nginx
ENTRYPOINT ["/entrypoint.sh"]
