Throw "This is not a robust file"

.\Create-ResourceGroup.ps1 -ResourceGroupPrefix 'rg' -ResourceGroupLocation 'northeurope' -LocationShortName 'neu'
.\Create-VirtualNetwork.ps1 -ResourceGroupName "rg-network-weu" -Location "northeurope" -LocationShortName 'neu' -VirtualNetworkPrefix '10.10' -Verbose

$List = @(
    $(New-Object PSObject -Property @{Name = 'vm-adds01-neu'; Size = 'Standard_DS1_v2'; Vnet = 'vnet-main-neu'; Subnet = 'snet-adds-main'; IP = "10.10.0.68"; ResourceGroup = 'rg-ad-neu' }),
    $(New-Object PSObject -Property @{Name = 'vm-pki01-neu'; Size = 'Standard_DS1_v2'; Vnet = 'vnet-main-neu'; Subnet = 'snet-srv-main'; IP = "10.10.0.132"; ResourceGroup = 'rg-srv-neu' })
)
.\Deploy-VirtualMachines.ps1 -List $List -Location "north europe" -Credential (Get-Credential)

Write-Host "Run the following commands on DomainController" -ForegroundColor Green
Write-Host '$path = "c:\tools\"
$pathTest = Test-Path -Path $path
if ($pathTest -eq $false ) {
    new-item -ItemType Directory -Path $path
}
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls11, [Net.SecurityProtocolType]::Tls12, [Net.SecurityProtocolType]::Ssl3
[Net.ServicePointManager]::SecurityProtocol = "Tls, Tls11, Tls12, Ssl3"
$outfile = $path + "Scripts.zip"
Invoke-WebRequest -Uri "https://github.com/przybylskirobert/whfb/archive/refs/heads/main.zip" -OutFile $outfile
Expand-Archive -LiteralPath $outfile -DestinationPath $path
$outfile = $path + "AzureADConnect.msi"
Invoke-WebRequest -Uri "https://download.microsoft.com/download/B/0/0/B00291D0-5A83-4DE7-86F5-980BC00DE05A/AzureADConnect.msi" -OutFile $outfile
' -ForegroundColor Yellow
Write-Host 'C:\Tools\whfb-main\Configure-ADDS.ps1 -DomainName "mvp.azureblog.pl" -InstallAD -verbose' -ForegroundColor Yellow
Write-Host 'C:\Tools\whfb-main\Configure-ADDS.ps1 -DomainName "mvp.azureblog.pl" -DeployOU -verbose' -ForegroundColor Yellow
Write-Host 'C:\Tools\whfb-main\Configure-ADDS.ps1 -DomainName "mvp.azureblog.pl" -InstallTemplates -verbose' -ForegroundColor Yellow

#endregion

Write-Host "Run the following commands on PKI" -ForegroundColor Green
Write-Host '$path = "c:\tools\"
$pathTest = Test-Path -Path $path
if ($pathTest -eq $false ) {
    new-item -ItemType Directory -Path $path
}
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls11, [Net.SecurityProtocolType]::Tls12, [Net.SecurityProtocolType]::Ssl3
[Net.ServicePointManager]::SecurityProtocol = "Tls, Tls11, Tls12, Ssl3"
$outfile = $path + "Scripts.zip"
Invoke-WebRequest -Uri "https://github.com/przybylskirobert/whfb/archive/refs/heads/main.zip" -OutFile $outfile
Expand-Archive -LiteralPath $outfile -DestinationPath $path
' -ForegroundColor Yellow
Write-Host 'C:\Tools\whfb-main\Configure-ADCS.ps1 -Verbose' -ForegroundColor Yellow
Write-Host "Populate root Certificate to all devices" -ForegroundColor BlYellowue
Write-Host "Create Certificate Template" -ForegroundColor Yellow
#endregion
