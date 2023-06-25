locals {
    subnets={
        subnet1="192.168.0.0/24"
        subnet2="192.168.1.0/24"
    }
    
    nsg_rules=[
        {
            priority=200
            destination_port_range="22"
        },
        {
            priority=300
            destination_port_range="443"
        }
    ]
}

variable "vnet"{
    type=string
    validation {
        condition=length(var.vnet)>3 && length(var.vnet) <=5 && startswith(var.vnet,"vnet")
        error_message="Invalid input"
    }
    sensitive = false
}
resource "azurerm_virtual_network" "vnet1"{
    name= "${azurerm_resource_group.rg.name}-${var.vnet}"
    location= var.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space = ["192.168.0.0/16"]
}
resource "azurerm_subnet" "my_subnet"{
    for_each = local.subnets
    name=each.key
    address_prefixes = ["${each.value}"]
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet1.name
}
resource "azurerm_network_security_group" "nsg"{
    name="subnet1-nsg"
    location=var.location
    resource_group_name = azurerm_resource_group.rg.name

    dynamic security_rule {
        for_each = local.nsg_rules
        content{
            name="Allow-${security_rule.value.destination_port_range}"
            priority=security_rule.value.priority
            direction="Inbound"
            access="Allow"
            protocol="Tcp"
            source_port_range="*"
            destination_port_range=security_rule.value.destination_port_range
            source_address_prefix="*"
            destination_address_prefix="*"
        }
        
    }
    depends_on = [ azurerm_subnet.my_subnet, azurerm_resource_group.rg ]
}

resource "azurerm_subnet_network_security_group_association" "association-subnet1"{
    for_each = local.subnets
    subnet_id = azurerm_subnet.my_subnet[each.key].id
    
    network_security_group_id = azurerm_network_security_group.nsg.id
}

