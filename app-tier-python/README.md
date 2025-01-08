# App Tier

sudo docker build \
  --build-arg DB_HOST="database-test.cb2im8iiaqin.us-east-1.rds.amazonaws.com" \
  --build-arg DB_USER="admin" \
  --build-arg DB_PWD="test1234" \
  --build-arg DB_DATABASE="webappdb" \
  -t your-image-name .

sudo docker run -p 4000:4000 aws-app-tier