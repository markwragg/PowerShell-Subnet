function Get-SubnetHostAddress {
    <#
        .SYNOPSIS
            Returns the list of usable host IP addresses, as [ipaddress] objects, for a given network
            address and mask.

        .DESCRIPTION
            Unlike Get-Subnet, this always calculates and returns the full list of host addresses
            regardless of subnet size, since that's this cmdlet's only job. It still warns (but does not
            refuse) when the subnet is larger than /16, since generating the full list for a very large
            subnet can take some time.

        .PARAMETER IP
            The network IP address or IP address with subnet mask via slash notation.

        .PARAMETER MaskBits
            The numerical representation of the subnet mask.

        .PARAMETER AsString
            Return the host addresses as strings instead of [ipaddress] objects.

        .EXAMPLE
            Get-SubnetHostAddress 10.1.2.3/24

            Description
            -----------
            Returns the list of host addresses for the specified network and mask.

        .EXAMPLE
            Get-SubnetHostAddress 10.1.2.3/24 -AsString

            Description
            -----------
            Returns the list of host addresses for the specified network and mask, as strings instead of
            [ipaddress] objects.

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

        .EXAMPLE
            Get-Subnet 10.1.2.3/24 | Get-SubnetHostAddress

            Description
            -----------
            Returns the list of host addresses for the network and mask resolved by Get-Subnet.
    #>
    param (
        [parameter(ValueFromPipeline)]
        $IP,

        [ValidateRange(0, 32)]
        [Alias('CIDR')]
        [int]
        $MaskBits,

        [switch]
        $AsString
    )
    process {

        $ProvidedMaskBits = $PSBoundParameters.ContainsKey('MaskBits')

        if ($IP -isnot [string]) {
            # Accept the object output by Get-Subnet (or anything else exposing IPAddress/MaskBits
            # properties) piped in directly, rather than requiring its properties be extracted manually.
            # $IP can't be typed [string] to enable this -- PowerShell's pipeline binder would coerce the
            # whole object to a string (via its default ToString()) before this code ever ran.
            if (-not $ProvidedMaskBits) {
                $MaskBits = $IP.MaskBits
                $ProvidedMaskBits = $true
            }
            $IP = $IP.IPAddress.ToString()
        }

        $Mask = $null
        if ($ProvidedMaskBits) { $Mask = $MaskBits }

        $Details = Resolve-Subnet -IP $IP -Mask $Mask

        if ($Details.Mask -lt 16) {
            Write-Warning "Calculating host addresses for a /$($Details.Mask) subnet may take some time."
        }

        if ($Details.Mask -ge 31) {
            if ($AsString) {
                $Details.NetworkAddr.IPAddressToString
                if ($Details.Mask -eq 31) {
                    $Details.BroadcastAddr.IPAddressToString
                }
            }
            else {
                $Details.NetworkAddr
                if ($Details.Mask -eq 31) {
                    $Details.BroadcastAddr
                }
            }
        }
        elseif ($AsString) {
            # Inlined rather than calling Convert-Int64toIP -- this loop can run millions of times for
            # large subnets, and paying PowerShell's per-call function dispatch overhead on every single
            # address measurably dominates the runtime at that scale.
            for ($i = $Details.HostStartAddr; $i -le $Details.HostEndAddr; $i++) {
                "$($i -shr 24 -band 255).$($i -shr 16 -band 255).$($i -shr 8 -band 255).$($i -band 255)"
            }
        }
        else {
            # Returns [ipaddress] objects (via the 4-byte constructor, since the byte order of the plain
            # int/long constructors doesn't match this loop's big-endian octet math) rather than strings.
            # Kept as a separate loop from the -AsString one above (rather than branching inside a single
            # loop) so the hot path isn't paying a per-iteration branch check on top of the per-call
            # dispatch overhead already called out above.
            for ($i = $Details.HostStartAddr; $i -le $Details.HostEndAddr; $i++) {
                [ipaddress]::new([byte[]](($i -shr 24 -band 255), ($i -shr 16 -band 255), ($i -shr 8 -band 255), ($i -band 255)))
            }
        }
    }
}
