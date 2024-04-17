locals {
  types_of_vm = toset(["linux", "windows"])
}

resource "azurerm_network_interface" "nic" {
  for_each            = local.types_of_vm
  name                = "test-nic-${each.key}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "test-ip-configuration-${each.key}"
    subnet_id                     = data.azurerm_subnet.subnet.id // Cant be arsed to create the network so data lookup it is
    private_ip_address_allocation = "Dynamic"

    public_ip_address_id = null // No public IP, feel free to change if needed
    primary              = true
  }
}

data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = azurerm_resource_group.rg.name
}