<#
    .SYNOPSIS 
    Run get-help -example Create-VirtualNetwork.ps1 for examples
    
    .EXAMPLE
    .\Create-VirtualNetwork.ps1 -ResourceGroupName "rg-network-neu" -Location "northeurope" -LocationShortName 'neu' -VirtualNetworkPrefix '10.0'
    Transcript started, output file is .\PowerShellLog_2021_21_04_0949.log
    Declaring new Subnet 'snet-adds-neu' with range '10.0.0.0/27'
    Declaring new Subnet 'snet-wks-neu' with range '10.0.0.32/27'
    Declaring new Subnet 'snet-srv-neu' with range '10.0.0.64/27'
    Creating new virtual network  'vnet-whfb-neu' in 'rg-network-neu' resourcegroup.
    Transcript stopped, output file is D:\OneDrive\Private\OneDrive\Work_Predica\Comunity\Blog\whfb\PowerShellLog_2021_21_04_0949.log

    .EXAMPLE
    .\Create-VirtualNetwork.ps1 -ResourceGroupName "rg-network-neu" -Location "northeurope" -LocationShortName 'neu' -VirtualNetworkPrefix '10.10'
    Transcript started, output file is .\PowerShellLog_2021_21_04_0949.log
    Resource group 'rg-network-neu2' does not exist.
    Transcript stopped, output file is D:\OneDrive\Private\OneDrive\Work_Predica\Comunity\Blog\whfb\PowerShellLog_2021_21_04_0949.log

#>
[CmdletBinding()]
param (
    [parameter(Mandatory = $true)]    
    [string] $ResourceGroupName,
    [parameter(Mandatory = $true)]    
    [string] $Location,
    [parameter(Mandatory = $true)]  
    [string] $LocationShortName,
    [parameter(Mandatory = $true)]  
    [string] $VirtualNetworkPrefix
)

#region StartTranscript
Stop-Transcript
$date = Get-date -format "yyyy_dd_MM_HHmm"
$logname = "PowerShellLog_" + $date + ".log"
Start-Transcript -Path .\$logname
#end region


$azAccountTest = (Get-AZContext -ErrorAction SilentlyContinue).count
if ($azAccountTest -eq 0) {
    Write-Host 'Please Log in to Azure Account'
    Connect-AzAccount
}

$rgChecker = (Get-AzResourceGroup -Name $ResourceGroupName -Location $Location -ErrorAction SilentlyContinue).count
if ($rgChecker -eq 0) {
    Write-Host "Resource group '$ResourceGroupName' does not exist."
    Stop-Transcript
    break
}

$vnetRange = $VirtualNetworkPrefix + ".0.0/24"
$vnetName = "vnet-main-" + $LocationShortName
$subnetsData = @(
    $(New-Object PSObject -Property @{Name = "snet-adds-" + $LocationShortName; Range = $VirtualNetworkPrefix + ".0.0/27" }),
    $(New-Object PSObject -Property @{Name = "snet-wks-" + $LocationShortName; Range = $VirtualNetworkPrefix + ".0.32/27" }),
    $(New-Object PSObject -Property @{Name = "snet-srv-" + $LocationShortName; Range = $VirtualNetworkPrefix + ".0.64/27" })
)
$dnsServer = $VirtualNetworkPrefix + ".0.4"
$subnetsConfig = @()

$vnetTest = (Get-AZVirtualNetwork -Name $vnetName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue).count

foreach ($subnet in $subnetsData) {
    Write-Host "Declaring new Subnet '$($subnet.name)' with range '$($subnet.range)'"
    $snet = New-AZVirtualNetworkSubnetConfig -Name $subnet.name -AddressPrefix $subnet.range
    $subnetsConfig += $snet
}

$vnetTest = (Get-AZVirtualNetwork -Name $vnetName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue).count
if ($vnetTest -eq 0) {
    Write-Host "Creating new virtual network  '$vnetName' in '$ResourceGroupName' resourcegroup."
    New-AZVirtualNetwork -Name $vnetName -ResourceGroupName $ResourceGroupName -Location $Location -AddressPrefix $vnetRange -Subnet $subnetsConfig -DnsServer $dnsServer
}
else {
    Write-Host "The follwoing virtual network '$vnetName' already exists."
}

Stop-Transcript
