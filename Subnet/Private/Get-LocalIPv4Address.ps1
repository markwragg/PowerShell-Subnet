function Get-LocalIPv4Address {
    <#
        .SYNOPSIS
            Returns the IPv4 address and prefix length of the first active, non-loopback network interface.

        .NOTES
            [System.Net.NetworkInformation.NetworkInterface] is part of the base class library, so unlike
            Get-NetIPAddress (Windows-only) this works the same way on Windows, Linux and macOS.
    #>
    $UnicastAddress = [System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() |
        Where-Object { $_.OperationalStatus -eq 'Up' -and $_.NetworkInterfaceType -ne 'Loopback' } |
        ForEach-Object { $_.GetIPProperties().UnicastAddresses } |
        Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' } |
        Select-Object -First 1

    if (-not $UnicastAddress) {
        return
    }

    [pscustomobject]@{
        IPAddress    = $UnicastAddress.Address.IPAddressToString
        PrefixLength = Get-UnicastAddressPrefixLength -UnicastAddress $UnicastAddress
    }
}
