# PowerShell-Subnet

[![Build Status](https://dev.azure.com/markwragg/GitHub/_apis/build/status/markwragg.PowerShell-Subnet?branchName=master)](https://dev.azure.com/markwragg/GitHub/_build/latest?definitionId=10&branchName=master) ![Test Coverage](https://img.shields.io/badge/Test Coverage-91.0112359550562%25-lightgrey.svg)

A PowerShell module for cmdlets related to network subnet calculations.

## Installation

The module is published in the PSGallery, so if you have PowerShell 5 can be installed by running:

```powershell
Install-Module Subnet -Scope CurrentUser
```

## Usage

Get the subnet details for a specified network address and mask using slash notation:

```powershell
Get-Subnet 192.168.4.56/24
```

Result:

```text
IPAddress        : 192.168.4.56
MaskBits         : 24
NetworkAddress   : 192.168.4.0
BroadcastAddress : 192.168.4.255
SubnetMask       : 255.255.255.0
NetworkClass     : C
Range            : 192.168.4.0 ~ 192.168.4.255
HostAddresses    : {192.168.4.1, 192.168.4.2, 192.168.4.3, 192.168.4.4...}
HostAddressCount : 254
```

Get the subnet details for a specified network address and mask, as specified via the `-MaskBits` parameter:

```powershell
Get-Subnet -IP 192.168.4.56 -MaskBits 20
```

Result:

```text
IPAddress        : 192.168.4.56
MaskBits         : 20
NetworkAddress   : 192.168.0.0
BroadcastAddress : 192.168.15.255
SubnetMask       : 255.255.240.0
NetworkClass     : C
Range            : 192.168.0.0 ~ 192.168.15.255
HostAddresses    : {192.168.0.1, 192.168.0.2, 192.168.0.3, 192.168.0.4...}
HostAddressCount : 4094
```

Get the subnet details for the current local network IP:

```powershell
Get-Subnet
```

## Other Features

- If the subnet size specified is larger than a /16, the cmdlet will not return the host addresses by default, and instead warn that this would take some time.
If you want to force the return of host addresses for these subnets, use `-Force`.
- If no subnet mask size is specified, the cmdlet will use the default size for the class of address, and show a warning that it has done so.
