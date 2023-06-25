terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.61.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  subscription_id="340ced25-5f9a-4ea3-879a-4eafd36ecaf3"
  tenant_id="bf954210-5e4b-4fab-8f3b-2c49402c934c"
  client_id="a6b22d65-bdd5-4cf8-9c53-b9be7f9066f2"
  client_secret="Ayb8Q~hq9Jk3~f9pXrp47RMWxvOeJ~Wg~zxZgbAz"
  features{
    
  }
}