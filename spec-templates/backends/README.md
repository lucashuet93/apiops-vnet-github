# Specification

1. Create a destination folder path [Or repository]
2. Create a folder called `backends`

3. For each service that constitutes a hostname (e.g. pod) that you will communicate with

    1. `${BACKEND_NAME}` is the name of that service
    2. `${BACKEND_URL}` is the hostname
    3. Create a folder `backends/${BACKEND_NAME}`
    4. Create `backends/${BACKEND_NAME}/backendInformation.json` with the following values taken from the service

```json
{
  "properties": {
    "protocol": "http",
    "url": "${BACKEND_URL}"
  }
}
```

## Notes
If we don't know the hostname until deployment time, then we can skip the url property (or have a placeholder) and use the configuration.dev.yaml to supply that value at deployment time.
