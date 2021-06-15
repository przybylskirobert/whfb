Throw "This is not a robust file"

.\Create-ResourceGroup.ps1 -ResourceGroupPrefix 'whfb-rg' -ResourceGroupLocation 'westeurope' -LocationShortName 'weu'
.\Create-VirtualNetwork.ps1 -ResourceGroupName "whfb-rg-network-weu" -Location "westeurope" -LocationShortName 'weu' -VirtualNetworkPrefix '192.168' -Verbose

$List = @(
    $(New-Object PSObject -Property @{Name = 'vm-adds01-neu'; Size = 'Standard_DS1_v2'; Vnet = 'vnet-whfb-weu'; Subnet = 'snet-adds-weu'; IP = "192.168.0.4"; ResourceGroup = 'whfb-rg-ad-weu' }),
    $(New-Object PSObject -Property @{Name = 'vm-pki01-neu'; Size = 'Standard_DS1_v2'; Vnet = 'vnet-whfb-weu'; Subnet = 'snet-srv-weu'; IP = "192.168.0.68"; ResourceGroup = 'whfb-rg-srv-weu' })
)
.\Deploy-VirtualMachines.ps1 -List $List -Location "west europe" -Credential (Get-Credential)

Write-Host "Run the following commands on DomainController" -ForegroundColor Blue
Write-Host '.\Configure-ADDS.ps1 -DomainName "azureblog.pl" -InstallAD' -ForegroundColor Blue
Write-Host '.\Configure-ADDS.ps1 -DomainName "azureblog.pl" -DeployOU' -ForegroundColor Blue
Write-Host '.\Configure-ADDS.ps1 -DomainName "azureblog.pl" -InstallTemplates' -ForegroundColor Blue

#endregion

Write-Host "Run the following commands on PKI" -ForegroundColor Blue
Write-Host '.\Configure-ADCS.ps1 -Verbose' -ForegroundColor Blue
Write-Host "Populate root Certificate to all devices" -ForegroundColor Blue

Write-Host "Create Certificate Template" -ForegroundColor Blue
#endregion