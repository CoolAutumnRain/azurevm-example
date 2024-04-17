resource "azurerm_windows_virtual_machine" "vm" {
  name                = "test-vm"
  computer_name       = "testvm"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = "Standard_B2s"
  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  admin_username = "testadmin"
  admin_password = random_password.admin_password.result

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "test-vm-os-disk"
  }
  # Azure Terraform provider sucks for these data lookups
  # Use 'az vm image list -f Windows --all -l westeurope -p MicrosoftWindowsServer --architecture x64' to find them manually.
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

data "template_file" "example_script" {
  template = file("myscript.ps1")
  vars = {
    terraform_template_machine_name = azurerm_windows_virtual_machine.vm.name
    terraform_template_network      = var.vnet_name
  }
}

resource "azurerm_virtual_machine_extension" "web_server_install" {
  name                       = "testvm-extension"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.9"
  auto_upgrade_minor_version = true
  # I don't think you need to b64 encode the script and then tell the extension to decode it, but that is shown in a random microsoft blog, see README for link
  settings = jsonencode({
    "commandToExecute" : "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.example_script.rendered)}')) | Out-File -filepath myscript.ps1\" && powershell -ExecutionPolicy Unrestricted -File myscript.ps1"
  })

  /*
    No idea if you need templating - otherwise you can run it ad hoc like so to install IIS for instance
    "commandToExectue": "powershell -ExecutionPolicy Unrestricted Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools"
    
    Might have to use HERE-doc style and protected settings if you want them not in clear text
    https://devblogs.microsoft.com/powershell/arm-dsc-extension-settings/#settings-vs-protectedsettings

    protected_settings = <<SETTINGS
    { 
        "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.ADDS.rendered)}')) | Out-File -filepath myscript.ps1\" && powershell -ExecutionPolicy Unrestricted -File myscript.ps1"
    }
    SETTINGS
  */
}
