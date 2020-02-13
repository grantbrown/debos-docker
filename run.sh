#!/bin/bash

docker run --rm -t \
    -u $(id -u) \
    --device /dev/kvm \
    --group-add=$(getent group kvm | cut -d : -f 3) \
    -v ${PWD}:/root \
    jbbgameich/debos-docker \
    /bin/bash -c "debos $*"
