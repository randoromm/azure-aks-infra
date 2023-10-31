/*
    Netmask: 255.255.0.0 = 16
    Broadcast: 10.0.255.255
    HostMin: 10.0.0.1
    HostMax: 10.0.255.254
    Hosts/Net: 65534
*/
resource "azurerm_virtual_network" "this" {
  name                = "${local.env}-main"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  tags = {
    env = local.env
  }
}
