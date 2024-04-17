data "template_cloudinit_config" "config" {
  # See https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = templatefile("./scripts/cloud_init.yaml", {
      ip_addr = azurerm_network_interface.nic["linux"].private_ip_address
    })
  }
}

resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 2048
}


resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "test-vm-linux"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = "Standard_B2s"
  admin_username        = "testvm"
  network_interface_ids = [azurerm_network_interface.nic["linux"].id]

  admin_ssh_key {
    username   = "testvm"
    public_key = tls_private_key.key_pair.public_key_openssh
  }

  os_disk {
    caching              = "None"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest" #
  }

  custom_data = data.template_cloudinit_config.config.rendered
  tags        = local.tags
}