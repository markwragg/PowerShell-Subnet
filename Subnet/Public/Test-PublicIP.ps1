function Test-PublicIP {
    <#
        .SYNOPSIS
            Use to determine if a given IP address is within the IPv4 public address space.

        .DESCRIPTION
            Returns $true or $false for a given IP address string depending on whether or not it is within the public IP address space, i.e it is not within the private IP address ranges.

        .PARAMETER IP
            The IP address to test.

        .EXAMPLE
            Test-PublicIP -IP 8.8.8.8

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
        -not (Test-PrivateIP -IP $IP)
    }
}
