<#
    .SYNOPSIS 
    Run get-help -example Configure-ADCS.ps1 for examples
    
    .EXAMPLE
    .\Configure-ADCS.ps1  -Verbose
#>
[CmdletBinding()]
param (
    
)

#region CAPolicy
Write-Verbose "Creating CAPOlicy.inf file"

$file =  'C:\Windows\CAPolicy.inf'
new-item -ItemType file -Path $file
$content = '[Version]
Signature="$Windows NT$"
[PolicyStatementExtension]
Policies=InternalPolicy
[InternalPolicy]
OID= 1.2.3.4.1455.67.89.5
Notice="Legal Policy Statement"
[Certsrv_Server]
RenewalKeyLength=2048
RenewalValidityPeriod=Years
RenewalValidityPeriodUnits=10
LoadDefaultTemplates=0
AlternateSignatureAlgorithm=1'
$content | Set-content -Path $file

#endregion

#region Install feature
Write-Verbose "Installing ADCS role"
Add-WindowsFeature Adcs-Cert-Authority -IncludeManagementTools
start-sleep -Seconds 300
#endregion

#region Configure ADCS
Write-Verbose "Configuring ADCS"

Install-ADcsCertificationAuthority `
-Credential (Get-Credential) `
-CAType 'EnterpriseRootCa'  `
-CACommonName $env:COMPUTERNAME `
-CADistinguishedNameSuffix ([ADSI]"LDAP://RootDSE").rootDomainNamingContext `
-CryptoProviderName 'RSA#Microsoft Software Key Storage Provider' `
-KeyLength 2048 `
-HashAlgorithmName 'SHA256' `
-ValidityPeriod 'Years' `
-ValidityPeriodUnits 10 `
-DatabaseDirectory 'C:\windows\system32\certLog' `
-LogDirectory 'c:\windows\system32\CertLog' `
-Force

#endregion

#region Certutil
Write-Verbose "Running Certutil code"
Certutil -setreg CA\CRLPeriodUnits 1 
Certutil -setreg CA\CRLPeriod "Weeks"
Certutil -setreg CA\CRLDeltaPeriodUnits 1 
Certutil -setreg CA\CRLDeltaPeriod "Days"  
Certutil -setreg CA\CRLOverlapPeriodUnits 12 
Certutil -setreg CA\CRLOverlapPeriod "Hours"
Certutil -setreg CA\ValidityPeriodUnits 5 
Certutil -setreg CA\ValidityPeriod "Years"
Certutil -setreg CA\AuditFilter 127

#endregion

