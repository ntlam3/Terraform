resource "azurerm_resource_group" "test-rg"{
    name = "ex-test"
    location = "eastus"
}

locals {
    subnets=[{
            subnet_name="subnet1"
            subnet_address_prefix="10.0.0.0/24"
        },
        {
            subnet_name="subnet2"
            subnet_address_prefix="10.0.1.0/24"
        }
    ]
}

resource "azurerm_virtual_network" "vnet1"{
    name=join("-",[azurerm_resource_group.test-rg.name,"vnet1"])
    location = azurerm_resource_group.test-rg.location
    resource_group_name = azurerm_resource_group.test-rg.name
    address_space = ["10.0.0.0/16"]

    dynamic "subnet"{
        for_each = local.subnets
        content{
            name = subnet.value.subnet_name
            address_prefix=subnet.value.subnet_address_prefix
        }
    }
    
}

