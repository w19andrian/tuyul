.PHONY: default help all build build-all docker golangci-lint tflint tfvalidate tfdeploy tfdestroy

BIN_DIR		=./bin
TF_DIR		= ./.infra/terraform
APP_TF_DIR	= ${TF_DIR}/${APP_NAME}-app
INFRA_TF_DIR = ${TF_DIR}/${APP_NAME}-infra

default: help

help:
	@echo 'Usage:'
	@echo '		make all						run "make golangci-lint" & "make build-all" '
	@echo '		make build-all					run "make build" & "make docker"'
	@echo '		make golangci-lint				run golangci-lint linter'
	@echo '		make build						build ${APP_NAME} binary'
	@echo '		make docker						build docker image with "latest" tag'
	@echo '		make tfvalidate-infra			run terraform validate (CORE INFRASTRUCTURE)' 
	@echo '		make tflint-infra				run "make tfvalidate-infra" and "make tflint-infra" linter (CORE INFRASTRUCTURE)' 
	@echo '		make tfplan-infra				run "make tflint-infra" & "terraform plan" with development environment values (CORE INFRASTRUCTURE)' 
	@echo '		make tfapply-infra				run an interactive "terraform apply" with development environment values (CORE INFRASTRUCTURE)' 
	@echo '		make tfdestroy-infra-dev		run "terraform destroy" to destroy development environment infrastructures (CORE INFRASTRUCTURE)'
	@echo '		make tfvalidate-app				run terraform validate (APP)'
	@echo '		make tflint-app					run "make tfvalidate-app" and "make tflint-app" linter (APP)'
	@echo '		make tfplan-app					run "make tflint-app" & "terraform plan" with development environment values (APP)'
	@echo '		make tfapply-app				run an interactive "terraform apply" with development environment values (APP)'
	@echo '		make tfdestroy-app-dev			run "terraform destroy" to destroy development environment infrastructures (APP)'
	@echo '		make clean						clean up build artifacts'

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
	rm -rf ./bin ${APP_TF_DIR}/{.terraform,plan.out} ${INFRA_TF_DIR}/{.terraform,plan.out}

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