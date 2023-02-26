$VM_Name = "Server1"
$VM_Switch = "vSwitch0"
$Install_Media = "X:\isot\Windows_Server_2019.iso"

New-VM -Name $VM_Name -MemoryStartUpBytes 4GB -Generation 2 -NewVHDPath "X:\vms\$VM_Name.vhdx" -NewVHDSizeBytes 40GB -SwitchName $VM_Switch

Add-VMScsiController -VMName $VM_Name
Add-VMDVDDrive -VMName $VM_Name -ControllerNumber 1 -ControllerLocation 0 -Path $Install_Media

$DVDDrive = Get-VMDvdDrive -VMName $VM_Name
Set-VMFirmware -VMName $VM_Name -FirstBootDevice $DVDDrive
