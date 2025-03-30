# LAGOON-MCL container

Check that [Docker](https://docs.docker.com/engine/install/) and docker buildx are installed on your machine.

## Retrieve container

```bash
docker pull jroussea/lagoon-mcl:latest
```

## Build container

### Download Quarto

LAGOON-MCL uses quarto to generate HTML reports. 

Download the `.deb` file corresponding to version 1.5.57.

```bash
wget -c https://github.com/quarto-dev/quarto-cli/releases/download/v1.5.57/quarto-1.5.57-linux-amd64.deb
```

All releases available on [GitHub](https://github.com/quarto-dev/quarto-cli)

### Docker build

```bash
docker buildx build i-t lagoon-mcl .
```

### Docker push

```bash
docker tag lagoon-mcl username/lagoon-mcl:latest

docker push username/lagoon-mcl:latest
```