function Test-IPv4Address {
    <#
        .SYNOPSIS
            Returns $true if the given string is an IPv4 address written as four plain decimal octets.

        .NOTES
            [ipaddress]::TryParse is deliberately not used on its own for validation, as it also accepts
            legacy short, hex and octal forms (e.g. '1.2.3' -> 1.2.0.3, '0' -> 0.0.0.0, and '010.1.1.1' ->
            8.1.1.1), which would silently resolve to a different address than the one typed. Each octet
            must be 0-255 with no leading zeros, matching the IPv4address/dec-octet grammar in RFC 3986
            section 3.2.2.

            [0-9] is used rather than \d, as .NET's \d also matches non-ASCII digits (e.g. Arabic-Indic),
            and \A/\z are used rather than ^/$, as .NET's $ also matches before a trailing newline.
    #>
    param (
        [string]$IP
    )

    $Octet = '(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])'
    $IP -match "\A$Octet(\.$Octet){3}\z"
}
