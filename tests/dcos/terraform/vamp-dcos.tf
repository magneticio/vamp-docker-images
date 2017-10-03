variable "ssh_key" {
    default = ""
}

resource "azurerm_resource_group" "dcos" {
  name     = "ci-dcos"
  location = "East US"
}

resource "azurerm_container_service" "dcos" {
  name                   = "ci-dcos"
  location               = "${azurerm_resource_group.dcos.location}"
  resource_group_name    = "${azurerm_resource_group.dcos.name}"
  orchestration_platform = "DCOS"

  master_profile {
    count      = 1
    dns_prefix = "magneticio-ci-dcos-master"
  }

  linux_profile {
    admin_username = "dcos"

    ssh_key {
      key_data = "${var.ssh_key}"
    }
  }

  agent_pool_profile {
    name       = "default"
    count      = 3
    dns_prefix = "magneticio-ci-dcos-agent"
    vm_size    = "Standard_A3"
  }

  diagnostics_profile {
    enabled = false
  }

  tags {
    Environment = "CI"
  }
}

output "dcos-master-url" {
  value = "${azurerm_container_service.dcos.master_profile}"
}

output "dcos-agent-pool-url" {
  value = "${azurerm_container_service.dcos.agent_pool_profile}"
}
