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
            Use to force the return of the full list of host IP addresses regardless of the subnet size (skipped by default for subnets larger than /16). HostAddressCount is always calculated and returned, regardless of subnet size or whether -Force is used.

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

        $Mask = $null
        if ($PSBoundParameters.ContainsKey('MaskBits')) { $Mask = $MaskBits }

        $Details = Resolve-Subnet -IP $IP -Mask $Mask

        $NetworkAddr = $Details.NetworkAddr
        $BroadcastAddr = $Details.BroadcastAddr
        $Range = "$NetworkAddr ~ $BroadcastAddr"

        # The count is cheap arithmetic regardless of subnet size, so it's always calculated -- it's only
        # the full list of individual host addresses below that's gated behind the size/-Force check.
        $HostAddressCount = if ($Details.Mask -eq 32) { 1 } elseif ($Details.Mask -eq 31) { 2 } else { ($Details.HostEndAddr - $Details.HostStartAddr) + 1 }

        if ($Details.Mask -ge 16 -or $Force) {

            Write-Progress "Calcualting host addresses for $NetworkAddr/$($Details.Mask).."

            # Get-SubnetHostAddress does the actual enumeration -- it's given the already-resolved IP/Mask
            # directly, so it won't re-run local-IP lookup or mask inference (and won't duplicate the
            # warning Resolve-Subnet already issued above if the mask had to be inferred).
            $HostAddresses = @(Get-SubnetHostAddress -IP $Details.IPAddr.IPAddressToString -MaskBits $Details.Mask)

            if ($Details.Mask -ge 31) {
                $NetworkAddr = $null
                $BroadcastAddr = $null
            }
        }
        else {
            Write-Warning "The full list of host addresses was not returned because it would take some time for a /$($Details.Mask) subnet. `nUse -Force if you want it to occur. HostAddressCount has been calculated regardless."
        }

        [pscustomobject]@{
            IPAddress        = $Details.IPAddr
            MaskBits         = $Details.Mask
            NetworkAddress   = $NetworkAddr
            BroadcastAddress = $BroadcastAddr
            SubnetMask       = $Details.MaskAddr
            NetworkClass     = $Details.Class
            Range            = $Range
            HostAddresses    = $HostAddresses
            HostAddressCount = $HostAddressCount
        }
    }
}
