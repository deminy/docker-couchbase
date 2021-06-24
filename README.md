Customized Couchbase image for local development. You can get the image from [here](https://hub.docker.com/r/deminy/couchbase).

# Docker Commands

```bash
# To build the Docker image.
docker build -t deminy/couchbase -f ./dockerfiles/latest/Dockerfile .

# To start a Couchbase container.
docker-compose up -d --force-recreate

docker exec -t  $(docker ps -qf "name=couchbase") bash -c "curl -i http://127.0.0.1:8091"
docker exec -ti $(docker ps -qf "name=couchbase") bash
```

# References

* The image is built based on [the official Couchbase image](https://hub.docker.com/_/couchbase).
