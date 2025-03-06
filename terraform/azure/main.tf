resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = "rg-${var.identifier}"
  tags     = var.default_tags
}

resource "azurerm_virtual_network" "myapp" {
  name                = "vnet-${var.identifier}-${var.myapp}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.69.0.0/16"]
  tags                = var.default_tags
}

resource "azurerm_subnet" "myapp" {
  name                 = "snet-${var.identifier}-${var.myapp}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.myapp.name
  address_prefixes     = ["10.69.1.0/24"]
}

resource "azurerm_public_ip" "myapp" {
  sku                 = "Basic"
  name                = "pip-${var.identifier}-${var.myapp}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  tags                = var.default_tags
}

resource "azurerm_network_interface" "myapp" {
  name                = "nic-${var.identifier}-${var.myapp}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "ipcfg-${var.identifier}-${var.myapp}"
    subnet_id                     = azurerm_subnet.myapp.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myapp.id
  }
  tags = var.default_tags
}

resource "azurerm_network_interface_security_group_association" "myapp" {
  network_interface_id      = azurerm_network_interface.myapp.id
  network_security_group_id = azurerm_network_security_group.myapp.id
}

resource "azurerm_network_security_group" "myapp" {
  name                = "nsg-${var.identifier}-${var.myapp}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  security_rule {
    name                       = "allow_ssh"
    priority                   = 1001
    access                     = "Allow"
    direction                  = "Inbound"
    protocol                   = "Tcp"
    destination_address_prefix = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }
  security_rule {
    name                       = "allow_http"
    priority                   = 1002
    access                     = "Allow"
    direction                  = "Inbound"
    protocol                   = "Tcp"
    destination_address_prefix = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }
  tags = var.default_tags
}

resource "azurerm_linux_virtual_machine" "myapp" {
  name                            = "vm-${var.identifier}-${var.myapp}"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  priority                        = "Spot"
  eviction_policy                 = "Delete"
  size                            = "Standard_DS2_v2"
  admin_username                  = "antero"
  disable_password_authentication = true

  custom_data = base64encode(file("skriptit/linux-perusteet.yaml"))

  network_interface_ids = [
    azurerm_network_interface.myapp.id,
  ]

  admin_ssh_key {
    username   = "antero"
    public_key = file(".secret/id_myapp.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = var.default_tags
}
