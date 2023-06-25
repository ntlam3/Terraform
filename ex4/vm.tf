locals {
    tags={
        environment="dev"
        department="it"
    }
}
resource "azurerm_public_ip" "public-ip01" {
  name                = "${azurerm_resource_group.rg.name}-${var.vm_name}-publicip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_interface" "if01"{
    name= "${azurerm_resource_group.rg.name}-${var.vm_name}-if01"
    location = var.location
    resource_group_name = azurerm_resource_group.rg.name
    ip_configuration {
      name="ipconfig1"
      subnet_id = azurerm_subnet.my_subnet["subnet1"].id
      private_ip_address_allocation = "Static"
      private_ip_address = cidrhost(local.subnets.subnet1,10)
      public_ip_address_id = azurerm_public_ip.public-ip01.id
    }
}

resource "azurerm_virtual_machine" "webvm" {
  name                  = "${azurerm_resource_group.rg.name}-${var.vm_name}"
  location              =  var.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.if01.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "canonical"
    offer     = "ubuntuserver"
    sku       = "18.04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = var.vm_name
    admin_username = "lam_nguyen"
    admin_password = var.vm_password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    for name,value in local.tags: name => value
   
  }
}

resource "azurerm_virtual_machine_extension" "custom_script_extension" {
  name = "customscript"
  virtual_machine_id = azurerm_virtual_machine.webvm.id
  publisher = "Microsoft.Azure.Extensions"
  type="CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
  {
    "fileUris": ["https://${azurerm_storage_account.storage_account.name}.blob.core.windows.net/${azurerm_storage_container.storage_container.name}/${azurerm_storage_blob.storage_blob.name}"],
    "commandToExecute": "sh script.sh"

  }
  SETTINGS
}