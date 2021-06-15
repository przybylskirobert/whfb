<#
    .SYNOPSIS 
    Run get-help -example Deploy-VirtualMachines.ps1 for examples
    
    .EXAMPLE
    $List = @(
        $(New-Object PSObject -Property @{Name = 'vm-adds01-neu'; Size = 'Standard_DS1_v2'; Vnet = 'vnet-whfb-weu'; Subnet = 'snet-adds-weu'; IP = "192.168.0.4"; ResourceGroup = 'tstrg-ad-weu' }),
        $(New-Object PSObject -Property @{Name = 'vm-pki01-neu'; Size = 'Standard_DS1_v2'; Vnet = 'vnet-whfb-weu'; Subnet = 'snet-srv-weu'; IP = "192.168.0.68"; ResourceGroup = 'tstrg-srv-weu' }),
        $(New-Object PSObject -Property @{Name = 'vm-hv01-neu'; Size = 'Standard_E4s_v3'; Vnet = 'vnet-whfb-weu'; Subnet = 'snet-srv-weu'; IP = "192.168.0.69"; ResourceGroup = 'tstrg-srv-weu' })
        )
    .\Deploy-VirtualMachines.ps1 -List $List -Location "west europe" -Credential (Get-Credential)

#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $True)]
    [PSOBject] $List,
    [parameter(Mandatory = $true)]    
    [string] $Location,
    [parameter(Mandatory = $true)]    
    [PSCredential] $Credential
)

#region StartTranscript
Stop-Transcript -ErrorAction SilentlyContinue
$date = Get-date -format "yyyy_dd_MM_HHmm"
$logname = "PowerShellLog_" + $date + ".log"
Start-Transcript -Path .\$logname
#end region

#region AZ Context
$azAccountTest = (Get-AZContext -ErrorAction SilentlyContinue).count
if ($azAccountTest -eq 0) {
    Write-Host 'Please Log in to Azure Account'
    Connect-AzAccount
}
#endregion


#region deploy vms
foreach ($vm in $list) {
    $vmName = $vm.name
    $vmSize = $vm.Size
    $vmVnet = $vm.Vnet
    $vmSnet = $vm.Subnet
    $vmIP = $vm.IP
    $vmRg = $vm.ResourceGroup
    $vmNIC = $vmName + "-nic"
    $vmPIP = $vmname + "-pip"

    $rgChecker = (Get-AzResourceGroup -Name $vmRg -Location $Location -ErrorAction SilentlyContinue).count
    if ($rgChecker -eq 0) {
        Write-Host "Resource group '$vmRg' does not exist."
        Stop-Transcript
        break
    }

    $vnetConfig = Get-AZVirtualNetwork -Name $vmVnet -ErrorAction SilentlyContinue
    if (($vnetConfig).count -eq 0 ){
        Write-Host "Virtual Network '$vmVnet' does not exist."
        Stop-Transcript
        break 
    }

    $snetID = ($vnetConfig.Subnets | Where-Object Name -eq $vmSnet).id
    $pipConfig = New-AZPublicIpAddress -Name $vmPIP -ResourceGroupName $vmRg -Location $Location -AllocationMethod Dynamic
    $nicConfig = New-AZNetworkInterface -Name $vmNIC -ResourceGroupName $vmRg -Location $Location -SubnetId  $snetID -PublicIpAddressId $pipConfig.Id -PrivateIpAddress $vmIP
    
    $vmConfig = New-AZVMConfig -VMName $vmname -VMSize $vmSize
    $vmConfig = Set-AZVMOperatingSystem -VM $vmConfig -Windows -ComputerName $vmname -Credential $credential -ProvisionVMAgent -EnableAutoUpdate
    $vmConfig = Add-AZVMNetworkInterface -VM $vmConfig -Id $nicConfig.Id
    $vmConfig = Set-AZVMSourceImage -VM $vmConfig -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2016-Datacenter' -Version latest
    $vmConfig = Set-AZVMBootDiagnostic -Disable -VM $vmConfig    
    Write-Host "Creating vm '$vmname' in resourcegroup '$vmRg' - VM Size '$vmSize' VM IP '$vmIP'"
    New-AZVM -ResourceGroupName $vmRg -Location $Location -VM $vmConfig -Verbose
}

#endregion

#region StopTranscript
Stop-Transcript
#endregion