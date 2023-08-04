output "dev_apim" {
  description = "Deployed resource groups names."
  value = {
    resource_group_name = module.apim_dev.apim.resource_group_name
    apim_name           = module.apim_dev.apim.apim_name
  }
}

output "prod_apim" {
  description = "Deployed resource groups names."
  value = {
    resource_group_name = module.apim_prod.apim.resource_group_name
    apim_name           = module.apim_prod.apim.apim_name

  }
}
