function Resolve-Subnet {
    <#
        .SYNOPSIS
            Resolves an IP/Mask parameter pair (as accepted by Get-Subnet and Get-SubnetHostAddress) into
            the network's class, mask, addresses, and usable host address range.

        .NOTES
            $Mask is deliberately untyped rather than [int] -- callers pass $null to mean "not specified",
            and an [int] parameter would silently coerce that to 0, indistinguishable from an explicit /0.
    #>
    param (
        [string]$IP,
        $Mask
    )

    if (-not $IP) {
        $LocalIP = Get-LocalIPv4Address

        if (-not $LocalIP) {
            throw "Unable to determine a local IPv4 address for this system. Please specify the -IP parameter explicitly."
        }

        $IP = $LocalIP.IPAddress
        if ($Mask -notin 0..32) { $Mask = $LocalIP.PrefixLength }
    }

    if ($IP -match '/\d') {
        $IPandMask = $IP -Split '/'
        $IP = $IPandMask[0]
        # Without this cast, $Mask stays a string here, and PowerShell's comparison operators then
        # compare it lexicographically rather than numerically -- e.g. '8' -ge 16 is $true, because
        # '8' -ge 16 is stringwise, so '8' > '1'. That silently mis-triggers (or skips) the -ge 16 /
        # -ge 31 checks that callers make against the resolved Mask, for any single-digit mask (/0 - /9).
        $Mask = [int]$IPandMask[1]
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
    $HostEndAddr = (Convert-IPtoInt64 -ip $BroadcastAddr.ipaddresstostring) - 1

    [pscustomobject]@{
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
