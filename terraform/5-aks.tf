/*
    Create a managed identity, so that we can create a private load balancer in our subnet.
    This will help to auth with Azure Entra ID
*/
resource "azurerm_user_assigned_identity" "base" {
  name                = "base"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

/*
    Bind the managed identity with (minimum) Network Contributor role
*/
resource "azurerm_role_assignment" "base" {
  scope                = azurerm_resource_group.this.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.base.principal_id
}

/**/
resource "azurerm_kubernetes_cluster" "this" {
  name                = "${local.env}-${local.aks_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  dns_prefix          = "${local.env}aks1"

  kubernetes_version        = local.aks_version
  automatic_channel_upgrade = "stable"
  private_cluster_enabled   = false
  node_resource_group       = "${local.resource_group_name}-${local.env}-${local.aks_name}"

  /*
    if you want private clusters. It's in preview.
    api_server_access_profile {
        vnet_integration_enabled = true
        subnet_id = azurerm_subnet.subnet1.id
    }
    */

  # For production change to "Standard"
  sku_tier = "Free"

  # Open ID connect provider - required for workload identity
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  /*
        Allows AKS to use native network (check also selium etc.)
    */
  network_profile {
    network_plugin = "azure"
    dns_service_ip = "10.0.64.10"
    # AKS will use cidr to allocate IPs to nodes
    service_cidr = "10.0.64.0/19"
  }

  default_node_pool {
    name                 = "general"
    vm_size              = "Standard_D2_v2"
    vnet_subnet_id       = azurerm_subnet.subnet1.id
    orchestrator_version = local.aks_version
    type                 = "VirtualMachineScaleSets"
    enable_auto_scaling  = true
    node_count           = 1
    min_count            = 1
    max_count            = 10

    node_labels = {
      role = "general"
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.base.id]
  }

  tags = {
    env = local.env
  }

  lifecycle {
    ignore_changes = [default_node_pool[0].node_count]
  }

  depends_on = [
    azurerm_role_assignment.base
  ]
}