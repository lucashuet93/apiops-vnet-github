SHELL := /bin/bash

.PHONY: help
.DEFAULT_GOAL := help

ENV_FILE := .env
ifeq ($(filter $(MAKECMDGOALS),config clean),)
	ifneq ($(strip $(wildcard $(ENV_FILE))),)
		ifneq ($(MAKECMDGOALS),config)
			include $(ENV_FILE)
			export
		endif
	endif
endif

help: ## 💬 This help message :)
	@grep -E '[a-zA-Z_-]+:.*?## .*$$' $(firstword $(MAKEFILE_LIST)) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-23s\033[0m %s\n", $$1, $$2}'

infra: ## 🚀 Deploy the API Ops Infrastructure
	@echo -e "\e[34m$@\e[0m" || true
	@./scripts/deploy.sh

extract-env: ## ⚙️ Extract the environment variables from Terraform
	@echo -e "\e[34m$@\e[0m" || true
	@./scripts/json-to-env.sh < infrastructure/terraform_output.json > infrastructure/terraform.env

extract-dev: ## 📤 Export the development API Management instance
	@echo -e "\e[34m$@\e[0m" || true
	@export API_MANAGEMENT_SERVICE_OUTPUT_FOLDER_PATH=extract/dev \
		&& export API_MANAGEMENT_SERVICE_NAME=${DEV_APIM_NAME} \
		&& export AZURE_RESOURCE_GROUP_NAME=${DEV_RESOURCE_GROUP_NAME} \
		&& extractor

extract-prod: ## 📤 Export the development API Management instance
	@echo -e "\e[34m$@\e[0m" || true
	@export API_MANAGEMENT_SERVICE_OUTPUT_FOLDER_PATH=extract/prod \
		&& export API_MANAGEMENT_SERVICE_NAME=${PROD_APIM_NAME} \
		&& export AZURE_RESOURCE_GROUP_NAME=${PROD_RESOURCE_GROUP_NAME} \
		&& extractor

publish-dev: ## 📤 Publish to the development API Management instance
	@echo -e "\e[34m$@\e[0m" || true
	@export API_MANAGEMENT_SERVICE_OUTPUT_FOLDER_PATH=apimartifacts \
		&& export API_MANAGEMENT_SERVICE_NAME=${DEV_APIM_NAME} \
		&& export AZURE_RESOURCE_GROUP_NAME=${DEV_RESOURCE_GROUP_NAME} \
		&& publisher