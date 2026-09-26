function Convert-SubnetMaskToPrefixLength ([System.Net.IPAddress]$SubnetMask) {
    <#
        .SYNOPSIS
            Converts a dotted-decimal subnet mask (e.g. 255.255.255.0) to its prefix length in bits (e.g. 24).
    #>
    $Bits = ($SubnetMask.GetAddressBytes() | ForEach-Object { [Convert]::ToString($_, 2).PadLeft(8, '0') }) -join ''
    ($Bits.ToCharArray() | Where-Object { $_ -eq '1' }).Count
}
