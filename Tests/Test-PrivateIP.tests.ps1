Describe "Test-PrivateIP PS$PSVersion" {

    BeforeAll {
        # Skipping the import when the module is already loaded avoids a second copy being loaded
        if (-not (Get-Module -Name 'Subnet')) {
            Import-Module $PSScriptRoot\..\Subnet
        }
    }

    $PrivateIPs = '10.0.0.0', '10.255.255.255', '172.16.0.0', '172.31.255.255', '192.168.0.0', '192.168.255.255'

    Context 'Private IPs' {

        It "Should return $true for <_>" -TestCases $PrivateIPs {
            InModuleScope Subnet -Parameters @{ IP = $_ } {
                Test-PrivateIP -IP $IP | Should -Be $true
            }
        }
    }

    Context 'Private IPs with pipeline input' {

        It "Should return $true for <_>" -TestCases $PrivateIPs {
            InModuleScope Subnet -Parameters @{ IP = $_ } {
                $IP | Test-PrivateIP | Should -Be $true
            }
        }
    }


    $PublicIPs = '9.255.255.255', '11.0.0.0', '172.15.255.255', '172.32.0.0', '192.167.255.255', '192.169.0.0'

    Context 'Public IPs' {


        It "Should return $false for <_>" -TestCases $PublicIPs {
            InModuleScope Subnet -Parameters @{ IP = $_ } {
                Test-PrivateIP -IP $IP | Should -Be $false
            }
        }
    }

    Context 'Public IPs with pipeline input' {

        It "Should return $false for <_>" -TestCases $PublicIPs {
            InModuleScope Subnet -Parameters @{ IP = $_ } {
                $IP | Test-PrivateIP | Should -Be $false
            }
        }
    }

    Context 'Invalid IPs' {

        It "Should throw a clear error for '<_>' rather than pattern matching it" -TestCases 'blah', '999.1.1.1', '10.evil', '10.1', '192.168', '010.1.1.1', '1.2.3.4.5', '::1' {
            { Test-PrivateIP -IP $_ -ErrorAction Stop } | Should -Throw "*'$_' is not a valid IPv4 address*"
        }

        It 'Should write a non-terminating error for an invalid IP and carry on with the rest of the pipeline' {
            $Result = '8.8.8.8', 'blah', '10.0.0.1' | Test-PrivateIP -ErrorAction SilentlyContinue -ErrorVariable Errors

            $Result | Should -Be @($false, $true)
            $Errors | Should -HaveCount 1
            $Errors[0].Exception.Message | Should -BeLike "*'blah' is not a valid IPv4 address*"
        }
    }
}