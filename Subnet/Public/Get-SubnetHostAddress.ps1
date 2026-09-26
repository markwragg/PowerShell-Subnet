function Get-SubnetHostAddress {
    <#
        .SYNOPSIS
            Returns the list of usable host IP addresses for a given network address and mask.

        .DESCRIPTION
            Unlike Get-Subnet, this always calculates and returns the full list of host addresses
            regardless of subnet size, since that's this cmdlet's only job. It still warns (but does not
            refuse) when the subnet is larger than /16, since generating the full list for a very large
            subnet can take some time.

        .PARAMETER IP
            The network IP address or IP address with subnet mask via slash notation.

        .PARAMETER MaskBits
            The numerical representation of the subnet mask.

        .EXAMPLE
            Get-SubnetHostAddress 10.1.2.3/24

            Description
            -----------
            Returns the list of host addresses for the specified network and mask.

        .EXAMPLE
            Get-SubnetHostAddress -IP 192.168.0.1 -MaskBits 12

            Description
            -----------
            Returns the list of host addresses for the specified (large) network and mask. A warning is
            shown that this may take some time, but the addresses are still returned.

        .EXAMPLE
            '10.1.2.3/24','10.1.2.4/24' | Get-SubnetHostAddress

            Description
            -----------
            Returns the list of host addresses for two specified networks.
    #>
    param (
        [parameter(ValueFromPipeline)]
        [string]
        $IP,

        [ValidateRange(0, 32)]
        [Alias('CIDR')]
        [int]
        $MaskBits
    )
    process {

        $Mask = $null
        if ($PSBoundParameters.ContainsKey('MaskBits')) { $Mask = $MaskBits }

        $Details = Resolve-Subnet -IP $IP -Mask $Mask

        if ($Details.Mask -lt 16) {
            Write-Warning "Calculating host addresses for a /$($Details.Mask) subnet may take some time."
        }

        if ($Details.Mask -ge 31) {
            $Details.NetworkAddr
            if ($Details.Mask -eq 31) {
                $Details.BroadcastAddr
            }
        }
        else {
            # Inlined rather than calling Convert-Int64toIP -- this loop can run millions of times for
            # large subnets, and paying PowerShell's per-call function dispatch overhead on every single
            # address measurably dominates the runtime at that scale.
            for ($i = $Details.HostStartAddr; $i -le $Details.HostEndAddr; $i++) {
                "$($i -shr 24 -band 255).$($i -shr 16 -band 255).$($i -shr 8 -band 255).$($i -band 255)"
            }
        }
    }
}
