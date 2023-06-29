locals {
    subnets={
        subnet1="172.16.0.0/24"
        subnet2="172.16.1.0/24"
    }
    tags={
        department="it"
        environment="dev"
    }
    security_rules=[
        {
            priority=500
            destination_port_range=80
        },
        
        {
            priority=550
            destination_port_range=443
        },
        
        {
            priority=443
            destination_port_range=22
        }
    ]
}
resource "azurerm_virtual_network" "vnet1" {
    name = "lam_nguyen_vnet1"
    location = var.location
    resource_group_name=azurerm_resource_group.rg.name
    address_space = ["172.16.0.0/16"]
    tags = {
      for name,value in local.tags: name => value
    }
}

resource "azurerm_subnet" "subnets" {
    for_each=local.subnets
    name=each.key
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet1.name
    address_prefixes = [each.value]

  
}

resource "azurerm_network_interface" "if1" {
    name="${var.vm}-interface-${random_string.random.result}"
    resource_group_name = azurerm_resource_group.rg.name
    location=var.location
    ip_configuration {
      name="${var.vm}-ipconfig"
      subnet_id=azurerm_subnet.subnets["subnet1"].id
      private_ip_address_allocation = "Static"
      private_ip_address = "172.16.0.10"
      public_ip_address_id = azurerm_public_ip.pubip1.id
    }
    
  
}
output "ip_configuration"{
    value=azurerm_network_interface.if1.ip_configuration[0].private_ip_address
}

resource "azurerm_public_ip" "pubip1" {
  name                = "${var.vm}-pubip1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  allocation_method   = "Dynamic"

  tags = {
    for name, value in local.tags: name => value
  }
}

resource "azurerm_network_security_group" "nsg"{
    name="Subnet1_NSG"
    location=var.location
    resource_group_name = azurerm_resource_group.rg.name

    dynamic "security_rule"{
        for_each = local.security_rules
        content {
          name="Allow_port_${security_rule.value.destination_port_range}"
          priority = security_rule.value.priority
          direction="Inbound"
          access="Allow"
          protocol="Tcp"
          source_port_range = "*"
          destination_port_range = security_rule.value.destination_port_range
          source_address_prefix = "*"
          destination_address_prefix = azurerm_network_interface.if1.ip_configuration[0].private_ip_address
        }
    }
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
    subnet_id = azurerm_subnet.subnets["subnet1"].id
    network_security_group_id = azurerm_network_security_group.nsg.id
}
