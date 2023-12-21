sudo docker build \
  --build-arg GITHUB_PAT=$GITHUB_PAT \
  -t rdsapps:latest \
  -f inst/docker/Dockerfile \
  .
docker tag rdsapps:latest bfatemi/rdsapps:latest
docker push bfatemi/rdsapps:latest

sudo docker run \
  --name app-prm \
  -p 4000:3838 \
  -e RPG_CONN_STRING=$RPG_CONN_STRING \
  --rm \
  -dt rdsapps:latest
