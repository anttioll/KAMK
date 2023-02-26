$VM_Name = "Kone0"
$Switch = "vSwitch0"
$Install_Media = "X:\isot\Windows_10.iso"

# Luodaan uusi virtualisoitu kone
New-VM -Name $VM_Name -MemoryStartupBytes 4GB -Generation 2 -NewVHDPath "X:\vms\$VM_Name.vhdx" -NewVHDSizeBytes 40GB -SwitchName $Switch

# Luodaan koneelle DVD-asema
Add-VMScsiController -VMName $VM_Name
Add-VMDvdDrive -VMName $VM_Name -ControllerNumber 1 -ControllerLocation 0 -Path $Install_Media

# Asetetaan kone käynnistymään DVD-asemalta
$DVDDrive = Get-VMDvdDrive -VMName $VM_Name
Set-VMFirmware -VMName $VM_Name -FirstBootDevice $DVDDrive
