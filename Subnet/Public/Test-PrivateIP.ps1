function Test-PrivateIP {
    <#
        .SYNOPSIS
            Use to determine if a given IP address is within the IPv4 private address space ranges.

        .DESCRIPTION
            Returns $true or $false for a given IP address string depending on whether or not it is within the
            RFC 1918 private IP address ranges (10.0.0.0/8, 172.16.0.0/12 and 192.168.0.0/16) or the loopback
            range (127.0.0.0/8, RFC 1122).

            Loopback is not an RFC 1918 range, but has always been included here for compatibility. Note that
            an address that isn't private is not necessarily public (e.g. link-local or carrier-grade NAT
            addresses), so use Test-PublicIP to test for that.

        .PARAMETER IP
            The IP address to test.

        .EXAMPLE
            Test-PrivateIP -IP 172.16.1.2

            Result
            ------
            True
    #>
    param(
        [parameter(Mandatory,ValueFromPipeline)]
        [string]
        $IP
    )
    process {

        # Non-terminating, so one invalid item in a pipeline doesn't stop the rest being processed.
        if (-not (Test-IPv4Address -IP $IP)) {
            Write-Error "'$IP' is not a valid IPv4 address."
            return
        }

        if ($IP -Match '(^127\.)|(^192\.168\.)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)') {
            $true
        }
        else {
            $false
        }
    }    
}