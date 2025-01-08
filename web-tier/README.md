# Web Tier

sudo docker build --build-arg API_SERVER=custom-backend --build-arg API_PORT=8080 -t aws-web-tier .
sudo docker run -p 80:80 aws-web-tier