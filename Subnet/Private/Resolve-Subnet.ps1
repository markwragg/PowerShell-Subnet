function Resolve-Subnet {
    <#
        .SYNOPSIS
            Resolves an IP/Mask parameter pair (as accepted by Get-Subnet and Get-SubnetHostAddress) into
            the network's class, mask, addresses, and usable host address range.

        .NOTES
            $Mask is deliberately untyped rather than [int] -- callers pass $null to mean "not specified",
            and an [int] parameter would silently coerce that to 0, indistinguishable from an explicit /0.

            Invalid input doesn't throw. Instead an object with just an Error property (the message) is
            returned, for the calling cmdlet to report as a single non-terminating error. A throw, even one
            caught by the caller, adds extra duplicate records to the caller's -ErrorVariable.
    #>
    param (
        [string]$IP,
        $Mask
    )

    if (-not $IP) {
        $LocalIP = Get-LocalIPv4Address

        if (-not $LocalIP) {
            return [pscustomobject]@{ Error = 'Unable to determine a local IPv4 address for this system. Please specify the -IP parameter explicitly.' }
        }

        $IP = $LocalIP.IPAddress
        if ($Mask -notin 0..32) { $Mask = $LocalIP.PrefixLength }
    }

    if ($IP.Contains('/')) {
        $IPandMask = $IP -Split '/'
        # Previously an out-of-range mask (e.g. /33) was silently discarded and replaced by the class
        # default, and anything after a second '/' was ignored.
        $Mask = $null
        if ($IPandMask.Count -eq 2) {
            # ConvertTo-PrefixLength returns an [int]. That matters: left as a string, PowerShell's
            # comparison operators compare it lexicographically -- e.g. '8' -ge 16 is $true -- which
            # mis-triggers (or skips) the -ge 16 / -ge 31 checks callers make against the resolved Mask.
            $Mask = ConvertTo-PrefixLength -MaskBits $IPandMask[1]
        }
        if ($null -eq $Mask) {
            return [pscustomobject]@{ Error = "'$IP' does not have a valid subnet mask. Specify a mask between /0 and /32." }
        }
        $IP = $IPandMask[0]
    }

    # Validate the IP address and ensure it's IPv4. [ipaddress]::TryParse returns $false for invalid addresses, and also for valid IPv6 addresses.
    # It also accepts legacy short/hex/octal forms though, so Test-IPv4Address is checked first.
    $ParsedIP = $null
    if (-not (Test-IPv4Address -IP $IP) -or
        -not [ipaddress]::TryParse($IP, [ref]$ParsedIP) -or $ParsedIP.AddressFamily -ne [System.Net.Sockets.AddressFamily]::InterNetwork) {
        return [pscustomobject]@{ Error = "'$IP' is not a valid IPv4 address." }
    }

    $Class = Get-NetworkClass -IP $IP

    if ($Mask -notin 0..32) {

        $Mask = switch ($Class) {
            'A' { 8 }
            'B' { 16 }
            'C' { 24 }
        }

        if ($null -eq $Mask) {
            return [pscustomobject]@{ Error = "Subnet mask size was not specified and could not be inferred because the address is Class $Class." }
        }

        Write-Warning "Subnet mask size was not specified. Using default subnet size for a Class $Class network of /$Mask."
    }

    $IPAddr = $ParsedIP
    $MaskAddr = [ipaddress]::Parse((Convert-Int64toIP -int ([convert]::ToInt64(("1" * $Mask + "0" * (32 - $Mask)), 2))))
    $NetworkAddr = [ipaddress]($MaskAddr.address -band $IPAddr.address)
    $BroadcastAddr = [ipaddress](([ipaddress]::parse("255.255.255.255").address -bxor $MaskAddr.address -bor $NetworkAddr.address))

    $HostStartAddr = (Convert-IPtoInt64 -ip $NetworkAddr.ipaddresstostring) + 1
    $HostEndAddr = (Convert-IPtoInt64 -ip $BroadcastAddr.ipaddresstostring) - 1

    [pscustomobject]@{
        Error         = $null
        IPAddr        = $IPAddr
        Mask          = $Mask
        Class         = $Class
        MaskAddr      = $MaskAddr
        NetworkAddr   = $NetworkAddr
        BroadcastAddr = $BroadcastAddr
        HostStartAddr = $HostStartAddr
        HostEndAddr   = $HostEndAddr
    }
}
