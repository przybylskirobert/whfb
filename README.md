# Windows Hello For Business Repository

Hi there!
This is my place where I'm putting all the scripts and config files regarding Windows Hello For Business configuration.

## Environment Overview
Scripts from this repo will help you with Windows Hello for Business LAB deployment.
LAB contains the following resources:
- Resource Groups (rg-ad-neu, rg-network-neu, rg-mgmt-neu, rg-srv-neu, rg-wks-neu)
- Virtual network (vnet-main-neu - X.X.0.0/24, with subnets snet-adds-neu X.X.0.0/27, snet-wks-neu X.X.0.32/27, snet-srv-neu X.X.0.64/27)
- Domain Controller (vm-adds01-neu 10.10.0.4)
- AD CS Server (vm-pki01-neu, 10.10.0.68)
- Hyper-V server (vm-hv01-neu, 10.10.0.69)

All test machines should be deployed under the Hype-V server to simulate TPM usage.

## Scripts Overview
- [Configure-ADCS.ps1](https://github.com/przybylskirobert/whfb/blob/master/Configure-ADCS.ps1) - Script used to Configure AD CS services
- [Configure-ADDS.ps1](https://github.com/przybylskirobert/whfb/blob/master/Configure-ADDS.ps1) 
- [Create-ResourceGroup.ps1](https://github.com/przybylskirobert/whfb/blob/master/Create-ResourceGroup.ps1) 
- [Create-VirtualNetwork.ps1](https://github.com/przybylskirobert/whfb/blob/master/Deploy-VirtualMachines.ps1)  
- [Steps.ps1](https://github.com/przybylskirobert/whfb/blob/master/Steps.ps1) 

## Environment Deployment

To deploy the environment open Steps.ps1 file and proceed according to the instructions.

Scripts wlak through is available [here](https://www.azureblog.pl/tag/windows-hello/) 
