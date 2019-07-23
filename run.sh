#!/usr/bin/env bash

docker run --rm -it --init \
  --runtime=nvidia \
  --ipc=host \
  --publish 8888:8888 \
  --volume="$PWD:$HOME" \
  -e NVIDIA_VISIBLE_DEVICES=0 \
  wn1980/dnn-gt640m-le
