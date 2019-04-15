function Get-Subnet {
    <#
        .SYNOPSIS
            Returns subnet details for the local IP address, or a given network address and mask.

        .DESCRIPTION
            Use to get subnet details  for a given network address and mask, including network address, broadcast address, network class, address range, host addresses and host address count.

        .PARAMETER IP
            The network IP address or IP address with subnet mask via slash notation.

        .PARAMETER MaskBits
            The numerical representation of the subnet mask.

        .PARAMETER Force
            Use to force the return of all host IP addresses regardless of the subnet size (skipped by default for subnets larger than /16).

        .EXAMPLE
            Get-Subnet 10.1.2.3/24

            Description
            -----------
            Returns the subnet details for the specified network and mask, specified as a single string to the -IP parameter.

        .EXAMPLE
            Get-Subnet 192.168.0.1 -MaskBits 23

            Description
            -----------
            Returns the subnet details for the specified network and mask.

        .EXAMPLE
            Get-Subnet

            Description
            -----------
            Returns the subnet details for the current local IP.

        .EXAMPLE
            '10.1.2.3/24','10.1.2.4/24' | Get-Subnet

            Description
            -----------
            Returns the subnet details for two specified networks.
    #>
    param ( 
        [parameter(ValueFromPipeline)]
        [string]
        $IP,

        [ValidateRange(0, 32)]
        [Alias('CIDR')]
        [int]
        $MaskBits,

        [switch]
        $Force
    )
    process {

        if ($PSBoundParameters.ContainsKey('MaskBits')) { 
            $Mask = $MaskBits 
        }

        if (-not $IP) { 
            $LocalIP = (Get-NetIPAddress | Where-Object { $_.AddressFamily -eq 'IPv4' -and $_.PrefixOrigin -ne 'WellKnown' })

            $IP = $LocalIP.IPAddress
            If ($Mask -notin 0..32) { $Mask = $LocalIP.PrefixLength }
        }

        if ($IP -match '/\d') { 
            $IPandMask = $IP -Split '/' 
            $IP = $IPandMask[0]
            $Mask = $IPandMask[1]
        }
        
        $Class = Get-NetworkClass -IP $IP

        if ($Mask -notin 0..32) {

            $Mask = switch ($Class) {
                'A' { 8 }
                'B' { 16 }
                'C' { 24 }
                default { 
                    throw "Subnet mask size was not specified and could not be inferred because the address is Class $Class." 
                }
            }

            Write-Warning "Subnet mask size was not specified. Using default subnet size for a Class $Class network of /$Mask."
        }

        $IPAddr = [ipaddress]::Parse($IP)
        $MaskAddr = [ipaddress]::Parse((Convert-Int64toIP -int ([convert]::ToInt64(("1" * $Mask + "0" * (32 - $Mask)), 2))))        
        $NetworkAddr = [ipaddress]($MaskAddr.address -band $IPAddr.address) 
        $BroadcastAddr = [ipaddress](([ipaddress]::parse("255.255.255.255").address -bxor $MaskAddr.address -bor $NetworkAddr.address))
        
        $HostStartAddr = (Convert-IPtoInt64 -ip $NetworkAddr.ipaddresstostring) + 1
        $HostEndAddr = (Convert-IPtoInt64 -ip $broadcastaddr.ipaddresstostring) - 1

        $HostAddressCount = ($HostEndAddr - $HostStartAddr) + 1
        
        if ($Mask -ge 16 -or $Force) {
            
            Write-Progress "Calcualting host addresses for $NetworkAddr/$Mask.."

            $HostAddresses = for ($i = $HostStartAddr; $i -le $HostEndAddr; $i++) {
                Convert-Int64toIP -int $i
            }
        }
        else {
            Write-Warning "Host address enumeration was not performed because it would take some time for a /$Mask subnet. `nUse -Force if you want it to occur."
        }

        [pscustomobject]@{
            IPAddress        = $IPAddr
            MaskBits         = $Mask
            NetworkAddress   = $NetworkAddr
            BroadcastAddress = $broadcastaddr
            SubnetMask       = $MaskAddr
            NetworkClass     = $Class
            Range            = "$networkaddr ~ $broadcastaddr"
            HostAddresses    = $HostAddresses
            HostAddressCount = $HostAddressCount
        }
    }
}