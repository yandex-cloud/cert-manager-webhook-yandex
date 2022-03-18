#!/bin/bash

REPOSITORY="$(cat deploy/cert-manager-webhook-yandex/values.yaml | grep repository | awk '{print $2}')"
VERSION="$(cat deploy/cert-manager-webhook-yandex/Chart.yaml | grep version | awk '{print $2}')"
IMAGE="$REPOSITORY:$VERSION"

docker build .
IMAGE_ID=$(docker images | awk '{print $3}' | sed -n '2p')

docker tag "$IMAGE_ID" "$IMAGE"
docker push "$IMAGE"
