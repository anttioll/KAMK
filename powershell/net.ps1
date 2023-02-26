$NetAdapter = Get-NetAdapter -Name "Ethernet"

New-VMSwitch -Name "ESwitch0" -AllowManagementOS $True -NetAdapterName $NetAdapter