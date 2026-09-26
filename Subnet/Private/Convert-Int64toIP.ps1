function Convert-Int64toIP ([int64]$int) {
    <#
        .SYNOPSIS
            Converts a 32-bit integer to its dotted-decimal IPv4 address string representation.
    #>
    (([math]::truncate($int / 16777216)).tostring() + "." + ([math]::truncate(($int % 16777216) / 65536)).tostring() + "." + ([math]::truncate(($int % 65536) / 256)).tostring() + "." + ([math]::truncate($int % 256)).tostring() )
}
