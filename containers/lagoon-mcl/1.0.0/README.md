# LAGOON-MCL container

The container is built from the image [condaforge/miniforge3](https://hub.docker.com/r/condaforge/miniforge3) to easily install Python and the various modules used by the pipeline in the desired versions.

## Apptainer build

```bash
apptainer build --fakeroot lagoon.sif lagoon-mcl.def
```
