function Test-PrivateIP {
    <#
        .SYNOPSIS
            Use to determine if a given IP address is within the IPv4 private address space ranges.

        .DESCRIPTION
            Returns $true or $false for a given IP address string depending on whether or not is is within the private IP address ranges.

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

        if ($IP -Match '(^127\.)|(^192\.168\.)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)') {
            $true
        }
        else {
            $false
        }
    }    
}