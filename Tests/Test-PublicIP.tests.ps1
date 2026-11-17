Describe "Test-PublicIP PS$PSVersion" {

    BeforeAll {
        # Skipping the import when the module is already loaded avoids a second copy being loaded
        if (-not (Get-Module -Name 'Subnet')) {
            Import-Module $PSScriptRoot\..\Subnet
        }
    }

    $PrivateIPs = '10.0.0.0', '10.255.255.255', '172.16.0.0', '172.31.255.255', '192.168.0.0', '192.168.255.255'

    Context 'Private IPs' {

        It "Should return $false for <_>" -TestCases $PrivateIPs {
            InModuleScope Subnet -Parameters @{ IP = $_ } {
                Test-PublicIP -IP $IP | Should -Be $false
            }
        }
    }

    Context 'Private IPs with pipeline input' {

        It "Should return $false for <_>" -TestCases $PrivateIPs {
            InModuleScope Subnet -Parameters @{ IP = $_ } {
                $IP | Test-PublicIP | Should -Be $false
            }
        }
    }


    $PublicIPs = '9.255.255.255', '11.0.0.0', '172.15.255.255', '172.32.0.0', '192.167.255.255', '192.169.0.0'

    Context 'Public IPs' {

        It "Should return $true for <_>" -TestCases $PublicIPs {
            InModuleScope Subnet -Parameters @{ IP = $_ } {
                Test-PublicIP -IP $IP | Should -Be $true
            }
        }
    }

    Context 'Public IPs with pipeline input' {

        It "Should return $true for <_>" -TestCases $PublicIPs {
            InModuleScope Subnet -Parameters @{ IP = $_ } {
                $IP | Test-PublicIP | Should -Be $true
            }
        }
    }

    # Special-purpose ranges that are not globally reachable (RFC 6890), plus multicast. Each range is
    # tested at its first and last address, and just outside it where that address is public.
    $NotGlobalIPs = @(
        '0.0.0.0', '0.255.255.255'
        '100.64.0.0', '100.127.255.255'
        '127.0.0.0', '127.0.0.1', '127.255.255.255'
        '169.254.0.0', '169.254.255.255'
        '192.0.0.0', '192.0.0.8', '192.0.0.170', '192.0.0.255'
        '192.0.2.0', '192.0.2.255'
        '198.18.0.0', '198.19.255.255'
        '198.51.100.0', '198.51.100.255'
        '203.0.113.0', '203.0.113.255'
        '224.0.0.0', '224.0.0.1', '239.255.255.255'
        '240.0.0.0', '255.255.255.254', '255.255.255.255'
    )

    Context 'Special-purpose (not globally reachable) IPs' {

        It "Should return $false for <_>" -TestCases $NotGlobalIPs {
            Test-PublicIP -IP $_ | Should -Be $false
        }
    }

    $GlobalBoundaryIPs = @(
        '1.0.0.0', '100.63.255.255', '100.128.0.0', '126.255.255.255', '128.0.0.0'
        '169.253.255.255', '169.255.0.0', '191.255.255.255', '192.0.1.0', '192.0.3.0'
        '198.17.255.255', '198.20.0.0', '198.51.99.255', '198.51.101.0', '203.0.112.255', '203.0.114.0'
        '223.255.255.255', '8.8.8.8'
        # Marked as globally reachable within 192.0.0.0/24 by the IANA registry
        '192.0.0.9', '192.0.0.10'
    )

    Context 'Public IPs just outside the special-purpose ranges' {

        It "Should return $true for <_>" -TestCases $GlobalBoundaryIPs {
            Test-PublicIP -IP $_ | Should -Be $true
        }
    }

    It 'Should not simply be the inverse of Test-PrivateIP' {
        Test-PrivateIP -IP 169.254.1.1 | Should -Be $false
        Test-PublicIP -IP 169.254.1.1 | Should -Be $false
    }

    Context 'Invalid IPs' {

        It "Should throw a clear error for '<_>' rather than reporting it as public" -TestCases 'blah', '999.1.1.1', '10.evil', '192.168', '010.1.1.1', '1.2.3.4.5', '::1' {
            { Test-PublicIP -IP $_ -ErrorAction Stop } | Should -Throw "*'$_' is not a valid IPv4 address*"
        }

        It 'Should write a non-terminating error for an invalid IP and carry on with the rest of the pipeline' {
            $Result = '8.8.8.8', 'blah', '10.0.0.1' | Test-PublicIP -ErrorAction SilentlyContinue -ErrorVariable Errors

            $Result | Should -Be @($true, $false)
            $Errors | Should -HaveCount 1
            $Errors[0].Exception.Message | Should -BeLike "*'blah' is not a valid IPv4 address*"
        }
    }
}
