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

extract-dev: ## ⬇️ Export the development API Management instance to a temp local folder
	@echo -e "\e[34m$@\e[0m" || true
	@export API_MANAGEMENT_SERVICE_OUTPUT_FOLDER_PATH=temp/dev \
		&& export API_MANAGEMENT_SERVICE_NAME=${DEV_APIM_NAME} \
		&& export AZURE_RESOURCE_GROUP_NAME=${DEV_RESOURCE_GROUP_NAME} \
		&& extractor

extract-prod: ## ⬇️ Export the development API Management instance to a temp local folder
	@echo -e "\e[34m$@\e[0m" || true
	@export API_MANAGEMENT_SERVICE_OUTPUT_FOLDER_PATH=temp/prod \
		&& export API_MANAGEMENT_SERVICE_NAME=${PROD_APIM_NAME} \
		&& export AZURE_RESOURCE_GROUP_NAME=${PROD_RESOURCE_GROUP_NAME} \
		&& extractor

publish-dev: artifacts-dev ## ⬆️ Publish to the development API Management instance
	@echo -e "\e[34m$@\e[0m" || true
	@export API_MANAGEMENT_SERVICE_OUTPUT_FOLDER_PATH=apim_artifacts \
		&& export API_MANAGEMENT_SERVICE_NAME=${DEV_APIM_NAME} \
		&& export AZURE_RESOURCE_GROUP_NAME=${DEV_RESOURCE_GROUP_NAME} \
		&& export CONFIGURATION_YAML_PATH="./apim_artifacts/configuration.dev.yaml" \
		&& publisher

# publish-prod: artifacts-prod ## ⬆️ Publish to the production API Management instance
# 	@echo -e "\e[34m$@\e[0m" || true
# 	@export API_MANAGEMENT_SERVICE_OUTPUT_FOLDER_PATH=apim_artifacts \
# 		&& export API_MANAGEMENT_SERVICE_NAME=${PROD_APIM_NAME} \
# 		&& export AZURE_RESOURCE_GROUP_NAME=${PROD_RESOURCE_GROUP_NAME} \
# 		&& export CONFIGURATION_YAML_PATH="./apim_artifacts/configuration.prod.yaml" \
# 		&& publisher

artifacts-dev: ## ⚙️ Create APIM Artifacts based on environment variables
	@echo -e "\e[34m$@\e[0m" || true
	@export API_MANAGEMENT_SERVICE_NAME=${DEV_APIM_NAME} \
		&& ./scripts/create_apimartifacts.sh

artifacts-prod: ## ⚙️ Create APIM Artifacts based on environment variables
	@echo -e "\e[34m$@\e[0m" || true
	@export API_MANAGEMENT_SERVICE_NAME=${PROD_APIM_NAME} \
		&& ./scripts/create_apimartifacts.sh
