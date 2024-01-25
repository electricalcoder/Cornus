#!/bin/bash

docker build -t base -f Dockerfile ./
docker build -t cn -f Dockerfile_CN --build-arg BASE_IMAGE=base ./
docker build -t sn -f Dockerfile_SN --build-arg BASE_IMAGE=base ./
