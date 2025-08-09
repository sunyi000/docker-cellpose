#!/bin/sh -f

# Cellpose uses a default starting directory for its internal file browser,
# which is normally the directory where Cellpose was launched.
# In Galaxy, $PWD is always a unique job working directory.
# Here, we override this to provide a more user-friendly default location,
# making it easier for users to open and save files.
cd "${CELLPOSE_START_DIR:-$PWD}"

export PATH=${PATH}:/opt/conda/envs/cellpose/bin
cellpose
