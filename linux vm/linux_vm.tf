terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.0"
    }
  }                                                                  
}
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "one_app" {
  name = "app_1"
  location = "eastus"
}
resource "azurerm_virtual_network" "one_app" {
  name                = "virtualNetwork1"
  location            = azurerm_resource_group.one_app.location
  resource_group_name = azurerm_resource_group.one_app.name
  address_space       = ["10.0.0.0/16"]
}
resource "azurerm_subnet" "one_app" {
  for_each =var.subnetname
  name = "subnet${each.key}"
  resource_group_name  = azurerm_resource_group.one_app.name
  virtual_network_name = azurerm_virtual_network.one_app.name
  address_prefixes     = each.value.address_prefixes
}
resource "azurerm_public_ip" "one_app" {
  for_each =var.subnetname
  name                = "${each.value.subnetname}-acceptanceTestPublicIp1"
  resource_group_name = azurerm_resource_group.one_app.name
  location            = azurerm_resource_group.one_app.location
  allocation_method   = "Static"
}
# Create Network Security Group and rule
resource "azurerm_network_security_group" "one_app" {
  for_each =var.subnetname
  name                = "${each.value.subnetname}-NetworkSecurityGroup"
  location            = azurerm_resource_group.one_app.location
  resource_group_name = azurerm_resource_group.one_app.name
# Note that this rule will allow all external connections from internet to SSH port
  
  security_rule {
    name                       = "SSH"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_network_interface" "one_app" {
  for_each =var.subnetname
  name = "${each.value.subnetname}-one_app"
  location            = azurerm_resource_group.one_app.location
  resource_group_name = azurerm_resource_group.one_app.name


  ip_configuration {

    name = "${each.value.subnetname}-internal"
    subnet_id                     = azurerm_subnet.one_app[each.key].id
    public_ip_address_id = azurerm_public_ip.one_app[each.key].id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface_security_group_association" "one_app" {
  for_each = var.subnetname
  network_interface_id = azurerm_network_interface.one_app[each.key].id
  #network_interface_id      = azurerm_network_interface.one_app[each.key].id
  network_security_group_id = azurerm_network_security_group.one_app[each.key].id
}
resource "tls_private_key" "secureadmin_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "public_key" {
    filename = "public_key.pem"
    content =   tls_private_key.secureadmin_ssh.public_key_openssh
}
resource "local_file" "private_key" {
    filename = "private_key.pem"
    content =   tls_private_key.secureadmin_ssh.private_key_pem
}

resource "azurerm_linux_virtual_machine" "one_app" {
  for_each = var.subnetname
 #name = "vm${each.value}"
 #for_each = {for i in range (3)>=i=i+1}
 name = each.value.vmname
  resource_group_name = azurerm_resource_group.one_app.name
  location            = azurerm_resource_group.one_app.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password = "Kina2002"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.one_app[each.key].id,
  ]
 


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
    

  source_image_reference { 
    publisher = "Canonical" 
    offer     = "UbuntuServer" 
    sku       = "16.04-LTS" 
    version   = "latest" 
  } 

   admin_ssh_key { 
    username   = "adminuser" 
    public_key = tls_private_key.secureadmin_ssh.public_key_openssh 

  } 
}