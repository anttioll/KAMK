#!/bin/bash

set -e

if [[ -z $TF_VAR_identifier ]]; then
    echo "Error: Please set the TF_VAR_identifier environment variable."
    exit 1
fi

# Define naming convention
RESOURCE_GROUP_NAME="rg-tfstate-${TF_VAR_identifier}-lpalv"
STORAGE_ACCOUNT_NAME="sttfstate${TF_VAR_identifier}lpalv"  # No dashes in storage account names, sadly.
CONTAINER_NAME="tfstatecontainer"

# Check the length of the storage account name
if [ ${#STORAGE_ACCOUNT_NAME} -gt 24 ]; then
    echo "Error: Storage account name must be between 3 and 24 characters in length."
    exit 1
fi

# Check if the storage account already exists
existing=$(az group list --query "[?contains(name, '$RESOURCE_GROUP_NAME')].name" --output tsv)

if [ -n "$existing" ]; then

    # Check for a second argument and force-delete the resource group if specified
    if [ "$1" == "delete" ]; then
        echo "Force deleting resource group $RESOURCE_GROUP_NAME and its contents..."
        az group delete --name $RESOURCE_GROUP_NAME --yes
        echo "Resource group deleted successfully."
        exit 0
    fi

    echo "Error: Resource Group $RESOURCE_GROUP_NAME already exists."
    exit 1
fi

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location swedencentral

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --auth-mode login
