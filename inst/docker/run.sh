sudo docker build \
  --build-arg GITHUB_PAT=$GITHUB_PAT \
  --build-arg RPG_CONN_STRING=$RPG_CONN_STRING \
  -t rdsapps:latest \
  -f inst/docker/Dockerfile \
  .

docker tag rdsapps:latest bfatemi/rdsapps:latest
docker push bfatemi/rdsapps:latest

#sudo docker pull bfatemi/rdsapps:latest
#sudo docker run --name app-prm -p 3939:3939 --rm -dt bfatemi/rdsapps:latest
