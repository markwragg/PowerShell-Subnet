# PowerShell-Subnet

[![Build Status](https://dev.azure.com/markwragg/GitHub/_apis/build/status/markwragg.PowerShell-Subnet?branchName=master)](https://dev.azure.com/markwragg/GitHub/_build/latest?definitionId=10&branchName=master) [![coverage](https://img.shields.io/badge/coverage-99%25-brightgreen.svg)](https://dev.azure.com/markwragg/GitHub/_build/latest?definitionId=10&branchName=master&view=codecoverage-tab)

A cross-platform PowerShell module for cmdlets related to network subnet calculations.

## Installation

The module is published in the PSGallery, so if you have PowerShell 5 or newer can be installed by running:

```powershell
Install-Module Subnet -Scope CurrentUser
```

Or:

```powershell
Install-PSResource Subnet
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

Get the subnet details for the current local network IP (works on Windows, Linux and macOS):

```powershell
Get-Subnet
```

Get just the list of host addresses for a subnet, without the rest of the subnet detail object. `Get-SubnetHostAddress` returns `[ipaddress]` objects by default; use `-AsString` for plain strings instead:

```powershell
Get-SubnetHostAddress 192.168.4.56/29 -AsString
```

Result:

```text
192.168.4.57
192.168.4.58
192.168.4.59
192.168.4.60
192.168.4.61
192.168.4.62
```

`Get-SubnetHostAddress` also accepts the object output by `Get-Subnet` via the pipeline:

```powershell
Get-Subnet 192.168.4.56/29 | Get-SubnetHostAddress
```

Test whether an IP address is within the private (RFC 1918) address space:

```powershell
Test-PrivateIP -IP 172.16.1.2
```

Result:

```text
True
```

Or whether it's within the public address space:

```powershell
Test-PublicIP -IP 8.8.8.8
```

Result:

```text
True
```

## Other Features

- `Get-Subnet`'s `HostAddressCount` is always calculated, regardless of subnet size, since it's just arithmetic. If the subnet size specified is larger than a /16, `Get-Subnet` will not return the full list of individual `HostAddresses` by default, and instead warn that this would take some time.
If you want to force the return of host addresses for these subnets, use `-Force`.
- `Get-SubnetHostAddress`, since returning host addresses is its only job, always calculates and returns them regardless of subnet size -- there's no `-Force` needed. It still warns if the subnet is larger than /16, since that may take some time.
- If no subnet mask size is specified, the cmdlets will use the default size for the class of address, and show a warning that they have done so.
