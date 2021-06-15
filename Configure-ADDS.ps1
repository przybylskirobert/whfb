  
<#
    .SYNOPSIS 
    Run get-help -example Configure-ADDS.ps1 for examples
    
    .EXAMPLE
    .\Configure-ADDS.ps1 -DomainName 'azureblog.pl' -InstallAD
    .EXAMPLE
    .\Configure-ADDS.ps1 -DomainName 'azureblog.pl' -DeployOU
    .EXAMPLE
    .\Configure-ADDS.ps1 -DomainName 'azureblog.pl' -InstallTemplates

#>
[CmdletBinding()]
param (
    [parameter(Mandatory = $true)]    
    [string] $DomainName,
    [switch] $InstallAD,
    [switch] $DeployOU,
    [switch] $InstallTemplates
)
#region StartTranscript
Stop-Transcript -ErrorAction SilentlyContinue
$date = Get-date -format "yyyy_dd_MM_HHmm"
$logname = "PowerShellLog_" + $date + ".log"
Start-Transcript -Path .\$logname
#end region

if ($InstallAD -eq $true) {
    $netbios = ($DomainName.Split('.'))[0]
    Install-WindowsFeature -Name 'AD-Domain-Services','DNS' -IncludeAllSubFeature -IncludeManagementTools  

    Import-Module ADDSDeployment
    Install-ADDSForest `
        -DomainMode "WinThreshold" `
        -DomainName $DomainName `
        -DomainNetbiosName $netbios `
        -ForestMode "WinThreshold" `
        -InstallDns:$true `
        -CreateDnsDelegation:$false `
        -DatabasePath "C:\Windows\NTDS" `
        -LogPath "C:\Windows\NTDS" `
        -SysvolPath "C:\Windows\SYSVOL" `
        -NoRebootOnCompletion:$false `
        -Force:$true
}

if ($DeployOU -eq $true) {
    $dnsroot = (Get-ADDomain).DNSRoot
    $sDSE = (Get-ADRootDSE).defaultNamingContext
    New-ADOrganizationalUnit -Name "Admin" -Path "$sDSE"
    New-ADOrganizationalUnit -Name "Groups" -Path "$sDSE"
    New-ADOrganizationalUnit -Name "Quarantine" -Path "$sDSE"
    New-ADOrganizationalUnit -Name "Stations" -Path "$sDSE"
    New-ADOrganizationalUnit -Name "Servers" -Path "$sDSE"
    New-ADOrganizationalUnit -Name "Tier 0" -Path ("OU=Admin,$sDSE")
    New-ADOrganizationalUnit -Name "Tier 1" -Path ("OU=Admin,$sDSE")
    New-ADOrganizationalUnit -Name "Tier 2" -Path ("OU=Admin,$sDSE")
    New-ADOrganizationalUnit -Name "PAW" -Path ("OU=Tier 0,OU=Admin,$sDSE")
    New-ADOrganizationalUnit -Name "Groups" -Path ("OU=Tier 0,OU=Admin,$sDSE")
    New-ADOrganizationalUnit -Name "Servers" -Path ("OU=Tier 0,OU=Admin,$sDSE")
    New-ADOrganizationalUnit -Name "RDS Infra" -Path ("OU= Servers,OU=Tier 0,OU=Admin,$sDSE")
    New-ADOrganizationalUnit -Name "Update Services" -Path ("OU= Servers,OU=Tier 0,OU=Admin,$sDSE")
    New-ADOrganizationalUnit -Name "Users" -Path ("OU=Tier 0,OU=Admin,$sDSE")
    New-ADOrganizationalUnit -Name "Service Accounts" -Path ("OU=Tier 0,OU=Admin,$sDSE")
    New-ADOrganizationalUnit -Name "Groups" -Path ("OU=Tier 1,OU=Admin,$sDSE")
    New-ADOrganizationalUnit -Name "PAW" -Path ("OU=Tier 1,OU=Admin,$sDSE")
    New-ADOrganizationalUnit -Name "Users" -Path ("OU=Tier 1,OU=Admin,$sDSE")
    New-ADOrganizationalUnit -Name "Service Accounts" -Path ("OU=Tier 1,OU=Admin,$sDSE")
    New-ADOrganizationalUnit -Name "Groups" -Path ("OU=Tier 2,OU=Admin,$sDSE")
    New-ADOrganizationalUnit -Name "Users" -Path ("OU=Tier 2,OU=Admin,$sDSE")
    New-ADOrganizationalUnit -Name "Service Accounts" -Path ("OU=Tier 2,OU=Admin,$sDSE")

    Import-Module ServerManager
    Add-WindowsFeature Gpmc | Out-Null
    Import-Module GroupPolicy

    Set-GpInheritance -target "OU=PAW,OU=Tier 0,OU=Admin,$sDSE" -IsBlocked Yes | Out-Null
    Set-GpInheritance -target "OU=PAW,OU=Tier 1,OU=Admin,$sDSE" -IsBlocked Yes | Out-Null

    New-ADUser -Name "domop" -SamAccountName "domop" -UserPrincipalName "domop@$dnsroot" -path "OU=Users,OU=Tier 0,OU=Admin, $sDSE" -AccountPassword(Read-Host -AsSecureString "Input Password") -Enabled $true
    $groups = @("Domain Admins", "Enterprise Admins", "Schema Admins")
    foreach ($group in $groups) {
        Add-ADGroupMember -Identity $group -Members "domop"
    }

    New-ADUser -Name "Tester" -SamAccountName "Tester" -UserPrincipalName "Tester$dnsroot" -path "OU=Users, OU=Tier 2, OU=Admin, $sDSE" -AccountPassword(Read-Host -AsSecureString "Input Password") -Enabled $true
}


$path = "c:\tools\"
$pathTest = Test-Path -Path $path
if ($pathTest -eq $false ) {
    new-item -ItemType Directory -Path $path
}

if ($InstallTemplates -eq $true) {
    $outfile = $path + "Windows 10 and Windows Server 2016 ADMX.msi"
    $outfile = $outfile.Replace(" ", "_")
    Invoke-WebRequest -Uri "https://download.microsoft.com/download/0/C/0/0C098953-38C6-4DF7-A2B6-DE10A57A1C55/Windows%2010%20and%20Windows%20Server%202016%20ADMX.msi" -OutFile $outfile
    $expression = "C:\Windows\System32\msiexec.exe /i $outfile /quiet"
    C:\Windows\System32\msiexec.exe /i $outfile /quiet
    start-sleep -Seconds 60
    $sourceDirectory = "C:\Program Files (x86)\Microsoft Group Policy\Windows 10 and Windows Server 2016 (Version 2.0)\PolicyDefinitions\*"
    $destinationDirectory = "\\$env:USERDNSDOMAIN\sysvol\$env:USERDNSDOMAIN\policies\PolicyDefinitions"
    Copy-item -Force -Recurse -Verbose $sourceDirectory -Destination $destinationDirectory

    $outfile = $path + "Administrative Templates (.admx) for Windows 10 October 2020 Update.msi"
    $outfile = $outfile.Replace(" ", "_")
    Invoke-WebRequest -Uri "https://download.microsoft.com/download/3/0/6/30680643-987a-450c-b906-a455fff4aee8/Administrative%20Templates%20(.admx)%20for%20Windows%2010%20October%202020%20Update.msi" -OutFile $outfile
    C:\Windows\System32\msiexec.exe /i $outfile /quiet
    start-sleep -Seconds 60
    $sourceDirectory = "C:\Program Files (x86)\Microsoft Group Policy\Windows 10 October 2020 Update (20H2)\PolicyDefinitions\"
    $destinationDirectory = "\\$env:USERDNSDOMAIN\sysvol\$env:USERDNSDOMAIN\policies\PolicyDefinitions"
    Copy-item -Force -Recurse -Verbose $sourceDirectory -Destination $destinationDirectory
}


#region StopTranscript
Stop-Transcript
#endregion