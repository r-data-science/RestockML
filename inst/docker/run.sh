sudo docker build \
  --build-arg GITHUB_PAT=$GITHUB_PAT \
  -t RestockML:latest \
  -f inst/docker/Dockerfile \
  .
docker tag RestockML:latest bfatemi/RestockML:latest
docker push bfatemi/RestockML:latest

sudo docker run \
  --name appRestockML \
  -p 4000:3838 \
  -e RPG_CONN_STRING=$RPG_CONN_STRING \
  --rm \
  -dt RestockML:latest
