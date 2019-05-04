locals {
  kubernetes_metadata_name = "terraform-example"
}

# we then retrieve the Kubernetes cluster to be able to use it's credentials
data "azurerm_kubernetes_cluster" "example" {
  name = "${azurerm_kubernetes_cluster.example.name}"
  resource_group_name = "${azurerm_kubernetes_cluster.example.resource_group_name}"
}

provider "kubernetes" {
  load_config_file       = false
  host                   = "${data.azurerm_kubernetes_cluster.example.kube_config.0.host}"
  username               = "${data.azurerm_kubernetes_cluster.example.kube_config.0.username}"
  password               = "${data.azurerm_kubernetes_cluster.example.kube_config.0.password}"
  client_certificate     = "${base64decode(data.azurerm_kubernetes_cluster.example.kube_config.0.client_certificate)}"
  client_key             = "${base64decode(data.azurerm_kubernetes_cluster.example.kube_config.0.client_key)}"
  cluster_ca_certificate = "${base64decode(data.azurerm_kubernetes_cluster.example.kube_config.0.cluster_ca_certificate)}"
}

resource "kubernetes_pod" "example" {
  metadata = {
    name = "${local.kubernetes_metadata_name}"

    labels {
      app = "MyApp"
    }
  }

  spec = {
    container = {
      name  = "random-number-generator"
      image = "tombuildsstuff/builder-app:latest"

      env {
        name  = "REDIS_HOST"
        value = "${azurerm_redis_cache.example.hostname}"
      }

      env {
        name  = "REDIS_KEY"
        value = "${azurerm_redis_cache.example.primary_access_key}"
      }
    }
  }
}

resource "kubernetes_service" "example" {
  metadata = {
    name = "${local.kubernetes_metadata_name}"
  }
  spec {
    selector = {
      app = "${kubernetes_pod.example.metadata.0.labels.app}"
    }
    session_affinity = "ClientIP"
    port {
      port = 8080
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}

output "address" {
  value = "Available at: http://${kubernetes_service.example.load_balancer_ingress.0.ip}:8080"
}
