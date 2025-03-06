terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  #backend "azurerm" {
  #  resource_group_name  = "rg-tfstate-ao-lpalv"
  #  storage_account_name = "sttfstateaolpalv"
  #  container_name       = "tfstatecontainer"
  #  key                  = "terraform.tfstate"
  #}
}

provider "azurerm" {
  features {}
}
