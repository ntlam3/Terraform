resource "azurerm_resource_group" "rg"{
    name="${var.resource_group_name}-${random_string.random.result}"
    location="southeastasia"
}

resource "random_string" "random" {
    length=10
    special=true
    override_special="-_()"
    
}

resource "random_integer" "random_no"{
    min=1000
    max=9999
}
output "random_value"{
  value       = "${random_string.random.result}"
  
}
output "random_integer"{
    value = random_integer.random_no.result
}

locals {
  storage_name = join("",[var.resource_group_name,azurerm_resource_group.rg.location])

}

resource "azurerm_storage_account" "storage_acc"{
    count=2
    name="${local.storage_name}${random_integer.random_no.result}${count.index}"
    resource_group_name=azurerm_resource_group.rg.name
    location=azurerm_resource_group.rg.location
    account_tier="Standard"
    account_replication_type="LRS"
}

resource "azurerm_storage_container" "my_container"{
    count=2
    name="container${local.storage_name}${count.index}"
    storage_account_name=azurerm_storage_account.storage_acc[count.index].name
    container_access_type="private"
}

resource "azurerm_storage_blob" "my_blob"{
    count=4
    count.index