function ConvertTo-PrefixLength {
    <#
        .SYNOPSIS
            Validates a -MaskBits value (or the mask from IP/Mask slash notation) and returns it as an [int]
            between 0 and 32. Returns $null for anything else.

        .NOTES
            Callers' -MaskBits parameters are deliberately untyped and validated here instead. Typed [int],
            PowerShell's parameter binder converts $null, '' and ' ' to 0 before any validation attribute
            runs (and [Nullable[int]] still converts '' to 0), so each would silently become a /0 network.

            Only integer types and strings of plain decimal digits with no sign, whitespace or leading
            zeros are accepted -- not e.g. 24.5, '+24', ' 24', '08' or '024'. This matches the no-leading-
            zeros rule Test-IPv4Address applies to each octet of the address.

            Returns $null rather than throwing, so callers can report a single non-terminating error. A
            throw, even one caught by the caller, adds extra duplicate records to the caller's -ErrorVariable.
    #>
    param (
        $MaskBits
    )

    $IntegerTypes = 'Byte', 'SByte', 'Int16', 'UInt16', 'Int32', 'UInt32', 'Int64', 'UInt64'

    $Value = $null
    if ($null -ne $MaskBits -and [Type]::GetTypeCode($MaskBits.GetType()).ToString() -in $IntegerTypes) {
        $Value = [int64]$MaskBits
    }
    elseif ($MaskBits -is [string] -and $MaskBits -match '\A(0|[1-9][0-9]?)\z') {
        $Value = [int64]$MaskBits
    }

    if ($null -ne $Value -and $Value -ge 0 -and $Value -le 32) {
        [int]$Value
    }
}
