resource "azurerm_resource_group" "example" {
  name     = "${var.prefix}-resources"
  location = "${var.location}"
}

resource "azurerm_redis_cache" "example" {
  name                = "${var.prefix}-redis"
  location            = "${azurerm_resource_group.example.location}"
  resource_group_name = "${azurerm_resource_group.example.name}"
  capacity            = 0
  family              = "C"
  sku_name            = "Basic"
  enable_non_ssl_port = false

  redis_configuration {}
}

resource "azurerm_container_group" "example" {
  name                = "${var.prefix}-container"
  location            = "${azurerm_resource_group.example.location}"
  resource_group_name = "${azurerm_resource_group.example.name}"
  ip_address_type     = "public"
  dns_name_label      = "${var.prefix}-container"
  os_type             = "Linux"

  container {
    name   = "random-number-generator"
    image  = "tombuildsstuff/builder-app"
    cpu    = "0.5"
    memory = "0.5"

    # expose the public port
    ports = {
      port     = 8080
      protocol = "TCP"
    }

    environment_variables = {
      "REDIS_HOST" = "${azurerm_redis_cache.example.hostname}"
    }

    secure_environment_variables = {
      "REDIS_KEY" = "${azurerm_redis_cache.example.primary_access_key}"
    }
  }
}

output "address" {
  value = "Available at: http://${azurerm_container_group.example.fqdn}:8080"
}
