#!/bin/bash
set -euo pipefail

echo "# Generated environment variables from tf output"

jq -r '
    [
        {
            "path": "apim_client_id",
            "env_var": "AZURE_CLIENT_ID"
        },
        {
            "path": "apim_client_secret",
            "env_var": "AZURE_CLIENT_SECRET"
        },
        {
            "path": "azure_subscription_id",
            "env_var": "AZURE_SUBSCRIPTION_ID"
        },
        {
            "path": "azure_tenant_id",
            "env_var": "AZURE_TENANT_ID"
        },
        {
            "path": "dev_apim_name",
            "env_var": "DEV_APIM_NAME"
        },
        {
            "path": "dev_resource_group_name",
            "env_var": "DEV_RESOURCE_GROUP_NAME"
        },
        {
            "path": "dev_app_insights_name",
            "env_var": "DEV_APP_INSIGHTS_NAME"
        },
        {
            "path": "dev_key_vault_name",
            "env_var": "DEV_KV_NAME"
        },
        {
            "path": "prod_apim_name",
            "env_var": "PROD_APIM_NAME"
        },
        {
            "path": "prod_resource_group_name",
            "env_var": "PROD_RESOURCE_GROUP_NAME"
        },
        {
            "path": "prod_app_insights_name",
            "env_var": "PROD_APP_INSIGHTS_NAME"
        },
        {
            "path": "prod_key_vault_name",
            "env_var": "PROD_KV_NAME"
        }
    ]
        as $env_vars_to_extract
    |
    with_entries(
        select (
            .key as $a
            |
            any( $env_vars_to_extract[]; .path == $a)
        )
        |
        .key |= . as $old_key | ($env_vars_to_extract[] | select (.path == $old_key) | .env_var)
    )
    |
    to_entries
    |
    map("\(.key)=\(.value.value)")
    |
    .[]
    ' | sed "s/\"/'/g" # replace double quote with single quote to handle special chars