## Provisioning an Application on Azure Kubernetes Service (AKS) with Terraform

[Azure Kubernetes Service](https://azure.microsoft.com/en-us/services/kubernetes-service/) provides a Managed Kubernetes Cluster. In this challenge we're going to use Azure Kubernetes Service to run the application as a Docker Container.

To provision this application using Azure Kubernetes Service we're going to need to use a few different things:

* An Azure Resource Group - which will host the resources we're going to provision.
* An [Azure Redis Cache](https://azure.microsoft.com/en-us/services/cache/) - which will be used by the Application.
* An [Azure Kubernetes Service](https://azure.microsoft.com/en-us/services/kubernetes-service/) which runs the Application as a Docker Container.

Within the Kubernetes Cluster, we'll then create:

* A Kubernetes Pod - which will run our Docker Container
* A Kubernetes Service - which acts as a Load Balancer for the Pod.

We're going to use [HashiCorp Terraform](https://terraform.io) and the [Terraform Provider for AzureRM](https://terraform.io/docs/providers/azurerm) to provision these resources in Azure; and then the [Terraform Provider for Kubernetes](https://terraform.io/docs/providers/kubernetes) to provision the Pod and the Service in Kubernetes.

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

> Kubernetes Cluster

Next we can provision the Kubernetes Cluster within the Resource Group.

The Terraform Resource for a Azure Kubernetes Service (AKS) is `azurerm_kubernetes_cluster` - for which [the documentation can be found here](https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html).

The important things to note here:

* The Kubernetes Cluster must have the Client ID and Client Secret of a Service Principal assigned to it. If you're authenticated to Terraform as a Service Principal, you can use [the `azurerm_client_config` Data Source](https://www.terraform.io/docs/providers/azurerm/d/client_config.html) to obtain the Client ID.

> Connecting to the Kubernetes Cluster

Now that the Kubernetes Cluster exists, we can create the Pod and Service within it.

Terraform uses a separate provider to manage resources in Kubernetes - and as such we need to pass the credentials of the Kubernetes Cluster through to it. For example, you can thread through the credentials from a Kubernetes Cluster resource to the Kubernetes Provider like so:

```
resource "azurerm_kubernetes_cluster" "example" { ... }

provider "kubernetes" {
  load_config_file       = false
  host                   = "${azurerm_kubernetes_cluster.example.kube_config.0.host}"
  username               = "${azurerm_kubernetes_cluster.example.kube_config.0.username}"
  password               = "${azurerm_kubernetes_cluster.example.kube_config.0.password}"
  client_certificate     = "${base64decode(azurerm_kubernetes_cluster.example.kube_config.0.client_certificate)}"
  client_key             = "${base64decode(azurerm_kubernetes_cluster.example.kube_config.0.client_key)}"
  cluster_ca_certificate = "${base64decode(azurerm_kubernetes_cluster.example.kube_config.0.cluster_ca_certificate)}"
}
```

At this point it should be possible to create the Pod and Service in Kubernetes.

> Kubernetes Pod

As Terraform is now connected to the Kubernetes Cluster, we can provision the Pod which runs our Application.

The Terraform Resource for a Kubernetes Pod is `kubernetes_pod` - for which [the documentation can be found here](https://www.terraform.io/docs/providers/kubernetes/r/pod.html).

The important things to note here:

* The docker image is `tombuildsstuff/builder-app`
* The Environment Variables `REDIS_HOST` and `REDIS_KEY` need to be set.
* An `app` label must be set within the `metadata` block (this is so that we can configure the Service later)

> Kubernetes Service

Finally to expose the Pod to the internet we can create a Service in Kubernetes.

The Terraform Resource for a Kubernetes Service is `kubernetes_service` - for which [the documentation can be found here](https://www.terraform.io/docs/providers/kubernetes/r/service.html).

The important things to note here:

* The same `app` selector needs to be used for the Pod and the Service
* We can use a `type` of `LoadBalancer` which will provision a Kubernetes "Software Load Balancer"
* The Port `8080` from the Application must be exposed (but you can use whatever external port you'd like)

### Running this Solution

When you've put together a Terraform Configuration, you can run this [using `terraform apply`](https://www.terraform.io/docs/commands/apply.html) - and when you're done you can destroy these resources [using `terraform destroy`](https://www.terraform.io/docs/commands/destroy.html).

### Example Solution

You can find the example solution for this [in this folder](solutions/kubernetes/).

### Done?

Other challenges [can be found in the README](README.md)
