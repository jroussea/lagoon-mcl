# LAGOON-MCL container

The LAGOON Docker container is available on [Docker Hub](https://hub.docker.com/r/jroussea/lagoon-mcl).

Otherwise, to build the container, check that [Docker](https://docs.docker.com/engine/install/) and docker buildx are installed on your machine.

The container is built from the image [condaforge/miniforge3](https://hub.docker.com/r/condaforge/miniforge3) to easily install Python and the various modules used by the pipeline in the desired versions.

## Retrieve container

```bash
docker pull jroussea/lagoon-mcl:latest
```

## Build container

### Docker build

```bash
docker buildx build -t lagoon-mcl .
```

### Docker push

```bash
docker tag lagoon-mcl username/lagoon-mcl:latest

docker push username/lagoon-mcl:latest
```