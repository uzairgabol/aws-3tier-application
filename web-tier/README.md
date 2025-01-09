# Web Tier

sudo docker build -t aws-web-tier .
sudo docker run -e API_URL=google.com -p 80:80 aws-web-tier