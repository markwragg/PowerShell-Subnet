function Convert-Int64toIP ([int64]$int) {
    <#
        .SYNOPSIS
            Converts a 32-bit integer to its dotted-decimal IPv4 address string representation.

        .NOTES
            Uses bit-shifting rather than division -- PowerShell's '/' operator always promotes to
            floating point, so the previous [math]::truncate($int / 16777216) approach paid for a
            double conversion on every octet. Bitwise ops stay in integer math throughout, which
            matters here since this can run in a tight loop generating millions of host addresses.
    #>
    "$($int -shr 24 -band 255).$($int -shr 16 -band 255).$($int -shr 8 -band 255).$($int -band 255)"
}
