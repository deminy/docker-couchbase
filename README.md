Customized Couchbase image for local development. You can get the image from [here](https://hub.docker.com/r/deminy/couchbase).

# How To Use It

Check file [docker-compose.yml](https://github.com/deminy/docker-couchbase/blob/master/docker-compose.yml) to see how to
use environment variables to initialize username, password, services, and other configuration options.

# Docker Commands

```bash
# To build the Docker image.
docker build -t deminy/couchbase -f ./dockerfiles/latest/Dockerfile .

# To start a Couchbase container.
docker-compose up -d --force-recreate

docker compose exec -t  couchbase bash -c "curl -i http://127.0.0.1:8091"
docker compose exec -ti couchbase bash
```

# References

* The image is built based on [the official Couchbase image](https://hub.docker.com/_/couchbase).
