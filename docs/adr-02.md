# Spec Transfer Process

## Context

The backend APIs fronted by API Management may be developed by a separate team in a different repository. The API Management configuration stored in `/apim_templates` is not a static set of files, and instead must change over time to accommodate changes in the backend APIs. As backend APIs change, their corresponding Open API Specs change as well. As new specs are created by the backend API team, the API Ops team must ingest the files and generate the required changes in API Management.

## Approach

As new versions of a spec become available, new versions or revisions to an existing version should be created for the corresponding API Management API. Versions and revisions are captured in API Ops as entirely new folders within `/apim_templates/apis`. For reference, the Swagger Petstore API that has 3 versions (each with different spec) has the following corresponding folders in `/apim_templates/apis`:

- `swagger-petstore/`
- `swagger-petstore-v2/`
- `swagger-petstore-v3/`

When a new version of a spec is released, a decision must be made [whether the change is breaking or not](https://learn.microsoft.com/en-us/azure/api-management/api-management-versions#versions-and-revisions). If the change is breaking, a new folder should be created in `/apim_templates/apis` that corresponds to the next available **version**. For the Swagger Petstore API, a new folder named `swagger-petstore-v4` would be created. If the change is not breaking, a new folder should be created in `/apim_templates/apis` that corresponds to the next available **revision** for the version that the spec targets. For the Swagger Petstore API, if the spec referred to a revision to `v3` of the API, a new folder named `swagger-petstore-v3;rev=2` would be created. A subsequent revision would result in a new folder named `swagger-petstore-v3;rev=3`.

API Ops expects each API folder to contain the following files:

- `apiInformation.json`, which contains the API configuration data
- `policy.xml`, which contains the API Policy applied to all API Operations
- `specification.yaml`, which contains the Open API Spec for the API

The `specification.yaml` file for a new version or revision will be the spec that is released by the backend API team. The `apiInformation.json` and `policy.xml` files from the previous versions or revisions should be used as templates to build the `apiInformation.json` and `policy.xml` files necessary for the newly created `/apim_templates/apis` folder. Generally, a new version's `apiInformation.json` will be nearly identical to the previous version's `apiInformation.json` file, with the `apiVersion` property updated. Similarly, a new revision's `apiInformation.json` will be nearly identical to the previous revision's `apiInformation.json` file, with the `apiRevision`, `apiRevisionDescription`, and `isCurrent` properties updated (only one revision may be current for each version). Additional properties may be updated, if necessary.

In addition to the APIM API configuration itself, the API may need to be associated with existing Products. API Ops Products are stored in the `/apim_templates/products` folder, where each Product has it's own directory that corresponds to its name. API Ops uses a few files to define Product configuration, but uses the `/apim_templates/products/{PRODUCT_NAME}/apis.json` file to set the APIs the Product should be associated with. Each `apis.json` file contains an array of API names that correspond to the folders in `/apim_templates/apis`. The name of the newly created `/apim_templates/apis` folder should be added to `apis.json` for each of the Products the new API version/revision should be associated with.

The `backends`, `diagnostics`, `loggers`, and `named values` folders in `/apim_templates` folder do not need to be updated on new spec changes. The url for the backend API does not change on spec updates and the monitoring configuration for the previous versions/revisions of the API will be applied to the new version/revision as well.

In total, when a new version or revision is created, a new folder should be created in `/apim_templates/apis` that includes the following files:

- `/apis/{API_NAME}/apiInformation.json`
- `/apis/{API_NAME}/policy.xml`
- `/apis/{API_NAME}/specification.yaml`

And the `apis.json` file should be updated for each associated Product:

- `/products/{PRODUCT_NAME}/apis.json`

Once the new folder and files are added and updated, the new configuration can be published to API Management.