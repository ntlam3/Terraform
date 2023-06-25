locals {
    nsg_rules=[
        {
            priority=200
            destination_port_range="3389"
        },
        {
            priority=300
            destination_port_range="443"
        }
    ]
}
resource azurerm_network_security_group "nsg1"{
    name="appnsg"
    location=var.location
    resource_group_name=var.resource_group_name
    
    dynamic security_rule{
        for_each=local.nsg_rules
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
    depends_on = [
        azurerm_resource_group.rg
    ]
}

