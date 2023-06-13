
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "aks_rg" {
  name     = "feba-rg"
  location = "westus2"
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "feba-aks"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "aks-cluster"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  service_principal {
    client_id     = ""  #need to define the azure client id
    client_secret = ""  #need to define the azure client secret
  }
}

resource "azurerm_mysql_server" "mysql_server" {
  name                = "feba-server"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  sku_name            = "B_Gen5_2"

  storage_profile {
    storage_mb = 5120
  }

  administrator_login          = "myadmin"
  administrator_login_password = "MyP@ssw0rd!"

  version = "5.7"
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "feab-vm"
  location              = azurerm_resource_group.aks_rg.location
  resource_group_name   = azurerm_resource_group.aks_rg.name
  vm_size               = "Standard_DS2_v2"
  network_interface_ids = [azurerm_network_interface.vm_nic.id]
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "feba-nic"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  ip_configuration {
    name                          = "feba-ip"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "feba-subnet"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes      = ["10.0.1.0/24"]
}

resource "azurerm_virtual_network" "vnet" {
  name                = "feba-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
}
