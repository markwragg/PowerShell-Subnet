function Get-UnicastAddressPrefixLength ($UnicastAddress) {
    <#
        .SYNOPSIS
            Returns the prefix length of a UnicastIPAddressInformation object, falling back to counting
            the bits of its subnet mask when .PrefixLength isn't implemented.

        .NOTES
            Reflection's GetValue() is used here rather than plain '.' property access because PowerShell
            silently swallows exceptions raised by a .NET property getter accessed via '.' instead of
            surfacing them to try/catch.

            .PrefixLength isn't implemented on .NET Framework (Windows PowerShell), so fall back to
            counting the bits of .IPv4Mask there instead -- and the reverse is true on Linux/macOS, where
            .IPv4Mask throws because those platforms have no concept of a dotted-decimal subnet mask.
    #>
    try {
        $UnicastAddress.GetType().GetProperty('PrefixLength').GetValue($UnicastAddress)
    }
    catch {
        Convert-SubnetMaskToPrefixLength -SubnetMask $UnicastAddress.IPv4Mask
    }
}
