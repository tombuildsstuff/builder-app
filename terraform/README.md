# Provisioning with Terraform

This repository contains an example application, which does two things:

* Inserts a random number into Redis every second.
* Hosts a web server (on port 8080) which displays the random number, refreshing every second client-side.

The application requires a Redis Cache to run, the details for which can be specified as the following Environment Variables:

* `REDIS_HOST` - The Hostname for the Redis Cache (e.g. `example.redis.cache.windows.net`)
* `REDIS_KEY` - The Access Key (Primary or Secondary) which should be used to connect to the Redis Cache (e.g. `efvsdajbfvDFHBHBKNUBJbyifevrweqwe+827168767=`).

The application is a Go binary - but to be able to deploy this easily on Azure we've wrapped it in a Docker Container which is [accessible on the Docker Hub](https://hub.docker.com/r/tombuildsstuff/builder-app) as:

```
tombuildsstuff/builder-app:latest
```

More information on how to debug the application [can be found here](debugging-the-application.html).

## Challenges

Azure has multiple services which allow provisioning Docker Containers, however we're going to focus on 3 of them:

* Using [Azure Container Instance](https://azure.microsoft.com/en-us/services/container-instances/) to run this Example in a Docker Container.
* Using [Azure App Service](https://azure.microsoft.com/en-us/services/app-service/) to run this Example in a Docker Container.
* Using [Azure Kubernetes Service (AKS)](https://azure.microsoft.com/en-us/services/kubernetes-service/) to run the Example in a Docker Container in a Kubernetes Cluster.

In all cases we're going to use [an Azure Redis Cache](https://azure.microsoft.com/en-us/services/cache/) to store the data.

There's a separate guide for each of these, and we'd recommend starting with Container Instance:

1. [Provisioning the Application using Azure Container Instance](challenge-container-instance.md)
2. [Provisioning the Application using Azure App Service](challenge-app-service.md)
3. [Provisioning the Application using Azure Kubernetes Service](challenge-kubernetes.md)

## Extra's

If you've finished those challenges and are interested in exploring more HashiCorp tooling [this guide covers running HashiCorp Consul in Kubernetes](https://learn.hashicorp.com/consul/getting-started-k8s/minikube) ([more information about Consul can be found here](https://www.consul.io)).
