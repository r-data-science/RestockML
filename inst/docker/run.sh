docker build . -t rdsapps -f inst/docker/Dockerfile
docker run --name app-prm -p 3939:3939 --rm -dt rdsapps
