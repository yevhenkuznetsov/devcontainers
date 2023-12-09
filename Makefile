SHELL:=bash

REGISTRY:=ghcr.io/yevhenkuznetsov/devcontainers
BASE_IMAGE_NAME:=${REGISTRY}/base
BASE_IMAGE_VERSION:=$(shell cat base/version.in)
QT_IMAGE_NAME:=${REGISTRY}/qt
QT_IMAGE_VERSION:=$(shell cat qt/version.in)

.PHONY: main
main: base qt

.PHONY: base
base:
	docker build . --tag ${BASE_IMAGE_NAME} --file ${PWD}/base/base.dockerfile
	docker tag ${BASE_IMAGE_NAME} ${BASE_IMAGE_NAME}:${BASE_IMAGE_VERSION}
	docker tag ${BASE_IMAGE_NAME}:${BASE_IMAGE_VERSION} ${BASE_IMAGE_NAME}:latest
	docker tag ${BASE_IMAGE_NAME} ${BASE_IMAGE_NAME}:latest

.PHONY: push-base
push-base:
	docker push ${BASE_IMAGE_NAME}
	docker push ${BASE_IMAGE_NAME}:${BASE_IMAGE_VERSION}
	docker push ${BASE_IMAGE_NAME}:latest

.PHONY: run-base
run-base:
	docker run -it --rm ${BASE_IMAGE_NAME}:latest

.PHONY: qt
qt:
	docker build . --tag ${QT_IMAGE_NAME} --file ${PWD}/qt/qt.dockerfile
	docker tag ${QT_IMAGE_NAME} ${QT_IMAGE_NAME}:${QT_IMAGE_VERSION}
	docker tag ${QT_IMAGE_NAME}:${QT_IMAGE_VERSION} ${QT_IMAGE_NAME}:latest
	docker tag ${QT_IMAGE_NAME} ${QT_IMAGE_NAME}:latest

.PHONY: push-qt
push-qt:
	docker push ${QT_IMAGE_NAME}
	docker push ${QT_IMAGE_NAME}:${QT_IMAGE_VERSION}
	docker push ${QT_IMAGE_NAME}:latest

.PHONY: run-qt
run-qt:
	docker run -it --rm ${QT_IMAGE_NAME}:latest
