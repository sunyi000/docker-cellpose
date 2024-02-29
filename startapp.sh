#!/bin/sh -f

PATH=${PATH}:/opt/conda/envs/cellpose/bin

export PATH

if [ ! -e /bin/cellpose_galaxy ]; then    
    cellpose
else
    cellpose_galaxy
fi
