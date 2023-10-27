/*
    Netmask: 255.255.224.0 = 19
    Broadcast: 10.0.31.255
    HostMin: 10.0.0.1
    HostMax: 10.0.31.254
    Hosts/Net: 8190
*/
resource "azurerm_subnet" "subnet1" {
    name = "subnet1"
    address_prefixes = ["10.0.0.0/19"]
    resource_group_name = azurerm_resource_group.this.name
    virtual_network_name = azurerm_virtual_network.this.name
}

/*
    Netmask: 255.255.224.0 = 19
    Broadcast: 10.0.63.255
    HostMin: 10.0.32.1
    HostMax: 10.0.63.254
    Hosts/Net: 8190
*/
resource "azurerm_subnet" "subnet2" {
    name = "subnet2"
    address_prefixes = ["10.0.32.0/19"]
    resource_group_name = azurerm_resource_group.this.name
    virtual_network_name = azurerm_virtual_network.this.name
}