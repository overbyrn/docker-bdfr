#!/bin/bash

# For Testing
docker run --rm -it \
-v /appdata/bdfr/config:/config \
-v /appdata/bdfr/downloads:/downloads \
-p 7634:7634 \
-e BDFR_WAIT=3600 \
-e BDFR_POSTLIMIT=10 \
-e BDFR_VERBOSE=2 \
-e BDFR_SORT=top \
-e BDFR_DETOX=false \
-e BDFR_RDFIND=false \
-e BDFR_SYMLINKS=false \
-e DEBUG=true \
--name bdfr overbyrn/docker-bdfr

exit 0

# As Deamon
docker run -d \
-v /appdata/bdfr/config:/config \
-v /appdata/bdfr/downloads:/downloads \
-p 7634:7634 \
-e BDFR_WAIT=3600 \
-e BDFR_POSTLIMIT=10 \
-e BDFR_VERBOSE=2 \
-e BDFR_SORT=top \
-e BDFR_DETOX=false \
-e BDFR_RDFIND=false \
-e BDFR_SYMLINKS=false \
--name bdfr overbyrn/docker-bdfr
