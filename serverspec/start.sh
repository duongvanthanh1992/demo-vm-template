#!/bin/bash

set -x

docker compose build \
    --build-arg OS="$OS" \
    --build-arg VERSION="$VERSION" \
    --build-arg TARGET="$TARGET"

docker compose run \
    -e OS="$OS" \
    -e UOM_USER_ENABLED="$UOM_USER_ENABLED" \
    -e PACKAGE="$PACKAGE" \
    serverspec_check spec:"$TARGET"
