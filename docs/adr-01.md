# Service Level vs API Level Observability

## Context

This Architecture Decision Record (ADR) discusses the options when it comes to observability (logging / diagnsotics) of API Management

## Decision
For this sample we will use Service Level Telemetry rather than API Level telemetry, this makes the solution simple and means that the API authors do not have to concern themselves with setting up telemetry.

### Option 1 - API Level Telemetry
This option allows the API author to add custom logging properties at an API level for instance, updating the sampling percentage for a specific API. The following files are needed in your apim_templates folder should you wish to configure API level observability: - 

`api_template/diagnostics/applicationinsights/diagnosticInformation.json`
```json
{
  "properties": {
    "alwaysLog": "allErrors",
    "backend": {
      "request": {
        "dataMasking": {
          "queryParams": [
            {
              "mode": "Hide",
              "value": "*"
            }
          ]
        }
      }
    },
    "frontend": {
      "request": {
        "dataMasking": {
          "queryParams": [
            {
              "mode": "Hide",
              "value": "*"
            }
          ]
        }
      }
    },
    "httpCorrelationProtocol": "Legacy",
    "logClientIp": true,
    "sampling": {
      "percentage": 100,
      "samplingType": "Fixed"
    },
    "verbosity": "Information"
  }
}
```

`api_template/diagnostics/azuremonitor/diagnosticInformation.json`
```json
{
  "properties": {
    "backend": {
      "request": {
        "dataMasking": {
          "queryParams": [
            {
              "mode": "Hide",
              "value": "*"
            }
          ]
        }
      }
    },
    "frontend": {
      "request": {
        "dataMasking": {
          "queryParams": [
            {
              "mode": "Hide",
              "value": "*"
            }
          ]
        }
      }
    },
    "logClientIp": true,
    "sampling": {
      "percentage": 100,
      "samplingType": "Fixed"
    },
    "verbosity": "Information"
  }
}
```

`apim_templates/loggers/applicationinsights/loggerInformation.json`
```json
{
  "properties": {
    "credentials": {
      "instrumentationKey": "{{Logger-Credentials}}"
    },
    "description": "A logger originally created in the dev instance",
    "isBuffered": true,
    "loggerType": "applicationInsights"
  }
}
```

`apim_templates/loggers/azuremonitor/loggerInformation.json`
```json
{
  "properties": {
    "isBuffered": true,
    "loggerType": "azureMonitor"
  }
}
```

And finally a Named Value to ensure the telemetry key is a secret
`apim_templates/named values/Logger-Credentials/namedValueInformation.json`
```json
{
  "properties": {
    "displayName": "Logger-Credentials",
    "keyVault": {},
    "secret": true
  }
}
```

When you wish to configure this for a particular environment, you will need to tell the APIs which Log Analytics / App Insights to use, this can be achieved in a `configuration.ENV.yaml` file, with these sections: - 
```yml
namedValues:
  - name: Logger-Credentials
    properties:
      displayName: Logger-Credentials
      keyVault:
        secretIdentifier: "https://${DEV_KV_NAME}.vault.azure.net/secrets/kvs-aikey"
loggers:
  # the name of the logger has to match the folder name in apimartifacts/loggers.
  # the folder name originally matches the dev instance's extracted logger name, but was renamed to a generic one
  - name: applicationinsights
    properties:
      resourceId: "/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/${DEV_RESOURCE_GROUP_NAME}/providers/Microsoft.Insights/components/${DEV_APP_INSIGHTS_NAME}"
      credentials:
        instrumentationKey: "{{Logger-Credentials}}"
diagnostics:
  - name: applicationinsights
    properties:
      # loggerId must match the name of the logger above, in this case applicationinsights
      loggerId: "/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/${DEV_RESOURCE_GROUP_NAME}/providers/Microsoft.ApiManagement/service/${DEV_APIM_NAME}/loggers/applicationinsights"
  - name: azuremonitor
    properties:
      loggerId: "/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/${DEV_RESOURCE_GROUP_NAME}/providers/Microsoft.ApiManagement/service/${DEV_APIM_NAME}/loggers/azuremonitor"
```

### Option 2 - Service Level Telemetry
Configuring loggers and diagnostics in Terraform is not hard, it will mean that all APIs use the same metriccs. If you do need API level diagnostics, it may be difficult to provision those from Terraform given the APIs do not exist as Terraform resources. This sample demonstrates how to do this.

## Further reading

- [https://learn.microsoft.com/en-us/azure/api-management/api-management-howto-app-insights](https://learn.microsoft.com/en-us/azure/api-management/api-management-howto-app-insights)