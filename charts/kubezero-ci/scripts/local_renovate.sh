#!/bin/sh

podman run -it --rm \
  -e GITHUB_COM_TOKEN=$GITHUB_TOKEN \
  -e RENOVATE_TOKEN=$RENOVATE_TOKEN \
  -e RENOVATE_AUTODISCOVER=false \
  -e RENOVATE_PLATFORM=local \
  -e LOG_LEVEL=debug \
  -v $(pwd):/usr/src/app ghcr.io/renovatebot/renovate:latest
