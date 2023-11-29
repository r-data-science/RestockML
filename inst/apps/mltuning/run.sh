docker build . -t rdsapps
docker run --name mltuning -p 3939:3939 --rm -dt rdsapps
