data "template_file" "cloudinitdata" {
    template = file("script.sh")
}
resource "tls_private_key" "linuxkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "linuxpemkey"{
    filename = "linuxkey.pem"
    content = tls_private_key.linuxkey.private_key_pem
}
resource "azurerm_linux_virtual_machine" "vm01"{
    name=var.vm
    location=var.location
    resource_group_name = azurerm_resource_group.rg.name
    network_interface_ids = [azurerm_network_interface.if1.id]
    size = "Standard_DS1_v2"
    custom_data = base64encode(data.template_file.cloudinitdata.rendered)
    admin_username = "lam_nguyen"
    admin_ssh_key {
      username="lam_nguyen"
      public_key=tls_private_key.linuxkey.public_key_openssh
    }
    source_image_reference {
      
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-focal"
        sku       = "20_04-lts"
        version   = "latest"
    }
    os_disk {
        name              = "myosdisk1"
        caching           = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }
       
    
    tags = {
        environment = "staging"
  }
}
