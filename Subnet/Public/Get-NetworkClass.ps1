function Get-NetworkClass {
    <#
        .SYNOPSIS
            Use to determine the network class of a given IP address.

        .DESCRIPTION
            Returns A, B, C, D or E depending on the numeric value of the first octet of a given IP address.

        .PARAMETER IP
            The IP address to test.

        .EXAMPLE
            Get-NetworkClass -IP 172.16.1.2

        .EXAMPLE
            '10.1.1.1' | Get-NetworkClass
    #>
    param(
        [parameter(Mandatory,ValueFromPipeline)]
        [string]
        $IP
    )
    process {

        switch ($IP.Split('.')[0]) {
            { $_ -in 0..127 } { 'A' }
            { $_ -in 128..191 } { 'B' }
            { $_ -in 192..223 } { 'C' }
            { $_ -in 224..239 } { 'D' }
            { $_ -in 240..255 } { 'E' }
        }
    }
}