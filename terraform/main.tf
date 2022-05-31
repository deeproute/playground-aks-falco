resource "azurerm_resource_group" "rg" {
  name      = var.resource_group_name
  location  = var.location
}

# Create user assigned identity
resource "azurerm_user_assigned_identity" "umi" {
  name                = "umi"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_kubernetes_cluster" "k8s" {
    name                    = var.cluster_name
    location                = azurerm_resource_group.rg.location
    resource_group_name     = azurerm_resource_group.rg.name
    dns_prefix              = var.cluster_name
    kubernetes_version      = var.kubernetes_version
    private_cluster_enabled = var.private_cluster_enabled

    default_node_pool {
        name            = "agentpool"
        node_count      = var.node_count
        vm_size         = var.vm_size
    }

    identity {
        type = "UserAssigned" # 
        identity_ids = [azurerm_user_assigned_identity.umi.id]
    }

    network_profile {
        load_balancer_sku = "standard"
        network_plugin = "kubenet"
    }

    key_vault_secrets_provider {
        secret_rotation_enabled = true
        secret_rotation_interval = "2m"
    }

    tags = {
        Environment = "lab"
    }
}
