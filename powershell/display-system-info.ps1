# Author: Antti Ollikainen

$hostname = Get-Content env:\COMPUTERNAME
$os = Get-CimInstance -ClassName Win32_OperatingSystem
$uptime = $($os.LocalDateTime - $os.LastBootUpTime)
$memory = Get-CimInstance -ClassName Win32_PhysicalMemory
$processes = Get-CimInstance -ClassName Win32_Process  | Sort-Object -Property WorkingSetSize -Descending | Select-Object -Property ProcessId,Name,WorkingSetSize -First 5
$disks = Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3 -and $_.DriveLetter -ne "$null"}
$ifindex = Get-NetAdapter | Select-Object -ExpandProperty ifIndex
$network = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Where-Object {$_.InterfaceIndex -eq $ifindex}
$line_break = "=" * 40

Write-Host $line_break
Write-Host "Hostname: $hostname"
Write-Host "Operating system: $($os.Caption)"
Write-Host "Operating system version: $($os.Version)"
Write-Host $line_break
Write-Host "System date: $($os.LocalDateTime)"
Write-Host "Up time: $uptime"
Write-Host $line_break
Write-Host "Total memory: $([math]::Round($($memory.Capacity / 1MB),2)) megabytes"
Write-Host "Free memory: $([math]::Round($($os.FreePhysicalMemory / 1kB),2)) megabytes"
Write-Host $line_break

Write-Host "Top five processes by memory usage:"
foreach($process in $processes) {
  Write-Host "ProcessId: $($process.ProcessId)" 
  Write-Host "Name: $($process.Name)"
  Write-Host "Working set size: $([math]::Round($($process.WorkingSetSize / 1MB),2)) megabytes"
  Write-Host
}
Write-Host $line_break
Write-Host "System hard drives:"
foreach($disk in $disks) {
  Write-Host "Drive: $($disk.DeviceID)"
  Write-Host "Size: $([math]::Round($($disk.Size / 1GB),2)) gigabytes"
  Write-Host "Free Space: $([math]::Round($($disk.FreeSpace / 1GB),2)) gigabytes"
}
Write-Host $line_break
Write-Host "DHCP enabled: $($network.DHCPEnabled)"
Write-Host "IPv6 Address: $($network.IPAddress[1])"
Write-Host "IPv4 Address: $($network.IPAddress[0])"
Write-Host "Subnet mask: $($network.IPSubnet)"
Write-Host "Default gateway: $($network.DefaultIPGateway)"
Write-Host $line_break
