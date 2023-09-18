# Specification

1. Create a destination folder path [Or repository]
2. Create a folder called `apis`

3. For each `.yaml` file in `https://github.com/baas-devops-ecos/grandcentral-spec/tree/master/src/main/resources`

    1. `${API_NAME}` is the name of the file without the extension
    2. Create a folder `api/${API_NAME}`
    3. Copy this file into `apis/${API_NAME}/specification.yml`
    4. Create `apis/${API_NAME}/apiInformation.json` with the following values taken from the source spec file

```json
{
  "properties": {
    "apiRevision": "@info.semanticVersion",
    "apiVersion": "@info.version",
    "displayName": "@info.title",
    "isCurrent": true,
    "subscriptionRequired": true,
  }
}
```