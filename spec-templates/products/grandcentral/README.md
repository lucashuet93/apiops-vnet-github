# Specification

1. Create a destination folder path [Or repository]
2. Create a folder called `products`
3. At the moment we are solving a single Product (but we could add multiple products later)
  `${PRODUCT_NAME}`= "Grand Central"

4. Create a folder `products/${PRODUCT_NAME}`
5. Create `backends/${PRODUCT_NAME}/productInformation.json` with the following hardcoded values. Later we could pass in a variable and this could be the customer name

```json
{
  "properties": {
    "displayName": "Grand Central",
    "state": "published",
    "subscriptionRequired": true
  }
}
```

6. Create a file called `backends/${PRODUCT_NAME}/apis.json`
7. We have to create an array of objects that match the name of each api that this product should have access to. I think this would be easier after we create all the APIs as then we can just iterate around all the folder names. 

An example

```json
[
  {
    "name": "${API_NAME1}"
  }
]
```