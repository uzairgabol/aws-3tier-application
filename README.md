create database, add database configurations on db_config after that:

1-install docker
2-docker login sudo docker login
3-create images sudo docker build -t image-name .
4-tag images
    sudo docker tag application-code-app-tier-python:latest uzairgabol/aws-3tier-app:app-tier-python
    sudo docker tag application-code-web-tier:latest uzairgabol/aws-3tier-app:web-tier
5-push images to docker hub sudo docker push uzairgabol/aws-3tier-app:app-tier-python
    sudo docker push uzairgabol/aws-3tier-app:app-tier-python
    sudo docker push uzairgabol/aws-3tier-app:web-tier

