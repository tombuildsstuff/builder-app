## Provisioning an Application on Azure App Service with Terraform

[Azure App Services](https://azure.microsoft.com/en-us/services/app-service/) is a managed service which allows you to run all kinds of Applications and Websites. In this challenge we're going to use Azure App Service to run the application as a Docker Container.

To provision this application using Azure App Service we're going to need to use a few different things:

* An Azure Resource Group - which will host the resources we're going to provision.
* An [Azure Redis Cache](https://azure.microsoft.com/en-us/services/cache/) - which will be used by the Application.
* An [Azure App Service Plan](https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans) (formerly known as a Server Farm) which will host the App Service.
* An [Azure App Service](https://azure.microsoft.com/en-us/services/app-service/) (formerly known as a Website) which runs the Application as a Docker Container on the capacity provided by the App Service Plan.

We're going to use [HashiCorp Terraform](https://terraform.io) and the [Terraform Provider for AzureRM](https://terraform.io/docs/providers/azurerm) to provision these resources in Azure.

## Getting Started with Terraform

If you've not used Terraform before, you may wish to take a look at [the Getting Started with Terraform and Azure guide](https://learn.hashicorp.com/terraform/azure/intro_az).

### Provisioning the Resources in Azure

> Resource Group

Almost all resources in Azure are contained within a Resource Group. To create a simple Resource Group we need two items: a `name` (which should be unique within your Subscription) and `location` (which is an Azure Region, such as `West US`).

The Terraform Resource for a Resource Group is `azurerm_resource_group` - for which [the documentation can be found here](https://www.terraform.io/docs/providers/azurerm/r/resource_group.html).

> Redis Cache

We can provision a Redis Cache within the Resource Group - whilst Azure supports multiple SKU's for a Redis Cache (such as `Basic`, `Standard` and `Premium`) - since this is an example we can use the `Basic` SKU (which allows up to 250MB of storage).

The Terraform Resource for a Redis Cache is `azurerm_redis_cache` - for which [the documentation can be found here](https://www.terraform.io/docs/providers/azurerm/r/redis_cache.html).

_NOTE:_ we can use Terraform's [Interpolation Syntax](https://www.terraform.io/docs/configuration-0-11/interpolation.html) to reference between resources, like so:

```
resource "azurerm_resource_group" "test" { ... }

resource "azurerm_redis_cache" "test" {
  ...
  resource_group_name = "${azurerm_resource_group.test.name}"
  location            = "${azurerm_resource_group.test.location}"
  ...
}
```

> App Service Plan

Azure App Services can be configured in different ways: with Linux/Windows as a host operating system, and in Dedicated or Consumption (Shared) modes. Since we're provisioning a Docker Container, we need to use a Dedicated Linux App Service Plan (rather than a shared one).

The Terraform Resource for an App Service Plan is `azurerm_app_service_plan` - for which [the documentation can be found here](https://www.terraform.io/docs/providers/azurerm/r/app_service_plan.html).

The important things to note here:

* The SKU must be a Tier of `Standard` and a Size of `S1`.
* The App Service Plan must have a `kind` of `Linux`.
* The App Service Plan must be `reserved` (reserved = true).

> App Service

Finally we can provision an App Service within the App Service Plan, which will allow us to run the Application as a Container.

The Terraform Resource for an App Service is `azurerm_app_service` - for which [the documentation can be found here](https://www.terraform.io/docs/providers/azurerm/r/app_service.html).

The important things to note here:

* The Application can be found as the Docker Image `tombuildsstuff/builder-app` and specified within the `site_config` block using the `linux_fx_version`: `DOCKER|tombuildsstuff/builder-app:latest`.
* The `app_command_line` within the `site_config` block should be set to an empty string (since this is set within the Docker Container).
* We need to set the Environment Variables for the Redis Host (`REDIS_HOST`) and the Redis (Access) Key (`REDIS_KEY`) - which can be set using [the `app_settings` block](https://www.terraform.io/docs/providers/azurerm/r/app_service.html#app_settings).
* As we're using a Docker Container (which doesn't require persistence) the App Setting `WEBSITES_ENABLE_APP_SERVICE_STORAGE` must be set to `false`.
* As we're pulling Docker Images from the Docker Hub - the App Setting `DOCKER_REGISTRY_SERVER_URL` must be set to `https://index.docker.io`.

### Running this Solution

When you've put together a Terraform Configuration, you can run this [using `terraform apply`](https://www.terraform.io/docs/commands/apply.html) - and when you're done you can destroy these resources [using `terraform destroy`](https://www.terraform.io/docs/commands/destroy.html).

### Example Solution

You can find the example solution for this [in this folder](solutions/app-service/).

### Done?

Other challenges [can be found in the README](README.md)
