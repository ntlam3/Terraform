resource "azurerm_storage_account" "storage_account"{
    name="${azurerm_resource_group.rg.name}storage01"
    location = var.location
    resource_group_name = azurerm_resource_group.rg.name
    account_tier = "Standard"
    account_replication_type = "GRS"
    tags={
        for name,value in local.tags: name => value
    }
}

resource "azurerm_storage_container" "storage_container" {
    name="${azurerm_storage_account.storage_account.name}-${time_static.date.unix}"
    storage_account_name = azurerm_storage_account.storage_account.name
    container_access_type = "blob"
}

resource "azurerm_storage_blob" "storage_blob"{
    name="script.sh"
    storage_account_name=azurerm_storage_account.storage_account.name
    storage_container_name=azurerm_storage_container.storage_container.name
    type="Block"
    source=".\\script\\script.sh"
}