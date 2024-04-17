resource "azurerm_resource_group" "rg" {
  name     = "example-resource-group"
  location = "west europe"
  tags     = local.tags
}

# This ends up in clear text in state FYI, for non-test use a key vault
# pw for windows vm
resource "random_password" "admin_password" {
  length = 24
}

# key-pair for ubuntu vm
resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

/*
Example on how to target a key vault to store the secret. This is for a key vault created outside of terraform using data lookup to find it.
resource "azurerm_key_vault_secret" "admin_pw" {
  name         = "test-admin-password"
  key_vault_id = data.azurerm_key_vault.my_key_vault.id
  value        = random_password.admin_password.result
  tags         = local.tags
}


data "azurerm_key_vault" "my_key_vault" {
  name                = "my-secret-key-value-store"
  resource_group_name = "locked-down-resource-group"
}
*/
