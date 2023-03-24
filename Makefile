.PHONY: default help all build build-all docker golangci-lint tflint tfvalidate tfdeploy tfdestroy

BIN_DIR		=./bin
TF_DIR		= ./.infra/terraform
APP_TF_DIR	= ${TF_DIR}/${APP_NAME}-app
INFRA_TF_DIR = ${TF_DIR}/${APP_NAME}-infra

default: help

help:
	@echo 'Usage:'
	@echo '		make all		run "make golangci-lint" & "make build-all" '
	@echo '		make build-all		run "make build" & "make docker"'
	@echo '		make golangci-lint	run golangci-lint linter'
	@echo '		make build		build ${APP_NAME} binary'
	@echo '		make docker		build docker image with "latest" tag'
	@echo '		make tfvalidate	run terraform validate'
	@echo '		make tflint		run "make tfvalidate" and tflint linter'
	@echo '		make tfplan		run terraform plan with development environment values and output it to /dev/null'
	@echo '		make tfapply	run an interactive "terraform apply" with development environment values'
	@echo '		make tfdestroy-dev	run "terraform destroy" to destroy development environment infrastructures'

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

tflint-app: tfvalidate-app
	@echo 'Starting preparation for Terraform linter'
	@if ! command -v tflint &> /dev/null; then \
		echo "Error: 'tflint' is not installed\nPlease check" >&2 \
		exit 1;\
	fi; \
	cd ${APP_TF_DIR} && tflint -f compact

tflint-infra: tfvalidate-infra
	@echo 'Starting preparation for Terraform linter'
	@if ! command -v tflint &> /dev/null; then \
		echo "Error: 'tflint' is not installed\nPlease check" >&2 \
		exit 1;\
	fi; \
	cd ${INFRA_TF_DIR} && tflint -f compact

tfvalidate-app:
	@echo 'Starting preparation for Terraform validation'
	@if ! command -v terraform &> /dev/null; then \
	echo "Error: 'terraform' is not installed\nPlease check" >&2 \
		exit 1;\
	fi; \
	cd ${APP_TF_DIR} && terraform init -backend-config=environments/${ENVIRONMENT}/config.s3.tfbackend -reconfigure; \
	terraform validate -no-color

tfvalidate-infra:
	@echo 'Starting preparation for Terraform validation'
	@if ! command -v terraform &> /dev/null; then \
	echo "Error: 'terraform' is not installed\nPlease check" >&2 \
		exit 1;\
	fi; \
	cd ${INFRA_TF_DIR} && terraform init -backend-config=environments/${ENVIRONMENT}/config.s3.tfbackend -reconfigure; \
	terraform validate -no-color

tfplan-app: tflint-app
	@echo 'running terraform plan for ${$APP_NAME}-app'
	cd ${APP_TF_DIR}; \
	terraform init -backend-config environments/${ENVIRONMENT}/config.s3.tfbackend ;\
	terraform plan -var-file environments/${ENVIRONMENT}/terraform.tfvars

tfplan-infra: tflint-infra
	@echo 'running terraform plan for ${$APP_NAME}-infra'
	cd ${INFRA_TF_DIR}; \
	terraform init -backend-config environments/${ENVIRONMENT}/config.s3.tfbackend ;\
	terraform plan -var-file environments/${ENVIRONMENT}/terraform.tfvars

tfapply-app: 
	@echo 'running terraform apply for ${$APP_NAME}-app'
	cd ${APP_TF_DIR}; \
	terraform init -backend-config environments/${ENVIRONMENT}/config.s3.tfbackend ;\
	terraform apply -var-file environments/${ENVIRONMENT}/terraform.tfvars

tfapply-infra: 	
	@echo 'running terraform apply for ${$APP_NAME}-infra'
	cd ${INFRA_TF_DIR}; \
	terraform init -backend-config environments/${ENVIRONMENT}/config.s3.tfbackend ;\
	terraform apply -var-file environments/${ENVIRONMENT}/terraform.tfvars

tfdestroy-app-dev:
	@echo 'running terraform destroy for ${$APP_NAME}-app'
	cd ${APP_TF_DIR}; \
	terraform init -backend-config environments/develop/config.s3.tfbackend -reconfigure;\
	terraform destroy -var-file environments/develop/terraform.tfvars -auto-approve; \

tfdestroy-infra-dev:
	@echo 'running terraform destroy for ${$APP_NAME}-infra'
	cd ${infra_TF_DIR}; \
	terraform init -backend-config environments/develop/config.s3.tfbackend -reconfigure;\
	terraform destroy -var-file environments/develop/terraform.tfvars -auto-approve; \