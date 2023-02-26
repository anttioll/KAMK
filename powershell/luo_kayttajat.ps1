$users = Import-Csv -Path ".\kayttajat.csv"

foreach ($user in $users) {
    $Name = $user.Name
    $DisplayName = $user.GivenName + " " + $user.SurName
    $GivenName = $user.GivenName
    $SurName = $user.SurName
    $SAM = $user.SamAccountName
    $UPN = $user.UserPrincipalName

    New-ADUser -Name $Name -DisplayName $DisplayName -GivenName $UserGivenName -Surname $SurName -SamAccountName $SAM -UserPrincipalName $UPN -ChangePasswordAtLogon:$True
}
