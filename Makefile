.PHONY: default help all build build-all docker golangci-lint

BIN_DIR		=./bin

default: help

help:
	@echo 'Usage:'
	@echo '		make all		run "make golangci-lint" & "make build-all" '
	@echo '		make build-all		run "make build" & "make docker"'
	@echo '		make golangci-lint	run golangci-lint linter'
	@echo '		make build		build ${APP_NAME} binary'
	@echo '		make docker		build docker image with "latest" tag'

all: golangci-lint build-all

build-all: build docker

golangci-lint:
	@echo 'Starting preparation for golangci linter'
	@if ! command -v tflint golangci-lint &> /dev/null; then \
		echo "Error: 'golangci-lint' is not installed" >&2 \
		exit 1;\
	fi
	@echo 'golangci-lint cli found'
	golangci-lint run ./... --tests=0 --issues-exit-code=1 --timeout=30m

build:
	@echo 'Building ${APP_NAME} binary'
	mkdir -p ./bin; 
	GOOS=linux GOARCH=amd64 go build -o ${BIN_DIR}/${APP_NAME} github.com/w19andrian/${APP_NAME}; 

docker:
	@echo 'Starting preparation for building Docker image'
	@if ! command -v docker &> /dev/null; then \
		echo "Error: 'docker' is not installed" >&2 \
		exit 1;\
	fi
	@echo 'found Docker command'
	docker build -t ${APP_NAME}:latest .
clean:
	rm -rf ./bin

