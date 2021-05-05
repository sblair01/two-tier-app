

#create a policy definition to restrict resource_group scope to CentralUS

# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.56.0"
    }
  }
}
# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "sample_app" {
  name     = "two-tier-app"
  location = "centralus"
  //location = var.location
}
resource "azurerm_network_security_group" "db" {
  name                = "database-sg"
  location            = var.location
  resource_group_name = azurerm_resource_group.sample_app.name
  
}

resource "azurerm_network_security_group" "web" {
  name                = "web-sg"
  location            = var.location
  resource_group_name = azurerm_resource_group.sample_app.name
  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "sshttph"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ssh"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


# Create a virtual network within the resource group
resource "azurerm_virtual_network" "example" {
  name                = "simple-app-network"
  resource_group_name = azurerm_resource_group.sample_app.name
  location            = var.location
  address_space       = ["10.0.0.0/20"]
  vm_protection_enabled = true

  subnet {
    name           = "db1"
    address_prefix = "10.0.0.0/22"
    security_group = azurerm_network_security_group.db.id

   
  }

  subnet {
    name           = "web1"
    address_prefix = "10.0.4.0/23"
    
  }

  subnet {
    name           = "spare1"
    address_prefix = "10.0.6.0/23"
   
    
  }

  tags = {
    environment = "Production"
    owner = "sablair"
    project = "2 tier app"
  }
}

  
  
