SHELL:=bash

REGISTRY:=ghcr.io/yevhenkuznetsov
BASE_IMAGE_NAME:=${REGISTRY}/base
BASE_IMAGE_VERSION:=$(shell cat base/version)

.PHONY: main
main: base

base: base/version
	docker build . --tag ${BASE_IMAGE_NAME} --file ${PWD}/base/base.dockerfile
	docker tag ${BASE_IMAGE_NAME} ${BASE_IMAGE_NAME}:${BASE_IMAGE_VERSION}
	docker tag ${BASE_IMAGE_NAME}:${BASE_IMAGE_VERSION} ${BASE_IMAGE_NAME}:latest
	docker tag ${BASE_IMAGE_NAME} ${BASE_IMAGE_NAME}:latest

.PHONY: run-base
run-base:
	docker run -it --rm ${BASE_IMAGE_NAME}:latest
