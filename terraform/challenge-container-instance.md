## Provisioning an Application on Azure Container Instance with Terraform

[Azure Container Instance](https://azure.microsoft.com/en-us/services/container-instances/) is a service which allows Azure to run one or more Docker Containers. In this challenge we're going to use Azure Container Instance to run the application.

To provision this application using Azure Container Instance we're going to need to use a few different things:

* An Azure Resource Group - which will host the resources we're going to provision.
* An [Azure Redis Cache](https://azure.microsoft.com/en-us/services/cache/) - which will be used by the Application.
* An [Azure Container Instance](https://azure.microsoft.com/en-us/services/container-instances/) to run the Application as a Docker Container.

We're going to use [HashiCorp Terraform](https://terraform.io) and the [Terraform Provider for AzureRM](https://terraform.io/docs/providers/azurerm) to provision these resources in Azure.

## Getting Started with Terraform

If you've not used Terraform before, this section should give you a quick overview.

TODO a link to a guide about how to get started with Terraform, plan, apply, destroy etc

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

> Container Instance

Finally we can provision a Container Instance within the Resource Group, which will run the Application as a Container.

The Terraform Resource for a Container Instance is `azurerm_container_group` - for which [the documentation can be found here](https://www.terraform.io/docs/providers/azurerm/r/container_group.html).


The important things to note here:

* The Application can be found as the Docker Image `tombuildsstuff/builder-app`.
* We need to expose port `8080` to allow the web page to be visible, which can be done [using the `ports` block](https://www.terraform.io/docs/providers/azurerm/r/container_group.html#ports).
* We need to set the Environment Variables for the Redis Host (`REDIS_HOST`) and the Redis (Access) Key (`REDIS_KEY`) - which can be set using [the `environment_variables` block](https://www.terraform.io/docs/providers/azurerm/r/container_group.html#environment_variables).

_NOTE_ since the Redis (Access) Key is a sensitive value, you may wish to use the `secure_environment_variables` to store the Environment Variables.


### Running this Solution

When you've put together a Terraform Configuration, you can run this [using `terraform apply`](https://www.terraform.io/docs/commands/apply.html) - and when you're done you can destroy these resources [using `terraform destroy`](https://www.terraform.io/docs/commands/destroy.html).

### Example Solution

You can find the example solution for this [in this folder](solutions/container-instance/).

### Done?

Other challenges [can be found in the README](README.md)
