function Test-PublicIP {
    <#
        .SYNOPSIS
            Use to determine if a given IP address is within the IPv4 public address space.

        .DESCRIPTION
            Returns $true or $false for a given IP address string depending on whether or not it is a public
            (globally reachable) unicast address.

            An address is not public if it is within any of the ranges the IANA IPv4 Special-Purpose Address
            Registry (RFC 6890) marks as not globally reachable, or is a multicast address:

            0.0.0.0/8        "This network" (RFC 791)
            10.0.0.0/8       Private-Use (RFC 1918)
            100.64.0.0/10    Shared Address Space / carrier-grade NAT (RFC 6598)
            127.0.0.0/8      Loopback (RFC 1122)
            169.254.0.0/16   Link-Local (RFC 3927)
            172.16.0.0/12    Private-Use (RFC 1918)
            192.0.0.0/24     IETF Protocol Assignments (RFC 6890), except 192.0.0.9 and 192.0.0.10
            192.0.2.0/24     Documentation, TEST-NET-1 (RFC 5737)
            192.168.0.0/16   Private-Use (RFC 1918)
            198.18.0.0/15    Benchmarking (RFC 2544)
            198.51.100.0/24  Documentation, TEST-NET-2 (RFC 5737)
            203.0.113.0/24   Documentation, TEST-NET-3 (RFC 5737)
            224.0.0.0/4      Multicast (RFC 5771)
            240.0.0.0/4      Reserved (RFC 1112), including 255.255.255.255, Limited Broadcast (RFC 919)

            This is not simply the inverse of Test-PrivateIP, which only tests for the RFC 1918 private ranges
            and loopback.

        .PARAMETER IP
            The IP address to test.

        .EXAMPLE
            Test-PublicIP -IP 8.8.8.8

            Result
            ------
            True

        .EXAMPLE
            Test-PublicIP -IP 169.254.1.1

            Result
            ------
            False
    #>
    param(
        [parameter(Mandatory,ValueFromPipeline)]
        [string]
        $IP
    )
    begin {
        $NotGlobal = '0.0.0.0/8', '10.0.0.0/8', '100.64.0.0/10', '127.0.0.0/8', '169.254.0.0/16', '172.16.0.0/12',
        '192.0.0.0/24', '192.0.2.0/24', '192.168.0.0/16', '198.18.0.0/15', '198.51.100.0/24', '203.0.113.0/24',
        '224.0.0.0/4', '240.0.0.0/4'

        # Within 192.0.0.0/24, these are marked as globally reachable by the IANA registry.
        $GlobalExceptions = '192.0.0.9', '192.0.0.10'

        $Ranges = foreach ($Range in $NotGlobal) {
            $Network, $Bits = $Range -split '/'
            [pscustomobject]@{
                Network = Convert-IPtoInt64 -ip $Network
                Size    = [int64][math]::Pow(2, 32 - [int]$Bits)
            }
        }
    }
    process {

        # Non-terminating, so one invalid item in a pipeline doesn't stop the rest being processed.
        if (-not (Test-IPv4Address -IP $IP)) {
            Write-Error "'$IP' is not a valid IPv4 address."
            return
        }

        if ($IP -in $GlobalExceptions) {
            return $true
        }

        $Address = Convert-IPtoInt64 -ip $IP

        foreach ($Range in $Ranges) {
            if ($Address -ge $Range.Network -and $Address -lt $Range.Network + $Range.Size) {
                return $false
            }
        }

        $true
    }
}
