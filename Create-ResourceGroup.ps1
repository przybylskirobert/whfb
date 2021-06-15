  
<#
    .SYNOPSIS 
    Run get-help -example Create-ResourceGroup.ps1 for examples
    
    .EXAMPLE
    .\Create-ResourceGroup.ps1 -ResourceGroupPrefix 'rg' -ResourceGroupLocation 'northeurope' -LocationShortName 'neu'
    Resource Group 'rg-ad-neu' already exists
    Resource Group 'rg-network-neu' already exists
    Resource Group 'rg-mgmt-neu' already exists
    Resource Group 'rg-srv-neu' already exists
    Resource Group 'rg-wks-neu' already exists
    .EXAMPLE
    .\Create-ResourceGroup.ps1 -ResourceGroupPrefix 'rg' -ResourceGroupLocation 'westeurope' -LocationShortName 'weu'
    Creating new resource group 'rg-ad-weu' in 'westeurope' region
    Creating new resource group 'rg-network-weu' in 'westeurope' region
    Creating new resource group 'rg-mgmt-weu' in 'westeurope' region
    Creating new resource group 'rg-srv-weu' in 'westeurope' region
    Creating new resource group 'rg-wks-weu' in 'westeurope' region

#>
[CmdletBinding()]
param (
    [parameter(Mandatory = $true)]    
    [string] $ResourceGroupPrefix,
    [parameter(Mandatory = $true)]    
    [string] $ResourceGroupLocation,
    [parameter(Mandatory = $true)]    
    [string] $LocationShortName
)


#region StartTranscript
Stop-Transcript -ErrorAction SilentlyContinue
$date = Get-date -format "yyyy_dd_MM_HHmm"
$logname = "PowerShellLog_" + $date + ".log"
Start-Transcript -Path .\$logname
#end region

#region variables
$resourcegroups = @(
    '-ad-',
    '-network-',
    '-mgmt-',
    '-srv-',
    '-wks-'
)
#endregion

#region AZ Context
$azAccountTest = (Get-AZContext -ErrorAction SilentlyContinue).count
if ($azAccountTest -eq 0) {
    Write-Host 'Please Log in to Azure Account'
    Connect-AzAccount
}
#endregion

foreach ($rg in $resourcegroups) {
    $rgName = $ResourceGroupPrefix + $rg + $LocationShortName
    $rgTest = (Get-AzResourceGroup -Name $rgName -Location $ResourceGroupLocation -ErrorAction SilentlyContinue).count 
    if ($rgTest -eq 0) {
        Write-Host "Creating new resource group '$rgName' in '$ResourceGroupLocation' region"
        New-AzResourceGroup  -Name $rgName -Location $ResourceGroupLocation
    }
    else {
        Write-Host "Resource Group '$rgName' already exists"
    }  
}

#region StopTranscript
Stop-Transcript
#endregion