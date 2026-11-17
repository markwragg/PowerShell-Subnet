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

            If no mask is specified (either via slash notation or -MaskBits), one is inferred from the
            address class (/8 for Class A, /16 for Class B, /24 for Class C) and a warning is shown. Be
            aware that for a Class A or B address this can mean a very large number of addresses.

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
        [parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        $IP,

        # Deliberately untyped: as [int], $null and '' would be silently converted to 0 (i.e. /0). It's
        # validated by ConvertTo-PrefixLength instead.
        [Alias('CIDR')]
        $MaskBits,

        [switch]
        $AsString
    )
    process {

        # Invalid input is reported as a non-terminating error, so one bad item in a pipeline doesn't stop
        # the rest being processed (-ErrorAction Stop still makes it terminating, as usual).
        if ($null -eq $IP -or ($IP -is [string] -and [string]::IsNullOrWhiteSpace($IP))) {
            Write-Error 'An IP address must be provided.'
            return
        }

        $ProvidedMaskBits = $PSBoundParameters.ContainsKey('MaskBits')

        if ($IP -is [ipaddress]) {
            # Accept an [ipaddress] directly (as Get-Subnet does via its [string] parameter). IPv6 is
            # rejected by the IPv4 validation in Resolve-Subnet.
            $IP = $IP.IPAddressToString
        }

        if ($IP -isnot [string]) {
            # Accept the object output by Get-Subnet (or anything else exposing IPAddress/MaskBits
            # properties) piped in directly, rather than requiring its properties be extracted manually.
            # $IP can't be typed [string] to enable this -- PowerShell's pipeline binder would coerce the
            # whole object to a string (via its default ToString()) before this code ever ran.
            if ($null -eq $IP.IPAddress) {
                # Without this, a non-string value that isn't a Get-Subnet-style object (e.g. 0) would
                # carry on unchanged and be stringified later, with 0 resolving to a 0.0.0.0/0 network.
                Write-Error "'$IP' is not a valid IPv4 address."
                return
            }
            # An object with no MaskBits leaves the mask unspecified, so it's inferred as usual.
            if (-not $ProvidedMaskBits -and $null -ne $IP.MaskBits) {
                $MaskBits = $IP.MaskBits
                $ProvidedMaskBits = $true
            }
            $IP = $IP.IPAddress.ToString()
        }

        $Mask = $null
        if ($ProvidedMaskBits) {
            $Mask = ConvertTo-PrefixLength -MaskBits $MaskBits
            if ($null -eq $Mask) {
                Write-Error "'$MaskBits' is not a valid subnet mask. Specify a value between 0 and 32."
                return
            }
        }

        $Details = Resolve-Subnet -IP $IP -Mask $Mask
        if ($Details.Error) {
            Write-Error $Details.Error
            return
        }

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
