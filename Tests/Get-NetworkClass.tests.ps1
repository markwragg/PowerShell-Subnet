Describe "Get-NetworkClass PS$PSVersion" {

    BeforeAll {
        if (-not (Get-Module -Name 'Subnet')) {
            Import-Module $PSScriptRoot\..\Subnet
        }

        Mock Write-Warning {} -ModuleName Subnet
        Mock Write-Progress {} -ModuleName Subnet
    }

    Context 'Class A IPs' {

        $ClassAIPs = '0.0.0.0', '1.1.1.1', '127.0.0.0'

        It "Should return A for <_>" -TestCases $ClassAIPs {
            Get-NetworkClass -IP $_ | Should -Be 'A'
        }
    }

    Context 'Class B IPs' {

        $ClassBIPs = '128.0.0.0', '175.255.0.0', '191.255.0.0'

        It "Should return B for <_>" -TestCases $ClassBIPs {
            Get-NetworkClass -IP $_ | Should -Be 'B'
        }
    }

    Context 'Class C IPs' {

        $ClassCIPs = '192.0.0.0', '200.255.255.0', '223.255.255.0'

        It "Should return C for <_>" -TestCases $ClassCIPs {
            Get-NetworkClass -IP $_ | Should -Be 'C'
        }
    }

    Context 'Class D IPs' {

        $ClassDIPs = '224.0.0.0', '235.0.0.0', '239.255.255.255'

        It "Should return D for <_>" -TestCases $ClassDIPs {
            Get-NetworkClass -IP $_ | Should -Be 'D'
        }
    }

    Context 'Class E IPs' {

        $ClassEIPs = '240.0.0.0', '245.0.0.0', '255.255.255.255'

        It "Should return E for <_>" -TestCases $ClassEIPs {
            Get-NetworkClass -IP $_ | Should -Be 'E'
        }
    }

    Context 'Invalid IPs' {

        It "Should throw a clear error for '<_>'" -TestCases 'blah', '999.1.1.1', '10.evil', '1.2.3', '0', '010.1.1.1', '1.2.3.4.5', '::1' {
            { Get-NetworkClass -IP $_ -ErrorAction Stop } | Should -Throw "*'$_' is not a valid IPv4 address*"
        }

        It 'Should write a non-terminating error for an invalid IP and carry on with the rest of the pipeline' {
            $Result = '8.8.8.8', 'blah', '192.168.1.1' | Get-NetworkClass -ErrorAction SilentlyContinue -ErrorVariable Errors

            $Result | Should -Be @('A', 'C')
            $Errors | Should -HaveCount 1
            $Errors[0].Exception.Message | Should -BeLike "*'blah' is not a valid IPv4 address*"
        }
    }
}