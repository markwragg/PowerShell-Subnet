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

    It 'Should throw when the mask cannot be inferred for a Class D or E address' {
        InModuleScope Subnet {
            { Resolve-Subnet -IP '224.1.2.3' -Mask $null } | Should -Throw
        }
    }

    It 'Should throw a clear error for an unparseable IP address, rather than silently zeroing the mask' {
        InModuleScope Subnet {
            { Resolve-Subnet -IP 'blah' -Mask $null } | Should -Throw "*'blah' is not a valid IPv4 address*"
        }
    }

    It 'Should throw a clear error for an out-of-range IP address' {
        InModuleScope Subnet {
            { Resolve-Subnet -IP '999.1.2.3' -Mask $null } | Should -Throw "*'999.1.2.3' is not a valid IPv4 address*"
        }
    }

    It 'Should throw a clear error for an IPv6 address' {
        InModuleScope Subnet {
            { Resolve-Subnet -IP '::1' -Mask $null } | Should -Throw "*'::1' is not a valid IPv4 address*"
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

    It 'Should throw a clear error when no IP is given and no local IPv4 address can be found' {
        InModuleScope Subnet {
            Mock Get-LocalIPv4Address { $null }

            { Resolve-Subnet -IP $null -Mask $null } | Should -Throw '*Please specify the -IP parameter explicitly*'
        }
    }
}
