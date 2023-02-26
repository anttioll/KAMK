$regex = "version"
$cmd = net config workstation

switch -regex ($cmd) {
  $regex {Write-Host $switch.current}
}

Write-Host $regex.GetType()
