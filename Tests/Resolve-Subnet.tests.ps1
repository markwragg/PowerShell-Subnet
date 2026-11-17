Describe "Resolve-Subnet PS$PSVersion" {

    BeforeAll {
        if (-not (Get-Module -Name 'Subnet')) {
            Import-Module $PSScriptRoot\..\Subnet
        }
    }

    It 'Should resolve an IP and separately specified mask' {
        InModuleScope Subnet {
            $Result = Resolve-Subnet -IP '1.2.3.4' -Mask 24

            $Result.IPAddr.IPAddressToString | Should -Be '1.2.3.4'
            $Result.Mask | Should -Be 24
            $Result.Class | Should -Be 'A'
            $Result.NetworkAddr.IPAddressToString | Should -Be '1.2.3.0'
            $Result.BroadcastAddr.IPAddressToString | Should -Be '1.2.3.255'
            $Result.HostStartAddr | Should -Be (Convert-IPtoInt64 -ip '1.2.3.1')
            $Result.HostEndAddr | Should -Be (Convert-IPtoInt64 -ip '1.2.3.254')
        }
    }

    It 'Should resolve an IP given in "IP/Mask" notation, including single-digit masks' {
        InModuleScope Subnet {
            $Result = Resolve-Subnet -IP '10.0.0.0/8' -Mask $null

            $Result.Mask | Should -Be 8
            $Result.Mask | Should -BeOfType [int]
            $Result.NetworkAddr.IPAddressToString | Should -Be '10.0.0.0'
            $Result.BroadcastAddr.IPAddressToString | Should -Be '10.255.255.255'
        }
    }

    It 'Should infer the mask from the network class when not specified, with a warning' {
        InModuleScope Subnet {
            Mock Write-Warning {}

            $Result = Resolve-Subnet -IP '192.168.1.1' -Mask $null

            $Result.Mask | Should -Be 24
            Should -Invoke Write-Warning -Times 1 -Exactly
        }
    }

    It 'Should return an error when the mask cannot be inferred for a Class D or E address' {
        InModuleScope Subnet {
            (Resolve-Subnet -IP '224.1.2.3' -Mask $null).Error | Should -Not -BeNullOrEmpty
        }
    }

    It 'Should return a clear error for an unparseable IP address, rather than silently zeroing the mask' {
        InModuleScope Subnet {
            (Resolve-Subnet -IP 'blah' -Mask $null).Error | Should -BeLike "*'blah' is not a valid IPv4 address*"
        }
    }

    It 'Should return a clear error for an out-of-range IP address' {
        InModuleScope Subnet {
            (Resolve-Subnet -IP '999.1.2.3' -Mask $null).Error | Should -BeLike "*'999.1.2.3' is not a valid IPv4 address*"
        }
    }

    It 'Should return a clear error for an IPv6 address' {
        InModuleScope Subnet {
            (Resolve-Subnet -IP '::1' -Mask $null).Error | Should -BeLike "*'::1' is not a valid IPv4 address*"
        }
    }

    It "Should reject the non-dotted-quad form '<IP>', rather than silently resolving it to a different address" -ForEach @(
        @{ IP = '1.2.3' }
        @{ IP = '1.2' }
        @{ IP = '1' }
        @{ IP = '0' }
        @{ IP = '0x7f.1' }
        @{ IP = '010.1.1.1' }
        @{ IP = '192.168.001.001' }
        @{ IP = '1.2.3.4.5' }
        @{ IP = ' 1.2.3.4' }
    ) {
        InModuleScope Subnet -Parameters @{ IP = $IP } {
            (Resolve-Subnet -IP $IP -Mask 24).Error | Should -BeLike "*'$IP' is not a valid IPv4 address*"
        }
    }

    It "Should return an error for the invalid subnet mask in '<IP>', rather than silently using the class default" -ForEach @(
        @{ IP = '1.2.3.4/33' }
        @{ IP = '1.2.3.4/99' }
        @{ IP = '1.2.3.4/-1' }
        @{ IP = '1.2.3.4/' }
        @{ IP = '1.2.3.4/24x' }
        @{ IP = '1.2.3.4/24/8' }
        @{ IP = '1.2.3.4/024' }
        @{ IP = '1.2.3.4/08' }
        @{ IP = "1.2.3.4/24`n" }
    ) {
        InModuleScope Subnet -Parameters @{ IP = $IP } {
            (Resolve-Subnet -IP $IP -Mask $null).Error | Should -BeLike '*does not have a valid subnet mask*'
        }
    }

    It 'Should accept masks from /0 to /32 via slash notation' {
        InModuleScope Subnet {
            (Resolve-Subnet -IP '10.0.0.0/0' -Mask $null).Mask | Should -Be 0
            (Resolve-Subnet -IP '10.0.0.0/8' -Mask $null).Mask | Should -Be 8
            (Resolve-Subnet -IP '10.0.0.0/32' -Mask $null).Mask | Should -Be 32
        }
    }

    It 'Should still accept valid dotted-quad addresses, including 0 and 255 octets' {
        InModuleScope Subnet {
            (Resolve-Subnet -IP '0.0.0.0' -Mask 8).IPAddr.ToString() | Should -Be '0.0.0.0'
            (Resolve-Subnet -IP '255.255.255.255' -Mask 32).IPAddr.ToString() | Should -Be '255.255.255.255'
            (Resolve-Subnet -IP '10.20.30.40' -Mask 24).IPAddr.ToString() | Should -Be '10.20.30.40'
        }
    }

    It 'Should fall back to the local IPv4 address when no IP is given' {
        InModuleScope Subnet {
            Mock Get-LocalIPv4Address {
                [pscustomobject]@{ IPAddress = '192.168.1.50'; PrefixLength = 24 }
            }

            $Result = Resolve-Subnet -IP $null -Mask $null

            $Result.IPAddr.IPAddressToString | Should -Be '192.168.1.50'
            $Result.Mask | Should -Be 24
        }
    }

    It 'Should return a clear error when no IP is given and no local IPv4 address can be found' {
        InModuleScope Subnet {
            Mock Get-LocalIPv4Address { $null }

            (Resolve-Subnet -IP $null -Mask $null).Error | Should -BeLike '*Please specify the -IP parameter explicitly*'
        }
    }
}
