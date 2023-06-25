resource "azurerm_resource_group" "rg"{
    name = local.rg_name
    location = local.location

}

locals {
    rg_name = "ex2"
    location = "eastus"
    tags ={
        environment="staging"
        department="IT"
        purpose="example"
    }
    data ={
        sample3="C:\\Terraform\\ex2\\data\\sample03.txt"
        sample4="C:\\Terraform\\ex2\\data\\sample04.txt"
    }
}

resource "azurerm_storage_account" "sg_account"{
    name = "myaccount${azurerm_resource_group.rg.name}"
    resource_group_name = azurerm_resource_group.rg.name
    location=local.location
    account_tier="Standard"
    account_replication_type="GRS"
    tags={
        for name, value in local.tags: name => value if name != "purpose"
    }
}

variable container_name{
    type=string
    validation{
        condition=length(var.container_name)>4 && substr(var.container_name,0,3)=="lam"
        error_message="The container name should be longer than 4 characters and start with 'lam'"
    }
}
resource "azurerm_storage_container" "my_container"{
    name = var.container_name
    storage_account_name=azurerm_storage_account.sg_account.name
    container_access_type="private"
}

resource "azurerm_storage_blob" "my_data"{
    for_each = {
        sample1="C:\\Terraform\\ex2\\data\\sample01.txt"
        sample2="C:\\Terraform\\ex2\\data\\sample02.txt"
    }
    storage_account_name=azurerm_storage_account.sg_account.name
    storage_container_name=azurerm_storage_container.my_container.name
    type="Block"
    name=each.key
    source=each.value
}

output "storage_account_id"{
    value=azurerm_storage_account.sg_account.name
}

