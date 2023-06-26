data "azurerm_key_vault" "my_key_vault" {
  name                = "lamnguyen-keyvault"
  resource_group_name = "lam_nguyen"
}

output "vault_uri" {
  value = data.azurerm_key_vault.my_key_vault.vault_uri
}

data "azurerm_key_vault_secret" "my_secret" {
  name         = "terraform"
  key_vault_id = data.azurerm_key_vault.my_key_vault.id
}

output "secret_value" {
  value     = data.azurerm_key_vault_secret.my_secret.value
  sensitive = true
}

resource "tls_private_key" "linuxkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "linuxpemkey"{
  filename = "linuxkey.pem"
  content=tls_private_key.linuxkey.private_key_pem
  depends_on = [
    tls_private_key.linuxkey
  ]
}